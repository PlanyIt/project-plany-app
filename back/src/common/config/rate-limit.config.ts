export const RATE_LIMIT_CONFIG = {
  // Configuration globale
  global: {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '60000'), // 1 minute
    maxRequests: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'), // Max 100 requêtes par minute par IP
  },

  // Configuration pour l'authentification
  auth: {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '60000'), // 1 minute
    maxRequests: parseInt(process.env.RATE_LIMIT_AUTH_MAX || '5'), // Max 5 tentatives de connexion par minute
  },

  // Configuration pour les opérations sensibles
  strict: {
    windowMs: 60000, // 1 minute
    maxRequests: 10, // Max 10 requêtes par minute
  },

  // Configuration pour l'API générale
  api: {
    windowMs: 60000, // 1 minute
    maxRequests: 100, // Max 100 requêtes par minute
  },

  // Configuration pour les uploads
  upload: {
    windowMs: 300000, // 5 minutes
    maxRequests: 20, // Max 20 uploads par 5 minutes
  },

  // Messages d'erreur
  messages: {
    tooManyRequests: 'Too many requests, please try again later.',
    authLimit: 'Too many authentication attempts, please try again later.',
    uploadLimit: 'Too many uploads, please wait before uploading again.',
  },
} as const;
