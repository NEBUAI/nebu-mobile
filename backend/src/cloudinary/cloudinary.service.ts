import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { v2 as cloudinary } from 'cloudinary';
import cloudinaryConfig from '../config/cloudinary.config';

export interface CloudinaryUploadResult {
  id: string;
  publicId: string;
  url: string;
  secureUrl: string;
  originalName: string;
  fileName: string;
  format: string;
  size: number;
  width?: number;
  height?: number;
  duration?: number;
  resourceType: 'image' | 'video' | 'raw';
  folder: string;
  uploadedAt: Date;
}

export interface CloudinaryUploadOptions {
  folder?: string;
  preset?: string;
  publicId?: string;
  overwrite?: boolean;
  resourceType?: 'image' | 'video' | 'raw' | 'auto';
  transformation?: any;
  tags?: string[];
  context?: Record<string, string>;
}

export interface CloudinaryResource {
  publicId: string;
  url: string;
  secureUrl: string;
  format: string;
  size: number;
  width?: number;
  height?: number;
  duration?: number;
  resourceType: 'image' | 'video' | 'raw';
  folder: string;
  createdAt: string;
  tags: string[];
  context: Record<string, string>;
}

@Injectable()
export class CloudinaryService {
  private cloudinaryConfig: ReturnType<typeof cloudinaryConfig>;

  constructor(private configService: ConfigService) {
    this.cloudinaryConfig =
      this.configService.get<ReturnType<typeof cloudinaryConfig>>('cloudinary');

    // Configure Cloudinary
    cloudinary.config({
      cloud_name: this.cloudinaryConfig.cloudName,
      api_key: this.cloudinaryConfig.apiKey,
      api_secret: this.cloudinaryConfig.apiSecret,
      secure: this.cloudinaryConfig.secure,
    });
  }

  /**
   * Upload a file to Cloudinary
   */
  async uploadFile(
    file: Express.Multer.File | Buffer | string,
    options: CloudinaryUploadOptions = {}
  ): Promise<CloudinaryUploadResult> {
    try {
      const uploadOptions = {
        folder: options.folder || this.cloudinaryConfig.folders.materials,
        upload_preset: options.preset,
        public_id: options.publicId,
        overwrite: options.overwrite || false,
        resource_type: options.resourceType || 'auto',
        transformation: options.transformation,
        tags: options.tags || [],
        context: options.context || {},
      };

      let uploadResult;

      if (Buffer.isBuffer(file)) {
        // Upload from buffer
        uploadResult = await cloudinary.uploader.upload(
          `data:${(file as any).mimetype || 'application/octet-stream'};base64,${file.toString('base64')}`,
          uploadOptions
        );
      } else if (typeof file === 'string') {
        // Upload from URL
        uploadResult = await cloudinary.uploader.upload(file, uploadOptions);
      } else {
        // Upload from Multer file
        uploadResult = await cloudinary.uploader.upload(
          `data:${file.mimetype};base64,${file.buffer.toString('base64')}`,
          uploadOptions
        );
      }

      return {
        id: uploadResult.asset_id,
        publicId: uploadResult.public_id,
        url: uploadResult.url,
        secureUrl: uploadResult.secure_url,
        originalName:
          file instanceof Object && 'originalname' in file ? file.originalname : 'unknown',
        fileName: uploadResult.original_filename || 'unknown',
        format: uploadResult.format,
        size: uploadResult.bytes,
        width: uploadResult.width,
        height: uploadResult.height,
        duration: uploadResult.duration,
        resourceType: uploadResult.resource_type,
        folder: uploadResult.folder || '',
        uploadedAt: new Date(uploadResult.created_at),
      };
    } catch (error) {
      throw new BadRequestException(`Error uploading file to Cloudinary: ${error.message}`);
    }
  }

  /**
   * Upload multiple files to Cloudinary
   */
  async uploadMultipleFiles(
    files: (Express.Multer.File | Buffer | string)[],
    options: CloudinaryUploadOptions = {}
  ): Promise<CloudinaryUploadResult[]> {
    const uploadPromises = files.map(file => this.uploadFile(file, options));
    return Promise.all(uploadPromises);
  }

  /**
   * Delete a file from Cloudinary
   */
  async deleteFile(
    publicId: string,
    resourceType: 'image' | 'video' | 'raw' = 'image'
  ): Promise<void> {
    try {
      const result = await cloudinary.uploader.destroy(publicId, {
        resource_type: resourceType,
      });

      if (result.result !== 'ok') {
        throw new NotFoundException(`File with public ID ${publicId} not found`);
      }
    } catch (error) {
      if (error instanceof NotFoundException) {
        throw error;
      }
      throw new BadRequestException(`Error deleting file from Cloudinary: ${error.message}`);
    }
  }

  /**
   * Get file information from Cloudinary
   */
  async getFileInfo(
    publicId: string,
    resourceType: 'image' | 'video' | 'raw' = 'image'
  ): Promise<CloudinaryResource> {
    try {
      const result = await cloudinary.api.resource(publicId, {
        resource_type: resourceType,
      });

      return {
        publicId: result.public_id,
        url: result.url,
        secureUrl: result.secure_url,
        format: result.format,
        size: result.bytes,
        width: result.width,
        height: result.height,
        duration: result.duration,
        resourceType: result.resource_type,
        folder: result.folder || '',
        createdAt: result.created_at,
        tags: result.tags || [],
        context: result.context || {},
      };
    } catch {
      throw new NotFoundException(`File with public ID ${publicId} not found`);
    }
  }

  /**
   * List files in a folder
   */
  async listFiles(
    folder: string,
    resourceType: 'image' | 'video' | 'raw' = 'image',
    maxResults: number = 50,
    nextCursor?: string
  ): Promise<{ resources: CloudinaryResource[]; nextCursor?: string }> {
    try {
      const result = await cloudinary.api.resources({
        type: 'upload',
        prefix: folder,
        resource_type: resourceType,
        max_results: maxResults,
        next_cursor: nextCursor,
      });

      const resources: CloudinaryResource[] = result.resources.map((resource: any) => ({
        publicId: resource.public_id,
        url: resource.url,
        secureUrl: resource.secure_url,
        format: resource.format,
        size: resource.bytes,
        width: resource.width,
        height: resource.height,
        duration: resource.duration,
        resourceType: resource.resource_type,
        folder: resource.folder || '',
        createdAt: resource.created_at,
        tags: resource.tags || [],
        context: resource.context || {},
      }));

      return {
        resources,
        nextCursor: result.next_cursor,
      };
    } catch (error) {
      throw new BadRequestException(`Error listing files from Cloudinary: ${error.message}`);
    }
  }

  /**
   * Search files by tags or context
   */
  async searchFiles(
    query: string,
    _resourceType: 'image' | 'video' | 'raw' = 'image',
    maxResults: number = 50,
    nextCursor?: string
  ): Promise<{ resources: CloudinaryResource[]; nextCursor?: string }> {
    try {
      const result = await cloudinary.search
        .expression(query)
        .max_results(maxResults)
        .next_cursor(nextCursor)
        .execute();

      const resources: CloudinaryResource[] = result.resources.map((resource: any) => ({
        publicId: resource.public_id,
        url: resource.url,
        secureUrl: resource.secure_url,
        format: resource.format,
        size: resource.bytes,
        width: resource.width,
        height: resource.height,
        duration: resource.duration,
        resourceType: resource.resource_type,
        folder: resource.folder || '',
        createdAt: resource.created_at,
        tags: resource.tags || [],
        context: resource.context || {},
      }));

      return {
        resources,
        nextCursor: result.next_cursor,
      };
    } catch (error) {
      throw new BadRequestException(`Error searching files in Cloudinary: ${error.message}`);
    }
  }

  /**
   * Generate transformation URL
   */
  generateTransformationUrl(
    publicId: string,
    transformation: any,
    resourceType: 'image' | 'video' | 'raw' = 'image'
  ): string {
    return cloudinary.url(publicId, {
      ...transformation,
      resource_type: resourceType,
    });
  }

  /**
   * Get predefined transformation URLs
   */
  getTransformationUrls(publicId: string, resourceType: 'image' | 'video' | 'raw' = 'image') {
    const transformations = this.cloudinaryConfig.transformations;

    return {
      thumbnail: this.generateTransformationUrl(publicId, transformations.thumbnail, resourceType),
      courseImage: this.generateTransformationUrl(
        publicId,
        transformations.courseImage,
        resourceType
      ),
      avatar: this.generateTransformationUrl(publicId, transformations.avatar, resourceType),
      videoThumbnail: this.generateTransformationUrl(
        publicId,
        transformations.videoThumbnail,
        resourceType
      ),
      original: this.generateTransformationUrl(publicId, {}, resourceType),
    };
  }

  /**
   * Upload with specific folder and preset based on media type
   */
  async uploadByType(
    file: Express.Multer.File | Buffer | string,
    mediaType: 'course' | 'video' | 'thumbnail' | 'material' | 'avatar' | 'certificate',
    options: Omit<CloudinaryUploadOptions, 'folder' | 'preset'> = {}
  ): Promise<CloudinaryUploadResult> {
    const folder =
      this.cloudinaryConfig.folders[
        (mediaType + 's') as keyof typeof this.cloudinaryConfig.folders
      ];
    const preset =
      this.cloudinaryConfig.presets[
        (mediaType + 's') as keyof typeof this.cloudinaryConfig.presets
      ];

    return this.uploadFile(file, {
      ...options,
      folder,
      preset,
    });
  }
}
