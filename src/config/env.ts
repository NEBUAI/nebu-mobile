import Constants from 'expo-constants';
import { logger } from '@/utils/logger';

// Environment configuration from Expo Constants
export const ENV_CONFIG = {
  // Backend API Configuration
  URL_BACKEND: Constants.expoConfig?.extra?.URL_BACKEND || 'http://localhost:3000',

  // LiveKit Configuration
  LIVEKIT_URL: Constants.expoConfig?.extra?.LIVEKIT_URL || '',
  LIVEKIT_API_KEY: Constants.expoConfig?.extra?.LIVEKIT_API_KEY || '',
  LIVEKIT_API_SECRET: Constants.expoConfig?.extra?.LIVEKIT_API_SECRET || '',

  // Social Auth Configuration
  GOOGLE_CLIENT_ID: Constants.expoConfig?.extra?.GOOGLE_CLIENT_ID || '',
  GOOGLE_WEB_CLIENT_ID: Constants.expoConfig?.extra?.GOOGLE_WEB_CLIENT_ID || '',
  FACEBOOK_APP_ID: Constants.expoConfig?.extra?.FACEBOOK_APP_ID || '',
  FACEBOOK_CLIENT_TOKEN: Constants.expoConfig?.extra?.FACEBOOK_CLIENT_TOKEN || '',
  APPLE_CLIENT_ID: Constants.expoConfig?.extra?.APPLE_CLIENT_ID || '',
  APPLE_TEAM_ID: Constants.expoConfig?.extra?.APPLE_TEAM_ID || '',
  APPLE_KEY_ID: Constants.expoConfig?.extra?.APPLE_KEY_ID || '',
};

// Debug function to check env config
if (__DEV__) {
  logger.debug('🔧 Environment Config Debug:', ENV_CONFIG);
  logger.debug('🔧 ExpoConfig extra:', Constants.expoConfig?.extra);
  logger.debug('🔧 URL_BACKEND:', Constants.expoConfig?.extra?.URL_BACKEND);
}
