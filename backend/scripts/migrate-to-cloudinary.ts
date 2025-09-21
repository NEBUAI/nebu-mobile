import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';
import { CloudinaryService } from '../src/cloudinary/cloudinary.service';
import { Repository } from 'typeorm';
import { CourseMedia } from '../src/courses/entities/course-media.entity';
import { getRepositoryToken } from '@nestjs/typeorm';
import * as fs from 'fs/promises';
import * as path from 'path';

interface MigrationOptions {
  dryRun?: boolean;
  batchSize?: number;
  skipExisting?: boolean;
  folder?: string;
}

class CloudinaryMigration {
  private cloudinaryService: CloudinaryService;
  private courseMediaRepository: Repository<CourseMedia>;

  constructor(
    cloudinaryService: CloudinaryService,
    courseMediaRepository: Repository<CourseMedia>
  ) {
    this.cloudinaryService = cloudinaryService;
    this.courseMediaRepository = courseMediaRepository;
  }

  async migrate(options: MigrationOptions = {}) {
    const {
      dryRun = false,
      batchSize = 10,
      skipExisting = true,
      folder = 'outliers-academy/migrated'
    } = options;

    console.log('🚀 Starting Cloudinary migration...');
    console.log(`📁 Target folder: ${folder}`);
    console.log(`🔍 Dry run: ${dryRun}`);
    console.log(`📦 Batch size: ${batchSize}`);

    // Get all course media records
    const mediaRecords = await this.courseMediaRepository.find({
      where: {
        ...(skipExisting && { cdnUrl: null })
      },
      order: { createdAt: 'ASC' }
    });

    console.log(`📊 Found ${mediaRecords.length} media records to migrate`);

    if (mediaRecords.length === 0) {
      console.log('✅ No media records to migrate');
      return;
    }

    let successCount = 0;
    let errorCount = 0;
    const errors: Array<{ id: string; error: string }> = [];

    // Process in batches
    for (let i = 0; i < mediaRecords.length; i += batchSize) {
      const batch = mediaRecords.slice(i, i + batchSize);
      console.log(`\n📦 Processing batch ${Math.floor(i / batchSize) + 1}/${Math.ceil(mediaRecords.length / batchSize)}`);

      for (const media of batch) {
        try {
          console.log(`🔄 Migrating: ${media.originalName} (${media.id})`);

          if (dryRun) {
            console.log(`   📝 Would migrate to: ${folder}/${media.fileName}`);
            successCount++;
            continue;
          }

          // Check if file exists locally
          const localPath = path.join('./uploads', this.getFolderFromMediaType(media.mediaType), media.fileName);
          
          try {
            await fs.access(localPath);
          } catch {
            console.log(`   ⚠️  Local file not found: ${localPath}`);
            errorCount++;
            errors.push({ id: media.id, error: 'Local file not found' });
            continue;
          }

          // Read file
          const fileBuffer = await fs.readFile(localPath);
          const file = {
            buffer: fileBuffer,
            originalname: media.originalName,
            mimetype: media.mimeType,
            size: media.fileSize
          } as Express.Multer.File;

          // Upload to Cloudinary
          const cloudinaryResult = await this.cloudinaryService.uploadFile(file, {
            folder: `${folder}/${this.getFolderFromMediaType(media.mediaType)}`,
            tags: [
              `course:${media.courseId}`,
              ...(media.lessonId ? [`lesson:${media.lessonId}`] : []),
              'migrated'
            ],
            context: {
              courseId: media.courseId,
              ...(media.lessonId && { lessonId: media.lessonId }),
              migratedAt: new Date().toISOString()
            }
          });

          // Update database record
          media.filePath = cloudinaryResult.publicId;
          media.cdnUrl = cloudinaryResult.secureUrl;
          media.thumbnailUrl = this.generateThumbnailUrl(cloudinaryResult.publicId, media.mediaType);
          media.metadata = {
            ...media.metadata,
            cloudinaryId: cloudinaryResult.id,
            publicId: cloudinaryResult.publicId,
            format: cloudinaryResult.format,
            width: cloudinaryResult.width,
            height: cloudinaryResult.height,
            resourceType: cloudinaryResult.resourceType,
            migratedAt: new Date().toISOString()
          };

          await this.courseMediaRepository.save(media);

          console.log(`   ✅ Migrated successfully: ${cloudinaryResult.secureUrl}`);
          successCount++;

        } catch (error) {
          console.log(`   ❌ Migration failed: ${error.message}`);
          errorCount++;
          errors.push({ id: media.id, error: error.message });
        }
      }

      // Small delay between batches
      if (i + batchSize < mediaRecords.length) {
        await new Promise(resolve => setTimeout(resolve, 1000));
      }
    }

    // Print summary
    console.log('\n📊 Migration Summary:');
    console.log(`✅ Successfully migrated: ${successCount}`);
    console.log(`❌ Failed migrations: ${errorCount}`);
    console.log(`📊 Total processed: ${successCount + errorCount}`);

    if (errors.length > 0) {
      console.log('\n❌ Errors:');
      errors.forEach(({ id, error }) => {
        console.log(`   ${id}: ${error}`);
      });
    }

    if (!dryRun && successCount > 0) {
      console.log('\n🧹 Consider cleaning up local files after verification');
    }
  }

  private getFolderFromMediaType(mediaType: string): string {
    switch (mediaType) {
      case 'video':
        return 'videos';
      case 'image':
        return 'images';
      case 'thumbnail':
        return 'thumbnails';
      case 'document':
        return 'documents';
      case 'audio':
        return 'audio';
      default:
        return 'files';
    }
  }

  private generateThumbnailUrl(publicId: string, mediaType: string): string | null {
    if (mediaType === 'video') {
      return this.cloudinaryService.generateTransformationUrl(publicId, {
        width: 640,
        height: 360,
        crop: 'fill',
        quality: 'auto',
        format: 'auto'
      }, 'video');
    }
    return null;
  }
}

async function main() {
  const app = await NestFactory.createApplicationContext(AppModule);
  
  const cloudinaryService = app.get(CloudinaryService);
  const courseMediaRepository = app.get(getRepositoryToken(CourseMedia));

  const migration = new CloudinaryMigration(cloudinaryService, courseMediaRepository);

  // Parse command line arguments
  const args = process.argv.slice(2);
  const options: MigrationOptions = {
    dryRun: args.includes('--dry-run'),
    batchSize: parseInt(args.find(arg => arg.startsWith('--batch-size='))?.split('=')[1] || '10'),
    skipExisting: !args.includes('--include-existing'),
    folder: args.find(arg => arg.startsWith('--folder='))?.split('=')[1] || 'outliers-academy/migrated'
  };

  try {
    await migration.migrate(options);
  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  } finally {
    await app.close();
  }
}

if (require.main === module) {
  main();
}
