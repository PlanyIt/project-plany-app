// Constants de sécurité pour l'authentification
export const SECURITY_CONSTANTS = {
  // JWT
  DEFAULT_JWT_EXPIRY: '15m',
  REFRESH_TOKEN_EXPIRY: '7d',

  // Rate limiting
  LOGIN_RATE_LIMIT: {
    ttl: 900, // 15 minutes
    limit: 5, // 5 tentatives max
  },

  // Password validation
  PASSWORD_MIN_LENGTH: 8,
  PASSWORD_REQUIREMENTS: {
    minLength: 8,
    requireUppercase: true,
    requireLowercase: true,
    requireNumbers: true,
    requireSpecialChars: true,
  },

  // Session security
  ARGON2_OPTIONS: {
    type: 2, // Argon2id
    memoryCost: 65536, // 64 MB
    timeCost: 3,
    parallelism: 4,
  },
} as const;

export const SECURITY_HEADERS = {
  'X-Content-Type-Options': 'nosniff',
  'X-Frame-Options': 'DENY',
  'X-XSS-Protection': '1; mode=block',
  'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
  'Referrer-Policy': 'strict-origin-when-cross-origin',
} as const;
