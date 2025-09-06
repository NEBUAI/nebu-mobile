const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

// Add support for TypeScript path mapping
config.resolver.alias = {
  '@': './src',
  '@/components': './src/components',
  '@/screens': './src/screens',
  '@/navigation': './src/navigation',
  '@/utils': './src/utils',
  '@/types': './src/types',
  '@/store': './src/store',
  '@/assets': './assets',
};

module.exports = config;
