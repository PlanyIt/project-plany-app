# Rate Limiting Implementation

Ce projet utilise un système de rate limiting personnalisé pour protéger l'API contre les abus et les attaques par déni de service.

## Configuration

La configuration se trouve dans `src/common/config/rate-limit.config.ts` :

- **Global** : 100 requêtes par minute par IP
- **Authentification** : 5 tentatives par minute
- **Opérations sensibles** : 10 requêtes par minute
- **Uploads** : 20 uploads par 5 minutes

## Utilisation

### 1. Middleware global

Le middleware `RateLimitMiddleware` est appliqué globalement et ajoute les headers suivants :

- `X-RateLimit-Limit` : Limite maximale
- `X-RateLimit-Remaining` : Requêtes restantes
- `X-RateLimit-Reset` : Heure de réinitialisation

### 2. Décorateurs pour contrôleurs spécifiques

```typescript
import {
  AuthThrottle,
  StrictThrottle,
  ApiThrottle,
} from '../common/decorators/throttle.decorator';

@Controller('auth')
export class AuthController {
  @Post('login')
  @AuthThrottle() // 5 requêtes par minute
  async login() {}

  @Post('sensitive-operation')
  @StrictThrottle() // 10 requêtes par minute
  async sensitiveOperation() {}
}
```

### 3. Guard personnalisé

Utilisez `ThrottleGuard` pour des contrôles plus fins :

```typescript
@UseGuards(ThrottleGuard)
export class MyController {}
```

## Réponses d'erreur

Quand la limite est dépassée, l'API retourne :

- Status Code : `429 Too Many Requests`
- Header `Retry-After` : Temps d'attente en secondes
- Message d'erreur explicite

## Monitoring

Les requêtes sont loggées avec :

- Timestamp
- IP client
- Méthode HTTP
- URL

## Variables d'environnement

```env
RATE_LIMIT_WINDOW_MS=60000    # Fenêtre de temps en ms
RATE_LIMIT_MAX_REQUESTS=100   # Nombre max de requêtes
```

## Sécurité

- Rate limiting basé sur l'IP client
- Support des proxies avec headers `X-Forwarded-For`
- Nettoyage automatique des anciennes entrées
- Headers de rate limiting standards
