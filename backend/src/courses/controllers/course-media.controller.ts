import {
  Controller,
  Post,
  Get,
  Put,
  Delete,
  Param,
  Body,
  UseInterceptors,
  UploadedFile,
  UseGuards,
  ParseFilePipe,
  MaxFileSizeValidator,
  FileTypeValidator,
  Query,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiConsumes,
  ApiBody,
  ApiParam,
  ApiQuery,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { UserRole } from '../../users/entities/user.entity';
import {
  CourseMediaService,
  CreateCourseMediaDto,
  UpdateCourseMediaDto,
} from '../services/course-media.service';
import { MediaType } from '../entities/course-media.entity';

@ApiTags('Course Media')
@Controller('courses/:courseId/media')
@UseGuards(JwtAuthGuard)
export class CourseMediaController {
  constructor(private readonly courseMediaService: CourseMediaService) {}

  @Post()
  @UseInterceptors(FileInterceptor('file'))
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Upload media for a course' })
  @ApiConsumes('multipart/form-data')
  @ApiParam({
    name: 'courseId',
    description: 'Course ID',
  })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        file: {
          type: 'string',
          format: 'binary',
          description: 'Media file to upload',
        },
        mediaType: {
          type: 'string',
          enum: ['video', 'image', 'document', 'audio', 'thumbnail'],
          description: 'Type of media',
        },
        lessonId: {
          type: 'string',
          description: 'Lesson ID (optional)',
        },
        tags: {
          type: 'array',
          items: { type: 'string' },
          description: 'Tags for the media',
        },
        context: {
          type: 'object',
          description: 'Additional context metadata',
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Media uploaded successfully',
  })
  @ApiResponse({ status: 400, description: 'Invalid file or upload failed' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Insufficient permissions' })
  async uploadMedia(
    @Param('courseId') courseId: string,
    @UploadedFile(
      new ParseFilePipe({
        validators: [
          new MaxFileSizeValidator({ maxSize: 500 * 1024 * 1024 }), // 500MB
          new FileTypeValidator({
            fileType:
              /(jpg|jpeg|png|webp|gif|svg|mp4|webm|ogg|avi|mov|wmv|mp3|wav|pdf|doc|docx|ppt|pptx|txt|vtt|srt)$/,
          }),
        ],
        fileIsRequired: true,
      })
    )
    file: Express.Multer.File,
    @CurrentUser() user: any,
    @Body('mediaType') mediaType: MediaType,
    @Body('lessonId') lessonId?: string,
    @Body('tags') tags?: string[],
    @Body('context') context?: Record<string, string>
  ) {
    const createDto: CreateCourseMediaDto = {
      courseId,
      lessonId,
      mediaType,
      file,
      originalName: file.originalname,
      tags: [...(tags || []), `uploadedBy:${user.id}`],
      context: { ...context, uploadedBy: user.id },
    };

    return await this.courseMediaService.createMedia(createDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all media for a course' })
  @ApiParam({
    name: 'courseId',
    description: 'Course ID',
  })
  @ApiQuery({
    name: 'mediaType',
    description: 'Filter by media type',
    enum: ['video', 'image', 'document', 'audio', 'thumbnail'],
    required: false,
  })
  @ApiQuery({
    name: 'lessonId',
    description: 'Filter by lesson ID',
    required: false,
  })
  @ApiResponse({
    status: 200,
    description: 'Media list retrieved successfully',
  })
  async getCourseMedia(
    @Param('courseId') courseId: string,
    @Query('mediaType') mediaType?: MediaType,
    @Query('lessonId') lessonId?: string
  ) {
    if (lessonId) {
      return await this.courseMediaService.getMediaByLesson(lessonId);
    }

    if (mediaType) {
      return await this.courseMediaService.getMediaByType(mediaType, courseId);
    }

    return await this.courseMediaService.getMediaByCourse(courseId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get specific media by ID' })
  @ApiParam({
    name: 'courseId',
    description: 'Course ID',
  })
  @ApiParam({
    name: 'id',
    description: 'Media ID',
  })
  @ApiResponse({
    status: 200,
    description: 'Media retrieved successfully',
  })
  @ApiResponse({ status: 404, description: 'Media not found' })
  async getMediaById(@Param('courseId') courseId: string, @Param('id') id: string) {
    return await this.courseMediaService.getMediaById(id);
  }

  @Get(':id/transformations')
  @ApiOperation({ summary: 'Get transformation URLs for media' })
  @ApiParam({
    name: 'courseId',
    description: 'Course ID',
  })
  @ApiParam({
    name: 'id',
    description: 'Media ID',
  })
  @ApiResponse({
    status: 200,
    description: 'Transformation URLs retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        thumbnail: { type: 'string' },
        courseImage: { type: 'string' },
        avatar: { type: 'string' },
        videoThumbnail: { type: 'string' },
        original: { type: 'string' },
      },
    },
  })
  async getTransformationUrls(@Param('courseId') courseId: string, @Param('id') id: string) {
    return await this.courseMediaService.getTransformationUrls(id);
  }

  @Put(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update media metadata' })
  @ApiParam({
    name: 'courseId',
    description: 'Course ID',
  })
  @ApiParam({
    name: 'id',
    description: 'Media ID',
  })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        title: { type: 'string' },
        description: { type: 'string' },
        tags: { type: 'array', items: { type: 'string' } },
        context: { type: 'object' },
        isActive: { type: 'boolean' },
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Media updated successfully',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Insufficient permissions' })
  @ApiResponse({ status: 404, description: 'Media not found' })
  async updateMedia(
    @Param('courseId') courseId: string,
    @Param('id') id: string,
    @Body() updateDto: UpdateCourseMediaDto
  ) {
    return await this.courseMediaService.updateMedia(id, updateDto);
  }

  @Delete(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete media' })
  @ApiParam({
    name: 'courseId',
    description: 'Course ID',
  })
  @ApiParam({
    name: 'id',
    description: 'Media ID',
  })
  @ApiResponse({
    status: 200,
    description: 'Media deleted successfully',
    schema: {
      type: 'object',
      properties: {
        message: { type: 'string' },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Insufficient permissions' })
  @ApiResponse({ status: 404, description: 'Media not found' })
  async deleteMedia(
    @Param('courseId') courseId: string,
    @Param('id') id: string
  ): Promise<{ message: string }> {
    await this.courseMediaService.deleteMedia(id);
    return { message: 'Media deleted successfully' };
  }

  @Get('search')
  @ApiOperation({ summary: 'Search media' })
  @ApiParam({
    name: 'courseId',
    description: 'Course ID',
  })
  @ApiQuery({
    name: 'query',
    description: 'Search query',
  })
  @ApiResponse({
    status: 200,
    description: 'Search results retrieved successfully',
  })
  async searchMedia(@Param('courseId') courseId: string, @Query('query') query: string) {
    return await this.courseMediaService.searchMedia(query, courseId);
  }
}
