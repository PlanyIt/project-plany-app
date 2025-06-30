import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { RateLimitMiddleware } from './common/middleware/rate-limit.middleware';
import { GlobalExceptionFilter } from './common/filters/global-exception.filter';
import helmet from 'helmet';
import { Request, Response, NextFunction } from 'express';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: ['error', 'warn', 'log', 'debug', 'verbose'],
  });
  const configService = app.get(ConfigService);

  // Vérifier que les variables d'environnement essentielles sont définies
  const jwtSecret = configService.get<string>('JWT_SECRET');
  if (!jwtSecret) {
    console.error(
      'JWT_SECRET is not defined in environment variables. Application may not work properly.',
    );
    process.exit(1);
  } else {
    console.log('JWT_SECRET is properly configured.');
  }

  // Configuration de sécurité avancée avec helmet
  app.use(
    helmet({
      contentSecurityPolicy: {
        directives: {
          defaultSrc: ["'self'"],
          styleSrc: ["'self'", "'unsafe-inline'"],
          scriptSrc: ["'self'"],
          imgSrc: ["'self'", 'data:', 'https:'],
          connectSrc: ["'self'"],
          fontSrc: ["'self'"],
          objectSrc: ["'none'"],
          mediaSrc: ["'self'"],
          frameSrc: ["'none'"],
        },
      },
      crossOriginEmbedderPolicy: false,
      hsts: {
        maxAge: 31536000,
        includeSubDomains: true,
        preload: true,
      },
    }),
  );

  // Headers de sécurité additionnels
  app.use((req: Request, res: Response, next: NextFunction) => {
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('X-Frame-Options', 'DENY');
    res.setHeader('X-XSS-Protection', '1; mode=block');
    res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
    res.setHeader(
      'Permissions-Policy',
      'geolocation=(), microphone=(), camera=()',
    );
    next();
  });

  // Global exception filter
  app.useGlobalFilters(new GlobalExceptionFilter());

  // Rate limiting global
  const rateLimitMiddleware = new RateLimitMiddleware();
  app.use((req: Request, res: Response, next: NextFunction) =>
    rateLimitMiddleware.use(req, res, next),
  );

  // Validation des données entrantes avec transformation automatique
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // Supprime les champs inutiles
      forbidNonWhitelisted: true, // Retourne une erreur si un champ non autorisé est présent
      transform: true, // Transforme les paramètres de requête en objets DTO
      transformOptions: {
        enableImplicitConversion: true,
      },
      disableErrorMessages: process.env.NODE_ENV === 'production',
    }),
  );

  // Configuration CORS sécurisée
  const corsOrigin = configService.get<string>('CORS_ORIGIN');
  const corsCredentials =
    configService.get<string>('CORS_CREDENTIALS') === 'true';
  const corsMethods = configService.get<string>('CORS_METHODS')?.split(',') || [
    'GET',
    'POST',
    'PUT',
    'DELETE',
    'PATCH',
    'OPTIONS',
  ];
  const corsHeaders = configService
    .get<string>('CORS_ALLOWED_HEADERS')
    ?.split(',') || ['Content-Type', 'Authorization'];

  app.enableCors({
    origin: corsOrigin || ['http://localhost:3000', 'http://localhost:5173'],
    credentials: corsCredentials,
    methods: corsMethods,
    allowedHeaders: corsHeaders,
    maxAge: 86400, // 24 heures
  });

  // Configuration Swagger pour la documentation API
  if (process.env.NODE_ENV !== 'production') {
    const config = new DocumentBuilder()
      .setTitle('Plany API')
      .setDescription(
        `Documentation complète de l'API Plany pour la gestion de plans et tâches.
        
        ## 🔐 Authentification
        L'API utilise l'authentification JWT Bearer Token.
        
        ### Comment s'authentifier :
        1. **Connectez-vous** via l'endpoint \`POST /api/auth/login\` avec vos identifiants
        2. **Copiez l'accessToken** de la réponse
        3. **Cliquez sur le bouton "Authorize" 🔒** en haut à droite
        4. **Entrez** : \`votre_token_ici\` 
        5. **Cliquez sur "Authorize"** puis "Close"
        
        ✅ Tous vos appels d'API protégés utiliseront maintenant automatiquement ce token !
        
        ### Exemple de token :
        \`eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2NzQ5...\`
        
        ## 📊 Rate Limiting
        - Authentification: 5 requêtes/minute
        - API générale: 100 requêtes/minute
        - Opérations sensibles: 10 requêtes/minute
        
        ## 📈 Métriques & Monitoring
        - Métriques Prometheus : \`/metrics\`
        - Health Check : \`/health\`
        - Grafana Dashboard : http://localhost:3001`,
      )
      .setVersion('1.0')
      .setContact('Support Plany', 'https://plany.dev', 'support@plany.dev')
      .setLicense('MIT', 'https://opensource.org/licenses/MIT')
      .addServer('http://localhost:3000', 'Serveur de développement')
      .addServer('https://api.plany.dev', 'Serveur de production')
      .addBearerAuth(
        {
          description: `Please enter JWT token`,
          name: 'Authorization',
          bearerFormat: 'JWT',
          scheme: 'bearer',
          type: 'http',
          in: 'Header',
        },
        'JWT-auth',
      )
      .addTag(
        'Authentication',
        'Endpoints pour la connexion, inscription et gestion des tokens',
      )
      .addTag('Users', 'Gestion complète des utilisateurs et profils')
      .addTag('Plans', 'Création, modification et gestion des plans')
      .addTag('Steps', 'Gestion des étapes individuelles des plans')
      .addTag('Comments', 'Système de commentaires et interactions sociales')
      .addTag('Categories', 'Classification et organisation des plans')
      .addTag('Health', "Surveillance de la santé de l'API")
      .addTag(
        'Metrics',
        'Métriques détaillées pour le monitoring Prometheus/Grafana',
      )
      .build();

    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api/docs', app, document, {
      swaggerOptions: {
        persistAuthorization: true,
        displayRequestDuration: true,
        filter: true,
        showExtensions: true,
        showCommonExtensions: true,
        securityDefinitions: {
          'JWT-auth': {
            type: 'apiKey',
            in: 'header',
            name: 'Authorization',
            description: 'JWT Bearer token',
          },
        },
      },
    });

    console.log('Swagger documentation available at: /api/docs');
  }

  const port = configService.get<number>('PORT') || 3000;

  await app.listen(port);
  console.log(`Application is running on: ${await app.getUrl()}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
}

bootstrap().catch((error) => {
  console.error('Failed to start application:', error);
  process.exit(1);
});
