import { SetMetadata } from '@nestjs/common';

export const THROTTLE_KEY = 'throttle';

export interface ThrottleOptions {
  limit: number;
  ttl: number;
  skipIf?: (context: any) => boolean;
}

export const Throttle = (options: ThrottleOptions) =>
  SetMetadata(THROTTLE_KEY, options);

// Décorateurs prédéfinis pour différents endpoints
export const AuthThrottle = () => Throttle({ limit: 5, ttl: 60000 }); // 5 tentatives par minute pour l'auth
export const ApiThrottle = () => Throttle({ limit: 100, ttl: 60000 }); // 100 requêtes par minute pour l'API générale
export const StrictThrottle = () => Throttle({ limit: 10, ttl: 60000 }); // 10 requêtes par minute pour les opérations sensibles
export const UploadThrottle = () => Throttle({ limit: 20, ttl: 300000 }); // 20 uploads par 5 minutes
