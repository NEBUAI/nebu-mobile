import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ProgressService } from '../../progress/services/progress.service';
import { getCorsOrigins } from '../../config/cors.config';

@WebSocketGateway({
  cors: {
    origin: getCorsOrigins(),
    credentials: true,
  },
  namespace: '/progress',
})
export class ProgressGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(ProgressGateway.name);
  private connectedUsers = new Map<string, string>(); // userId -> socketId

  constructor(
    private jwtService: JwtService,
    private progressService: ProgressService
  ) {}

  async handleConnection(client: Socket) {
    try {
      const token =
        client.handshake.auth.token ||
        client.handshake.headers.authorization?.replace('Bearer ', '');

      if (!token) {
        client.disconnect();
        return;
      }

      const payload = this.jwtService.verify(token);
      const userId = payload.sub;

      if (!userId) {
        client.disconnect();
        return;
      }

      // Store user connection
      this.connectedUsers.set(userId, client.id);
      client.data.userId = userId;

      // Join user to their personal room
      client.join(`user:${userId}`);

      this.logger.log(`User ${userId} connected to progress tracking`);
    } catch (error) {
      this.logger.error('Connection error:', error);
      client.disconnect();
    }
  }

  handleDisconnect(client: Socket) {
    const userId = client.data.userId;

    if (userId) {
      this.connectedUsers.delete(userId);
      this.logger.log(`User ${userId} disconnected from progress tracking`);
    }
  }

  @SubscribeMessage('join_course')
  async handleJoinCourse(
    @MessageBody() data: { courseId: string },
    @ConnectedSocket() client: Socket
  ) {
    try {
      const userId = client.data.userId;
      client.join(`course:${data.courseId}`);

      this.logger.log(`User ${userId} joined course ${data.courseId}`);
      return { success: true };
    } catch (error) {
      this.logger.error('Error joining course:', error);
      return { success: false, error: error.message };
    }
  }

  @SubscribeMessage('leave_course')
  async handleLeaveCourse(
    @MessageBody() data: { courseId: string },
    @ConnectedSocket() client: Socket
  ) {
    try {
      const userId = client.data.userId;
      client.leave(`course:${data.courseId}`);

      this.logger.log(`User ${userId} left course ${data.courseId}`);
      return { success: true };
    } catch (error) {
      this.logger.error('Error leaving course:', error);
      return { success: false, error: error.message };
    }
  }

  @SubscribeMessage('update_progress')
  async handleUpdateProgress(
    @MessageBody()
    data: {
      courseId: string;
      lessonId?: string;
      progress: number;
      status: string;
    },
    @ConnectedSocket() client: Socket
  ) {
    try {
      const userId = client.data.userId;

      // Update progress in database
      const progress = await this.progressService.updateOrCreate(
        userId,
        data.courseId,
        data.lessonId || null,
        {
          progress: data.progress,
          status: data.status as any,
        }
      );

      // Broadcast progress update to course room
      this.server.to(`course:${data.courseId}`).emit('progress_updated', {
        userId,
        courseId: data.courseId,
        lessonId: data.lessonId,
        progress: data.progress,
        status: data.status,
        timestamp: new Date(),
      });

      return { success: true, progress };
    } catch (error) {
      this.logger.error('Error updating progress:', error);
      return { success: false, error: error.message };
    }
  }

  @SubscribeMessage('lesson_started')
  async handleLessonStarted(
    @MessageBody() data: { courseId: string; lessonId: string },
    @ConnectedSocket() client: Socket
  ) {
    try {
      const userId = client.data.userId;

      // Broadcast lesson started to course room
      this.server.to(`course:${data.courseId}`).emit('lesson_started', {
        userId,
        courseId: data.courseId,
        lessonId: data.lessonId,
        timestamp: new Date(),
      });

      return { success: true };
    } catch (error) {
      this.logger.error('Error handling lesson started:', error);
      return { success: false, error: error.message };
    }
  }

  @SubscribeMessage('lesson_completed')
  async handleLessonCompleted(
    @MessageBody() data: { courseId: string; lessonId: string },
    @ConnectedSocket() client: Socket
  ) {
    try {
      const userId = client.data.userId;

      // Broadcast lesson completed to course room
      this.server.to(`course:${data.courseId}`).emit('lesson_completed', {
        userId,
        courseId: data.courseId,
        lessonId: data.lessonId,
        timestamp: new Date(),
      });

      return { success: true };
    } catch (error) {
      this.logger.error('Error handling lesson completed:', error);
      return { success: false, error: error.message };
    }
  }

  // Method to send progress update to specific user
  async sendProgressUpdate(userId: string, progressData: any) {
    const socketId = this.connectedUsers.get(userId);

    if (socketId) {
      this.server.to(socketId).emit('progress_update', progressData);
    }
  }

  // Method to broadcast progress update to course
  async broadcastCourseProgress(courseId: string, progressData: any) {
    this.server.to(`course:${courseId}`).emit('course_progress', progressData);
  }
}
