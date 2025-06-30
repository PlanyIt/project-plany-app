// Environment configuration with validation
export interface EnvironmentConfig {
  // Server
  PORT: number;
  NODE_ENV: 'development' | 'production' | 'test';

  // Database
  MONGO_URI: string;

  // Authentication
  JWT_SECRET: string;
  JWT_EXPIRES_IN: string;
  JWT_REFRESH_SECRET: string;
  JWT_REFRESH_EXPIRES_IN: string;

  // Cache/Redis
  REDIS_URL?: string;
  REDIS_HOST?: string;
  REDIS_PORT?: number;
  REDIS_PASSWORD?: string;

  // Security
  CORS_ORIGIN: string;
  CORS_CREDENTIALS: boolean;
  CORS_METHODS: string;
  CORS_ALLOWED_HEADERS: string;

  // Rate Limiting
  RATE_LIMIT_WINDOW_MS: number;
  RATE_LIMIT_MAX_REQUESTS: number;
  RATE_LIMIT_AUTH_MAX: number;

  // Logging
  LOG_LEVEL: 'error' | 'warn' | 'info' | 'debug' | 'verbose';
}

export const validateEnvironment = (
  config: Record<string, any>,
): EnvironmentConfig => {
  const errors: string[] = [];

  // Required variables
  const required = ['MONGO_URI', 'JWT_SECRET', 'JWT_REFRESH_SECRET'];
  for (const key of required) {
    if (!config[key]) {
      errors.push(`${key} is required`);
    }
  }

  // Validate format
  if (config.MONGO_URI && !config.MONGO_URI.startsWith('mongodb')) {
    errors.push('MONGO_URI must be a valid MongoDB connection string');
  }

  if (config.PORT && isNaN(Number(config.PORT))) {
    errors.push('PORT must be a number');
  }

  if (
    config.NODE_ENV &&
    !['development', 'production', 'test'].includes(config.NODE_ENV)
  ) {
    errors.push('NODE_ENV must be development, production, or test');
  }

  if (errors.length > 0) {
    throw new Error(`Environment validation failed: ${errors.join(', ')}`);
  }

  return {
    PORT: Number(config.PORT) || 3000,
    NODE_ENV: config.NODE_ENV || 'development',
    MONGO_URI: config.MONGO_URI,
    JWT_SECRET: config.JWT_SECRET,
    JWT_EXPIRES_IN: config.JWT_EXPIRES_IN || '15m',
    JWT_REFRESH_SECRET: config.JWT_REFRESH_SECRET,
    JWT_REFRESH_EXPIRES_IN: config.JWT_REFRESH_EXPIRES_IN || '7d',
    REDIS_URL: config.REDIS_URL,
    REDIS_HOST: config.REDIS_HOST,
    REDIS_PORT: Number(config.REDIS_PORT) || 6379,
    REDIS_PASSWORD: config.REDIS_PASSWORD,
    CORS_ORIGIN: config.CORS_ORIGIN || 'http://localhost:3000',
    CORS_CREDENTIALS: config.CORS_CREDENTIALS === 'true',
    CORS_METHODS: config.CORS_METHODS || 'GET,POST,PUT,DELETE,PATCH,OPTIONS',
    CORS_ALLOWED_HEADERS:
      config.CORS_ALLOWED_HEADERS || 'Content-Type,Authorization',
    RATE_LIMIT_WINDOW_MS: Number(config.RATE_LIMIT_WINDOW_MS) || 60000,
    RATE_LIMIT_MAX_REQUESTS: Number(config.RATE_LIMIT_MAX_REQUESTS) || 100,
    RATE_LIMIT_AUTH_MAX: Number(config.RATE_LIMIT_AUTH_MAX) || 5,
    LOG_LEVEL: config.LOG_LEVEL || 'info',
  };
};
