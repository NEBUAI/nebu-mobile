const IS_DEV = process.env.APP_VARIANT === 'development';

// Load environment variables
require('dotenv').config();

// Validate required environment variables
const validateEnv = () => {
  const requiredVars = ['URL_BACKEND', 'LIVEKIT_URL', 'LIVEKIT_API_KEY', 'LIVEKIT_API_SECRET'];
  const missing = requiredVars.filter(varName => !process.env[varName]);

  if (missing.length > 0 && IS_DEV) {
    console.warn('⚠️ Missing environment variables:', missing.join(', '));
  }
};

validateEnv();

export default {
  name: IS_DEV ? 'Nebu (Dev)' : 'Nebu',

  expo: {
    slug: 'Nebu',
    version: '1.0.0',
    cli: {
      appVersionSource: 'local'
    },
    orientation: 'portrait',
    icon: './assets/icon.png',
    userInterfaceStyle: 'automatic',
    splash: {
      image: './assets/splash.png',
      resizeMode: 'contain',
      backgroundColor: '#ffffff'
    },
    assetBundlePatterns: [
      '**/*'
    ],
    ios: {
      supportsTablet: true,
      bundleIdentifier: IS_DEV ? 'com.nebu.mobile.dev' : 'com.nebu.mobile',
      infoPlist: {
        NSBluetoothAlwaysUsageDescription: 'Esta aplicación necesita acceso a Bluetooth para conectarse con tu robot Nebu.',
        NSBluetoothPeripheralUsageDescription: 'Esta aplicación necesita acceso a Bluetooth para configurar tu robot Nebu.',
        NSLocationWhenInUseUsageDescription: 'Esta aplicación necesita acceso a la ubicación para escanear dispositivos Bluetooth cercanos.',
        NSLocationAlwaysAndWhenInUseUsageDescription: 'Esta aplicación necesita acceso a la ubicación para escanear dispositivos Bluetooth cercanos.',
        NSCameraUsageDescription: 'Esta aplicación necesita acceso a la cámara para escanear códigos QR de dispositivos.',
        UIBackgroundModes: ['bluetooth-central', 'bluetooth-peripheral'],
        UIRequiredDeviceCapabilities: ['armv7', 'bluetooth-le']
      }
    },
    android: {
      adaptiveIcon: {
        foregroundImage: './assets/adaptive-icon.png',
        backgroundColor: '#ffffff'
      },
      package: IS_DEV ? 'com.nebu.mobile.dev' : 'com.nebu.mobile',
      permissions: [
        'android.permission.BLUETOOTH',
        'android.permission.BLUETOOTH_ADMIN',
        'android.permission.BLUETOOTH_CONNECT',
        'android.permission.BLUETOOTH_SCAN',
        'android.permission.ACCESS_FINE_LOCATION',
        'android.permission.ACCESS_COARSE_LOCATION',
        'android.permission.INTERNET',
        'android.permission.ACCESS_NETWORK_STATE',
        'android.permission.CAMERA'
      ],
      usesFeatures: [
        {
          name: 'android.hardware.bluetooth_le',
          required: true
        },
        {
          name: 'android.hardware.bluetooth',
          required: true
        }
      ]
    },
    web: {
      favicon: './assets/favicon.png'
    },
    plugins: [
      "expo-font",
      "expo-camera",
      [
        'react-native-permissions',
        {
          bluetooth: 'when-in-use',
          location: 'when-in-use',
          camera: 'when-in-use'
        }
      ]
    ],
    extra: {
      eas: {
        projectId: 'bd86ccea-c4fa-46f2-bcae-0c310774b80e'
      },
      // Environment variables (usando nombres del .env)
      URL_BACKEND: process.env.URL_BACKEND || 'http://localhost:3000',
      LIVEKIT_URL: process.env.LIVEKIT_URL || '',
      LIVEKIT_API_KEY: process.env.LIVEKIT_API_KEY || '',
      LIVEKIT_API_SECRET: process.env.LIVEKIT_API_SECRET || '',
      GOOGLE_CLIENT_ID: process.env.GOOGLE_CLIENT_ID || '',
      GOOGLE_WEB_CLIENT_ID: process.env.GOOGLE_WEB_CLIENT_ID || '',
      FACEBOOK_APP_ID: process.env.FACEBOOK_APP_ID || '',
      FACEBOOK_CLIENT_TOKEN: process.env.FACEBOOK_CLIENT_TOKEN || '',
      APPLE_CLIENT_ID: process.env.APPLE_CLIENT_ID || '',
      APPLE_TEAM_ID: process.env.APPLE_TEAM_ID || '',
      APPLE_KEY_ID: process.env.APPLE_KEY_ID || '',
    },
    runtimeVersion: '1.0.0',
    updates: {
      url: 'https://u.expo.dev/bd86ccea-c4fa-46f2-bcae-0c310774b80e'
    }
  }
};