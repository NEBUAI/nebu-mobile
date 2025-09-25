// Environment configuration
export const ENV_CONFIG = {
  // LiveKit Configuration
  LIVEKIT_URL: process.env.LIVEKIT_URL || '',
  LIVEKIT_API_KEY: process.env.LIVEKIT_API_KEY || '',
  LIVEKIT_SECRET_KEY: process.env.LIVEKIT_SECRET_KEY || '',
  
  // Backend API Configuration
  API_BASE_URL: process.env.API_BASE_URL || 'http://localhost:3000',
  
  // Social Auth Configuration
  GOOGLE_CLIENT_ID: process.env.GOOGLE_CLIENT_ID || '', // Android Client ID
  GOOGLE_WEB_CLIENT_ID: process.env.GOOGLE_WEB_CLIENT_ID || '', // Web Client ID (para server)
  FACEBOOK_APP_ID: process.env.FACEBOOK_APP_ID || '',
  FACEBOOK_CLIENT_TOKEN: process.env.FACEBOOK_CLIENT_TOKEN || '',
  APPLE_CLIENT_ID: process.env.APPLE_CLIENT_ID || '',
  APPLE_TEAM_ID: process.env.APPLE_TEAM_ID || '',
  APPLE_KEY_ID: process.env.APPLE_KEY_ID || '',
};
