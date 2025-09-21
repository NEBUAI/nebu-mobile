import { registerAs } from '@nestjs/config';

export default registerAs('cloudinary', () => ({
  cloudName: process.env.CLOUDINARY_CLOUD_NAME,
  apiKey: process.env.CLOUDINARY_API_KEY,
  apiSecret: process.env.CLOUDINARY_API_SECRET,
  secure: process.env.NODE_ENV === 'production',

  // Upload presets for different media types
  presets: {
    courses: process.env.CLOUDINARY_PRESET_COURSES || 'outliers_courses',
    videos: process.env.CLOUDINARY_PRESET_VIDEOS || 'outliers_videos',
    thumbnails: process.env.CLOUDINARY_PRESET_THUMBNAILS || 'outliers_thumbnails',
    materials: process.env.CLOUDINARY_PRESET_MATERIALS || 'outliers_materials',
    avatars: process.env.CLOUDINARY_PRESET_AVATARS || 'outliers_avatars',
    certificates: process.env.CLOUDINARY_PRESET_CERTIFICATES || 'outliers_certificates',
  },

  // Folder structure
  folders: {
    courses: 'outliers-academy/courses',
    videos: 'outliers-academy/videos',
    thumbnails: 'outliers-academy/thumbnails',
    materials: 'outliers-academy/materials',
    avatars: 'outliers-academy/avatars',
    certificates: 'outliers-academy/certificates',
  },

  // Transformation settings
  transformations: {
    thumbnail: {
      width: 300,
      height: 200,
      crop: 'fill',
      quality: 'auto',
      format: 'auto',
    },
    courseImage: {
      width: 800,
      height: 450,
      crop: 'fill',
      quality: 'auto',
      format: 'auto',
    },
    avatar: {
      width: 200,
      height: 200,
      crop: 'fill',
      gravity: 'face',
      quality: 'auto',
      format: 'auto',
    },
    videoThumbnail: {
      width: 640,
      height: 360,
      crop: 'fill',
      quality: 'auto',
      format: 'auto',
    },
  },
}));
