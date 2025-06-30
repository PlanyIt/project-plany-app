import { Injectable } from '@nestjs/common';
import {
  Counter,
  Histogram,
  Gauge,
  register,
  collectDefaultMetrics,
} from 'prom-client';

@Injectable()
export class MetricsService {
  private httpRequestsTotal: Counter<string>;
  private httpRequestDuration: Histogram<string>;
  private activeConnections: Gauge<string>;
  private usersTotal: Gauge<string>;
  private plansTotal: Gauge<string>;
  private commentsTotal: Gauge<string>;
  private authLoginAttempts: Counter<string>;
  private authLoginSuccess: Counter<string>;
  private authLoginFailed: Counter<string>;
  private rateLimitHits: Counter<string>;
  private plansByCategory: Gauge<string>;

  constructor() {
    // 1) On crée une Registry custom (ou on peut aussi utiliser la Registry par défaut via `register`)
    // 2) (Optionnel) collecter les métriques par défaut de Node.js
    collectDefaultMetrics();

    // Métriques HTTP
    this.httpRequestsTotal = new Counter({
      name: 'http_requests_total',
      help: 'Total number of HTTP requests',
      labelNames: ['method', 'route', 'status_code'],
    });

    this.httpRequestDuration = new Histogram({
      name: 'http_request_duration_ms',
      help: 'Duration of HTTP requests in ms',
      labelNames: ['method', 'route'],
      buckets: [0.1, 5, 15, 50, 100, 500, 1000],
    });

    this.activeConnections = new Gauge({
      name: 'active_connections',
      help: 'Number of active connections',
    });

    // Métriques métier
    this.usersTotal = new Gauge({
      name: 'users_total',
      help: 'Total number of users',
    });

    this.plansTotal = new Gauge({
      name: 'plans_total',
      help: 'Total number of plans',
    });

    this.commentsTotal = new Gauge({
      name: 'comments_total',
      help: 'Total number of comments',
    });

    this.plansByCategory = new Gauge({
      name: 'plans_by_category',
      help: 'Number of plans by category',
      labelNames: ['category'],
    });

    // Métriques d'authentification
    this.authLoginAttempts = new Counter({
      name: 'auth_login_attempts_total',
      help: 'Total number of login attempts',
    });

    this.authLoginSuccess = new Counter({
      name: 'auth_login_success_total',
      help: 'Total number of successful logins',
    });

    this.authLoginFailed = new Counter({
      name: 'auth_login_failed_total',
      help: 'Total number of failed logins',
    });

    // Métriques de rate limiting
    this.rateLimitHits = new Counter({
      name: 'rate_limit_hits_total',
      help: 'Total number of rate limit hits',
      labelNames: ['endpoint'],
    });

    // Enregistrer toutes les métriques
    register.registerMetric(this.httpRequestsTotal);
    register.registerMetric(this.httpRequestDuration);
    register.registerMetric(this.activeConnections);
    register.registerMetric(this.usersTotal);
    register.registerMetric(this.plansTotal);
    register.registerMetric(this.commentsTotal);
    register.registerMetric(this.authLoginAttempts);
    register.registerMetric(this.authLoginSuccess);
    register.registerMetric(this.authLoginFailed);
    register.registerMetric(this.rateLimitHits);
    register.registerMetric(this.plansByCategory);
  }

  // Méthodes pour HTTP
  incrementHttpRequests(method: string, route: string, statusCode: number) {
    this.httpRequestsTotal.inc({
      method,
      route,
      status_code: statusCode.toString(),
    });
  }

  observeHttpDuration(method: string, route: string, duration: number) {
    this.httpRequestDuration.observe({ method, route }, duration);
  }

  recordHttpRequestDuration(method: string, route: string, duration: number) {
    this.httpRequestDuration.observe({ method, route }, duration);
  }

  setActiveConnections(count: number) {
    this.activeConnections.set(count);
  }

  // Méthodes pour les métriques métier
  setUsersTotal(count: number) {
    this.usersTotal.set(count);
  }

  setPlansTotal(count: number) {
    this.plansTotal.set(count);
  }

  setCommentsTotal(count: number) {
    this.commentsTotal.set(count);
  }

  setPlansByCategory(category: string, count: number) {
    this.plansByCategory.set({ category }, count);
  }

  // Méthodes pour l'authentification
  incrementLoginAttempts() {
    this.authLoginAttempts.inc();
  }

  incrementLoginSuccess() {
    this.authLoginSuccess.inc();
  }

  incrementLoginFailed() {
    this.authLoginFailed.inc();
  }

  // Méthodes pour le rate limiting
  incrementRateLimitHits(endpoint: string) {
    this.rateLimitHits.inc({ endpoint });
  }

  async getMetrics(): Promise<string> {
    return await register.metrics();
  }

  // Méthode pour mettre à jour toutes les métriques métier
  async updateBusinessMetrics(
    usersCount: number,
    plansCount: number,
    commentsCount: number,
    plansByCategory: Record<string, number>,
  ) {
    this.setUsersTotal(usersCount);
    this.setPlansTotal(plansCount);
    this.setCommentsTotal(commentsCount);

    // Mettre à jour les plans par catégorie
    Object.entries(plansByCategory).forEach(([category, count]) => {
      this.setPlansByCategory(category, count);
    });
  }

  recordHttpRequest(
    method: string,
    route: string,
    statusCode: number,
    duration: number,
  ): void {
    // Enregistrer les métriques HTTP
    this.httpRequestsTotal.inc({
      method,
      route,
      status_code: statusCode.toString(),
    });

    this.httpRequestDuration.observe(
      {
        method,
        route,
      },
      duration,
    );
  }
}
