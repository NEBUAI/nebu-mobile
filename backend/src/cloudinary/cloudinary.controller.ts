import {
  Controller,
  Post,
  Get,
  Delete,
  Param,
  Body,
  UseInterceptors,
  UploadedFile,
  UploadedFiles,
  UseGuards,
  BadRequestException,
  ParseFilePipe,
  MaxFileSizeValidator,
  FileTypeValidator,
  Query,
  ParseIntPipe,
} from '@nestjs/common';
import { FileInterceptor, FilesInterceptor } from '@nestjs/platform-express';
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
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { UserRole } from '../users/entities/user.entity';
import {
  CloudinaryService,
  CloudinaryUploadResult,
  CloudinaryResource,
} from './cloudinary.service';

export class UploadFromUrlDto {
  url: string;
  folder?: string;
  preset?: string;
  publicId?: string;
  tags?: string[];
  context?: Record<string, string>;
}

export class UploadBase64Dto {
  data: string;
  mimeType: string;
  fileName: string;
  folder?: string;
  preset?: string;
  publicId?: string;
  tags?: string[];
  context?: Record<string, string>;
}

@ApiTags('Cloudinary Media')
@Controller('media')
@UseGuards(JwtAuthGuard)
export class CloudinaryController {
  constructor(private readonly cloudinaryService: CloudinaryService) {}

  @Post('upload/single')
  @UseInterceptors(FileInterceptor('file'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Upload a single file to Cloudinary' })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        file: {
          type: 'string',
          format: 'binary',
          description: 'File to upload',
        },
        folder: {
          type: 'string',
          description: 'Cloudinary folder path',
          example: 'outliers-academy/courses',
        },
        preset: {
          type: 'string',
          description: 'Upload preset name',
        },
        tags: {
          type: 'array',
          items: { type: 'string' },
          description: 'Tags for the uploaded file',
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'File uploaded successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        publicId: { type: 'string' },
        url: { type: 'string' },
        secureUrl: { type: 'string' },
        originalName: { type: 'string' },
        fileName: { type: 'string' },
        format: { type: 'string' },
        size: { type: 'number' },
        width: { type: 'number' },
        height: { type: 'number' },
        duration: { type: 'number' },
        resourceType: { type: 'string', enum: ['image', 'video', 'raw'] },
        folder: { type: 'string' },
        uploadedAt: { type: 'string', format: 'date-time' },
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid file or upload failed' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async uploadSingle(
    @UploadedFile(
      new ParseFilePipe({
        validators: [
          new MaxFileSizeValidator({ maxSize: 100 * 1024 * 1024 }), // 100MB
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
    @Body('folder') folder?: string,
    @Body('preset') preset?: string,
    @Body('tags') tags?: string[],
    @Body('context') context?: Record<string, string>
  ): Promise<CloudinaryUploadResult> {
    return this.cloudinaryService.uploadFile(file, {
      folder,
      preset,
      tags: tags || [`user:${user.id}`],
      context: context || { userId: user.id },
    });
  }

  @Post('upload/multiple')
  @UseInterceptors(FilesInterceptor('files', 10))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Upload multiple files to Cloudinary' })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        files: {
          type: 'array',
          items: {
            type: 'string',
            format: 'binary',
          },
          description: 'Files to upload (max 10)',
        },
        folder: {
          type: 'string',
          description: 'Cloudinary folder path',
        },
        preset: {
          type: 'string',
          description: 'Upload preset name',
        },
        tags: {
          type: 'array',
          items: { type: 'string' },
          description: 'Tags for the uploaded files',
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Files uploaded successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          publicId: { type: 'string' },
          url: { type: 'string' },
          secureUrl: { type: 'string' },
          originalName: { type: 'string' },
          fileName: { type: 'string' },
          format: { type: 'string' },
          size: { type: 'number' },
          width: { type: 'number' },
          height: { type: 'number' },
          duration: { type: 'number' },
          resourceType: { type: 'string', enum: ['image', 'video', 'raw'] },
          folder: { type: 'string' },
          uploadedAt: { type: 'string', format: 'date-time' },
        },
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid files or upload failed' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async uploadMultiple(
    @UploadedFiles(
      new ParseFilePipe({
        validators: [
          new MaxFileSizeValidator({ maxSize: 100 * 1024 * 1024 }), // 100MB per file
        ],
        fileIsRequired: true,
      })
    )
    files: Express.Multer.File[],
    @CurrentUser() user: any,
    @Body('folder') folder?: string,
    @Body('preset') preset?: string,
    @Body('tags') tags?: string[],
    @Body('context') context?: Record<string, string>
  ): Promise<CloudinaryUploadResult[]> {
    if (!files || files.length === 0) {
      throw new BadRequestException('No files provided');
    }

    return this.cloudinaryService.uploadMultipleFiles(files, {
      folder,
      preset,
      tags: tags || [`user:${user.id}`],
      context: context || { userId: user.id },
    });
  }

  @Post('upload/url')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Upload file from URL to Cloudinary' })
  @ApiBody({ type: UploadFromUrlDto })
  @ApiResponse({
    status: 201,
    description: 'File uploaded from URL successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        publicId: { type: 'string' },
        url: { type: 'string' },
        secureUrl: { type: 'string' },
        originalName: { type: 'string' },
        fileName: { type: 'string' },
        format: { type: 'string' },
        size: { type: 'number' },
        width: { type: 'number' },
        height: { type: 'number' },
        duration: { type: 'number' },
        resourceType: { type: 'string', enum: ['image', 'video', 'raw'] },
        folder: { type: 'string' },
        uploadedAt: { type: 'string', format: 'date-time' },
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid URL or upload failed' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async uploadFromUrl(
    @Body() uploadDto: UploadFromUrlDto,
    @CurrentUser() user: any
  ): Promise<CloudinaryUploadResult> {
    return this.cloudinaryService.uploadFile(uploadDto.url, {
      folder: uploadDto.folder,
      preset: uploadDto.preset,
      publicId: uploadDto.publicId,
      tags: [...(uploadDto.tags || []), `user:${user.id}`],
      context: { ...uploadDto.context, userId: user.id },
    });
  }

  @Post('upload/base64')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Upload file from base64 to Cloudinary' })
  @ApiBody({ type: UploadBase64Dto })
  @ApiResponse({
    status: 201,
    description: 'File uploaded from base64 successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        publicId: { type: 'string' },
        url: { type: 'string' },
        secureUrl: { type: 'string' },
        originalName: { type: 'string' },
        fileName: { type: 'string' },
        format: { type: 'string' },
        size: { type: 'number' },
        width: { type: 'number' },
        height: { type: 'number' },
        duration: { type: 'number' },
        resourceType: { type: 'string', enum: ['image', 'video', 'raw'] },
        folder: { type: 'string' },
        uploadedAt: { type: 'string', format: 'date-time' },
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid base64 data or upload failed' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async uploadFromBase64(
    @Body() uploadDto: UploadBase64Dto,
    @CurrentUser() user: any
  ): Promise<CloudinaryUploadResult> {
    const buffer = Buffer.from(uploadDto.data, 'base64');
    (buffer as any).mimetype = uploadDto.mimeType;
    (buffer as any).originalname = uploadDto.fileName;

    return this.cloudinaryService.uploadFile(buffer, {
      folder: uploadDto.folder,
      preset: uploadDto.preset,
      publicId: uploadDto.publicId,
      tags: [...(uploadDto.tags || []), `user:${user.id}`],
      context: { ...uploadDto.context, userId: user.id },
    });
  }

  @Post('upload/by-type/:type')
  @UseInterceptors(FileInterceptor('file'))
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'Upload file by media type (course, video, thumbnail, material, avatar, certificate)',
  })
  @ApiConsumes('multipart/form-data')
  @ApiParam({
    name: 'type',
    description: 'Media type',
    enum: ['course', 'video', 'thumbnail', 'material', 'avatar', 'certificate'],
  })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        file: {
          type: 'string',
          format: 'binary',
          description: 'File to upload',
        },
        tags: {
          type: 'array',
          items: { type: 'string' },
          description: 'Additional tags',
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
    description: 'File uploaded by type successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        publicId: { type: 'string' },
        url: { type: 'string' },
        secureUrl: { type: 'string' },
        originalName: { type: 'string' },
        fileName: { type: 'string' },
        format: { type: 'string' },
        size: { type: 'number' },
        width: { type: 'number' },
        height: { type: 'number' },
        duration: { type: 'number' },
        resourceType: { type: 'string', enum: ['image', 'video', 'raw'] },
        folder: { type: 'string' },
        uploadedAt: { type: 'string', format: 'date-time' },
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid file or type' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async uploadByType(
    @Param('type') type: 'course' | 'video' | 'thumbnail' | 'material' | 'avatar' | 'certificate',
    @UploadedFile(
      new ParseFilePipe({
        validators: [
          new MaxFileSizeValidator({ maxSize: 500 * 1024 * 1024 }), // 500MB for videos
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
    @Body('tags') tags?: string[],
    @Body('context') context?: Record<string, string>
  ): Promise<CloudinaryUploadResult> {
    return this.cloudinaryService.uploadByType(file, type, {
      tags: [...(tags || []), `user:${user.id}`],
      context: { ...context, userId: user.id },
    });
  }

  @Get('info/:publicId')
  @ApiOperation({ summary: 'Get file information from Cloudinary' })
  @ApiParam({
    name: 'publicId',
    description: 'Cloudinary public ID',
    example: 'outliers-academy/courses/sample-image',
  })
  @ApiQuery({
    name: 'resourceType',
    description: 'Resource type',
    enum: ['image', 'video', 'raw'],
    required: false,
  })
  @ApiResponse({
    status: 200,
    description: 'File information retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        publicId: { type: 'string' },
        url: { type: 'string' },
        secureUrl: { type: 'string' },
        format: { type: 'string' },
        size: { type: 'number' },
        width: { type: 'number' },
        height: { type: 'number' },
        duration: { type: 'number' },
        resourceType: { type: 'string', enum: ['image', 'video', 'raw'] },
        folder: { type: 'string' },
        createdAt: { type: 'string' },
        tags: { type: 'array', items: { type: 'string' } },
        context: { type: 'object' },
      },
    },
  })
  @ApiResponse({ status: 404, description: 'File not found' })
  async getFileInfo(
    @Param('publicId') publicId: string,
    @Query('resourceType') resourceType: 'image' | 'video' | 'raw' = 'image'
  ): Promise<CloudinaryResource> {
    return this.cloudinaryService.getFileInfo(publicId, resourceType);
  }

  @Get('list')
  @ApiOperation({ summary: 'List files in a folder' })
  @ApiQuery({
    name: 'folder',
    description: 'Folder path to list files from',
    example: 'outliers-academy/courses',
  })
  @ApiQuery({
    name: 'resourceType',
    description: 'Resource type',
    enum: ['image', 'video', 'raw'],
    required: false,
  })
  @ApiQuery({
    name: 'maxResults',
    description: 'Maximum number of results',
    required: false,
  })
  @ApiQuery({
    name: 'nextCursor',
    description: 'Pagination cursor',
    required: false,
  })
  @ApiResponse({
    status: 200,
    description: 'Files listed successfully',
    schema: {
      type: 'object',
      properties: {
        resources: {
          type: 'array',
          items: { $ref: '#/components/schemas/CloudinaryResource' },
        },
        nextCursor: { type: 'string' },
      },
    },
  })
  async listFiles(
    @Query('folder') folder: string,
    @Query('resourceType') resourceType: 'image' | 'video' | 'raw' = 'image',
    @Query('maxResults', new ParseIntPipe({ optional: true })) maxResults: number = 50,
    @Query('nextCursor') nextCursor?: string
  ) {
    return this.cloudinaryService.listFiles(folder, resourceType, maxResults, nextCursor);
  }

  @Get('search')
  @ApiOperation({ summary: 'Search files by query' })
  @ApiQuery({
    name: 'query',
    description: 'Search query (Cloudinary expression)',
    example: 'tags:course AND folder:outliers-academy/courses',
  })
  @ApiQuery({
    name: 'resourceType',
    description: 'Resource type',
    enum: ['image', 'video', 'raw'],
    required: false,
  })
  @ApiQuery({
    name: 'maxResults',
    description: 'Maximum number of results',
    required: false,
  })
  @ApiQuery({
    name: 'nextCursor',
    description: 'Pagination cursor',
    required: false,
  })
  @ApiResponse({
    status: 200,
    description: 'Files found successfully',
    schema: {
      type: 'object',
      properties: {
        resources: {
          type: 'array',
          items: { $ref: '#/components/schemas/CloudinaryResource' },
        },
        nextCursor: { type: 'string' },
      },
    },
  })
  async searchFiles(
    @Query('query') query: string,
    @Query('resourceType') resourceType: 'image' | 'video' | 'raw' = 'image',
    @Query('maxResults', new ParseIntPipe({ optional: true })) maxResults: number = 50,
    @Query('nextCursor') nextCursor?: string
  ) {
    return this.cloudinaryService.searchFiles(query, resourceType, maxResults, nextCursor);
  }

  @Get('transform/:publicId')
  @ApiOperation({ summary: 'Get transformation URLs for a file' })
  @ApiParam({
    name: 'publicId',
    description: 'Cloudinary public ID',
  })
  @ApiQuery({
    name: 'resourceType',
    description: 'Resource type',
    enum: ['image', 'video', 'raw'],
    required: false,
  })
  @ApiResponse({
    status: 200,
    description: 'Transformation URLs generated successfully',
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
  async getTransformationUrls(
    @Param('publicId') publicId: string,
    @Query('resourceType') resourceType: 'image' | 'video' | 'raw' = 'image'
  ) {
    return this.cloudinaryService.getTransformationUrls(publicId, resourceType);
  }

  @Delete(':publicId')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete a file from Cloudinary (admin/instructor only)' })
  @ApiParam({
    name: 'publicId',
    description: 'Cloudinary public ID to delete',
  })
  @ApiQuery({
    name: 'resourceType',
    description: 'Resource type',
    enum: ['image', 'video', 'raw'],
    required: false,
  })
  @ApiResponse({
    status: 200,
    description: 'File deleted successfully',
    schema: {
      type: 'object',
      properties: {
        message: { type: 'string' },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Insufficient permissions' })
  @ApiResponse({ status: 404, description: 'File not found' })
  async deleteFile(
    @Param('publicId') publicId: string,
    @Query('resourceType') resourceType: 'image' | 'video' | 'raw' = 'image'
  ): Promise<{ message: string }> {
    await this.cloudinaryService.deleteFile(publicId, resourceType);
    return { message: 'File deleted successfully' };
  }
}
