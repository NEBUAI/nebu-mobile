const IS_DEV = process.env.APP_VARIANT === 'development';

export default {
  name: IS_DEV ? 'Nebu Mobile (Dev)' : 'Nebu Mobile',

  expo: {
    slug: 'nebu-mobile',
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
        'android.permission.ACCESS_NETWORK_STATE'
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
      "expo-font", // ← Agrega esto
      [
        'react-native-permissions',
        {
          bluetooth: 'when-in-use',
          location: 'when-in-use'
        }
      ]
    ],
    extra: {
      eas: {
        projectId: 'bd86ccea-c4fa-46f2-bcae-0c310774b80e'
      }
    },
    runtimeVersion: '1.0.0',
    updates: {
      url: 'https://u.expo.dev/bd86ccea-c4fa-46f2-bcae-0c310774b80e'
    }
  }
};