import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CloudinaryService } from '../../cloudinary/cloudinary.service';
import { CourseMedia, MediaType, ProcessingStatus } from '../entities/course-media.entity';
import { Course } from '../entities/course.entity';
import { Lesson } from '../entities/lesson.entity';

export interface CreateCourseMediaDto {
  courseId: string;
  lessonId?: string;
  mediaType: MediaType;
  file: Express.Multer.File | Buffer | string;
  originalName: string;
  tags?: string[];
  context?: Record<string, string>;
}

export interface UpdateCourseMediaDto {
  fileName?: string;
  originalName?: string;
  tags?: string[];
  context?: Record<string, string>;
  metadata?: Record<string, any>;
}

@Injectable()
export class CourseMediaService {
  constructor(
    @InjectRepository(CourseMedia)
    private courseMediaRepository: Repository<CourseMedia>,
    @InjectRepository(Course)
    private courseRepository: Repository<Course>,
    @InjectRepository(Lesson)
    private lessonRepository: Repository<Lesson>,
    private cloudinaryService: CloudinaryService
  ) {}

  async createMedia(createDto: CreateCourseMediaDto): Promise<CourseMedia> {
    // Verify course exists
    const course = await this.courseRepository.findOne({
      where: { id: createDto.courseId },
    });
    if (!course) {
      throw new NotFoundException('Course not found');
    }

    // Verify lesson exists if provided
    if (createDto.lessonId) {
      const lesson = await this.lessonRepository.findOne({
        where: { id: createDto.lessonId, courseId: createDto.courseId },
      });
      if (!lesson) {
        throw new NotFoundException('Lesson not found or does not belong to course');
      }
    }

    try {
      // Upload to Cloudinary
      const cloudinaryResult = await this.cloudinaryService.uploadByType(
        createDto.file,
        this.mapMediaTypeToCloudinaryType(createDto.mediaType),
        {
          tags: [
            `course:${createDto.courseId}`,
            ...(createDto.lessonId ? [`lesson:${createDto.lessonId}`] : []),
            ...(createDto.tags || []),
          ],
          context: {
            courseId: createDto.courseId,
            ...(createDto.lessonId && { lessonId: createDto.lessonId }),
            ...createDto.context,
          },
        }
      );

      // Create database record
      const courseMedia = this.courseMediaRepository.create({
        courseId: createDto.courseId,
        lessonId: createDto.lessonId,
        mediaType: createDto.mediaType,
        fileName: cloudinaryResult.fileName,
        originalName: createDto.originalName,
        filePath: cloudinaryResult.publicId, // Store Cloudinary public ID
        cdnUrl: cloudinaryResult.secureUrl,
        fileSize: cloudinaryResult.size,
        mimeType: this.getMimeTypeFromFormat(cloudinaryResult.format),
        duration: cloudinaryResult.duration,
        thumbnailUrl: this.generateThumbnailUrl(cloudinaryResult.publicId, createDto.mediaType),
        isProcessed: true,
        processingStatus: ProcessingStatus.COMPLETED,
        metadata: {
          cloudinaryId: cloudinaryResult.id,
          publicId: cloudinaryResult.publicId,
          format: cloudinaryResult.format,
          width: cloudinaryResult.width,
          height: cloudinaryResult.height,
          resourceType: cloudinaryResult.resourceType,
          ...createDto.context,
        },
      });

      return await this.courseMediaRepository.save(courseMedia);
    } catch (error) {
      throw new BadRequestException(`Failed to create media: ${error.message}`);
    }
  }

  async updateMedia(id: string, updateDto: UpdateCourseMediaDto): Promise<CourseMedia> {
    const media = await this.courseMediaRepository.findOne({ where: { id } });
    if (!media) {
      throw new NotFoundException('Media not found');
    }

    // Update Cloudinary metadata if needed
    if (updateDto.tags || updateDto.context) {
      try {
        // Note: Cloudinary doesn't have a direct update API for tags/context
        // This would require re-uploading or using their admin API
        // Cloudinary metadata update not implemented yet
      } catch {
        // Failed to update Cloudinary metadata
      }
    }

    // Update database record
    Object.assign(media, updateDto);
    return await this.courseMediaRepository.save(media);
  }

  async deleteMedia(id: string): Promise<void> {
    const media = await this.courseMediaRepository.findOne({ where: { id } });
    if (!media) {
      throw new NotFoundException('Media not found');
    }

    try {
      // Delete from Cloudinary
      await this.cloudinaryService.deleteFile(
        media.filePath,
        this.mapMediaTypeToResourceType(media.mediaType)
      );
    } catch {
      // Failed to delete from Cloudinary
    }

    // Delete from database
    await this.courseMediaRepository.remove(media);
  }

  async getMediaById(id: string): Promise<CourseMedia> {
    const media = await this.courseMediaRepository.findOne({ where: { id } });
    if (!media) {
      throw new NotFoundException('Media not found');
    }
    return media;
  }

  async getMediaByCourse(courseId: string): Promise<CourseMedia[]> {
    return await this.courseMediaRepository.find({
      where: { courseId },
      order: { createdAt: 'DESC' },
    });
  }

  async getMediaByLesson(lessonId: string): Promise<CourseMedia[]> {
    return await this.courseMediaRepository.find({
      where: { lessonId },
      order: { createdAt: 'DESC' },
    });
  }

  async getMediaByType(mediaType: MediaType, courseId?: string): Promise<CourseMedia[]> {
    const where: any = { mediaType };
    if (courseId) {
      where.courseId = courseId;
    }

    return await this.courseMediaRepository.find({
      where,
      order: { createdAt: 'DESC' },
    });
  }

  async getTransformationUrls(id: string): Promise<Record<string, string>> {
    const media = await this.getMediaById(id);
    return this.cloudinaryService.getTransformationUrls(
      media.filePath,
      this.mapMediaTypeToResourceType(media.mediaType)
    );
  }

  async searchMedia(_query: string, _courseId?: string): Promise<CourseMedia[]> {
    // This would require implementing a search service that queries Cloudinary
    // and then fetches the corresponding database records
    // Media search not implemented yet
    return [];
  }

  private mapMediaTypeToCloudinaryType(
    mediaType: MediaType
  ): 'course' | 'video' | 'thumbnail' | 'material' | 'avatar' | 'certificate' {
    switch (mediaType) {
      case MediaType.VIDEO:
        return 'video';
      case MediaType.THUMBNAIL:
        return 'thumbnail';
      case MediaType.DOCUMENT:
        return 'material';
      case MediaType.IMAGE:
        return 'course';
      case MediaType.AUDIO:
        return 'material';
      default:
        return 'material';
    }
  }

  private mapMediaTypeToResourceType(mediaType: MediaType): 'image' | 'video' | 'raw' {
    switch (mediaType) {
      case MediaType.VIDEO:
        return 'video';
      case MediaType.IMAGE:
      case MediaType.THUMBNAIL:
        return 'image';
      case MediaType.DOCUMENT:
      case MediaType.AUDIO:
        return 'raw';
      default:
        return 'image';
    }
  }

  private getMimeTypeFromFormat(format: string): string {
    const mimeTypes: { [key: string]: string } = {
      jpg: 'image/jpeg',
      jpeg: 'image/jpeg',
      png: 'image/png',
      webp: 'image/webp',
      gif: 'image/gif',
      svg: 'image/svg+xml',
      mp4: 'video/mp4',
      webm: 'video/webm',
      ogg: 'video/ogg',
      avi: 'video/avi',
      mov: 'video/mov',
      wmv: 'video/wmv',
      mp3: 'audio/mpeg',
      wav: 'audio/wav',
      pdf: 'application/pdf',
      doc: 'application/msword',
      docx: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      ppt: 'application/vnd.ms-powerpoint',
      pptx: 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      txt: 'text/plain',
      vtt: 'text/vtt',
      srt: 'application/x-subrip',
    };

    return mimeTypes[format.toLowerCase()] || 'application/octet-stream';
  }

  private generateThumbnailUrl(publicId: string, mediaType: MediaType): string | null {
    if (mediaType === MediaType.VIDEO) {
      // For videos, generate a thumbnail URL
      return this.cloudinaryService.generateTransformationUrl(
        publicId,
        {
          width: 640,
          height: 360,
          crop: 'fill',
          quality: 'auto',
          format: 'auto',
        },
        'video'
      );
    }
    return null;
  }
}
