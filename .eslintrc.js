module.exports = {
  extends: ['expo'],
  rules: {
    // Disable all import-related rules that are causing issues
    'import/no-unresolved': 'off',
    'import/namespace': 'off',
    'import/default': 'off',
    'import/no-named-as-default': 'off',
    'import/no-named-as-default-member': 'off',
    'import/export': 'off',

    // Disable TypeScript rules that are too strict or incompatible
    '@typescript-eslint/no-unused-vars': 'off',
    '@typescript-eslint/no-explicit-any': 'off',
    '@typescript-eslint/ban-ts-comment': 'off',
    '@typescript-eslint/no-empty-object-type': 'off',
    '@typescript-eslint/no-wrapper-object-types': 'off',

    // Disable React hooks rules for now
    'react-hooks/exhaustive-deps': 'off',
  },
  ignorePatterns: [
    'node_modules/',
    'dist/',
    'build/',
    '.expo/',
    '*.config.js',
    'metro.config.js',
    'babel.config.js',
  ],
};