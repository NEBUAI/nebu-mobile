import Constants from 'expo-constants';

// Environment configuration from Expo Constants
export const ENV_CONFIG = {
  // LiveKit Configuration
  LIVEKIT_URL: Constants.expoConfig?.extra?.LIVEKIT_URL || '',
  LIVEKIT_API_KEY: Constants.expoConfig?.extra?.LIVEKIT_API_KEY || '',
  LIVEKIT_SECRET_KEY: Constants.expoConfig?.extra?.LIVEKIT_SECRET_KEY || '',
  
  // Backend API Configuration  
  API_BASE_URL: Constants.expoConfig?.extra?.API_BASE_URL || 'http://localhost:3000',
  
  // Social Auth Configuration
  GOOGLE_CLIENT_ID: Constants.expoConfig?.extra?.GOOGLE_CLIENT_ID || '', // Android Client ID
  GOOGLE_WEB_CLIENT_ID: Constants.expoConfig?.extra?.GOOGLE_WEB_CLIENT_ID || '', // Web Client ID (para server)
  FACEBOOK_APP_ID: Constants.expoConfig?.extra?.FACEBOOK_APP_ID || '',
  FACEBOOK_CLIENT_TOKEN: Constants.expoConfig?.extra?.FACEBOOK_CLIENT_TOKEN || '',
  APPLE_CLIENT_ID: Constants.expoConfig?.extra?.APPLE_CLIENT_ID || '',
  APPLE_TEAM_ID: Constants.expoConfig?.extra?.APPLE_TEAM_ID || '',
  APPLE_KEY_ID: Constants.expoConfig?.extra?.APPLE_KEY_ID || '',
};

// Debug function to check env config
if (__DEV__) {
  console.log('🔧 Environment Config Debug:', ENV_CONFIG);
  console.log('🔧 ExpoConfig extra:', Constants.expoConfig?.extra);
  console.log('🔧 API_BASE_URL:', Constants.expoConfig?.extra?.API_BASE_URL);
}
