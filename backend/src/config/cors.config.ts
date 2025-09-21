// Localhost origins for hybrid development
const getLocalhostOrigins = () => {
  const allowLocalhost = process.env.ALLOW_LOCALHOST_CORS === 'true';
  
  if (!allowLocalhost) {
    return [];
  }
  
  return [
    'http://localhost:3000',
    'http://localhost:3001', 
    'http://localhost:3002',
    'http://localhost:3003',
    'http://127.0.0.1:3000',
    'http://127.0.0.1:3001',
    'http://127.0.0.1:3002',
    'http://127.0.0.1:3003',
  ];
};

export const corsConfig = {
  production: [
    process.env.FRONTEND_URL!,
    process.env.FRONTEND_URL?.replace('https://', 'https://www.'),
    'https://outliers.academy',
    'https://www.outliers.academy',
    'https://api.outliers.academy',
    ...getLocalhostOrigins(), // Conditionally add localhost origins
  ].filter(Boolean),
  development: [
    'http://localhost:3000',
    'http://localhost:3001',
    'http://localhost:3002',
    'http://localhost:3003',
    'http://127.0.0.1:3000',
    'http://127.0.0.1:3001',
    'http://127.0.0.1:3002',
    'http://127.0.0.1:3003',
    'https://outliers.academy',
    'http://outliers.academy',
    'https://www.outliers.academy',
    'http://www.outliers.academy',
  ]
};

// Localhost regex patterns for hybrid development
const getLocalhostRegexPatterns = () => {
  const allowLocalhost = process.env.ALLOW_LOCALHOST_CORS === 'true';
  
  if (!allowLocalhost) {
    return [];
  }
  
  return [
    /^https?:\/\/localhost(:[0-9]+)?$/,
    /^https?:\/\/127\.0\.0\.1(:[0-9]+)?$/,
  ];
};

export const corsRegexConfig = {
  production: [
    /^https:\/\/.*\.outliers\.academy$/,
    ...getLocalhostRegexPatterns(), // Conditionally add localhost patterns
  ],
  development: [
    /^https?:\/\/localhost(:[0-9]+)?$/,
    /^https?:\/\/127\.0\.0\.1(:[0-9]+)?$/,
    /^https?:\/\/.*\.localhost(:[0-9]+)?$/,
    /^https?:\/\/.*\.outliers\.academy$/,
    /^https?:\/\/outliers\.academy$/,
  ]
};

export function getCorsOrigins() {
  const env = process.env.NODE_ENV === 'production' ? 'production' : 'development';
  return corsConfig[env];
}

export function getCorsRegexOrigins() {
  const env = process.env.NODE_ENV === 'production' ? 'production' : 'development';
  return corsRegexConfig[env];
}
