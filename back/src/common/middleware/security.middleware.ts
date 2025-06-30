import { Injectable, NestMiddleware, Logger } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { SECURITY_HEADERS } from '../constants/security.constants';

interface SecurityEvent {
  type: 'suspicious_request' | 'potential_attack' | 'blocked_ip';
  ip: string;
  userAgent: string;
  url: string;
  timestamp: Date;
  details?: any;
}

@Injectable()
export class SecurityMiddleware implements NestMiddleware {
  private readonly logger = new Logger(SecurityMiddleware.name);
  private readonly suspiciousIps = new Map<string, number>();
  private readonly blockedIps = new Set<string>();

  // Patterns de détection d'attaques
  private readonly maliciousPatterns = [
    /(\%27)|(\')|(\-\-)|(\%23)|(#)/i, // SQL Injection
    /(((\%3C)|<)((\%2F)|\/)*[a-z0-9\%]+((\%3E)|>))/i, // XSS
    /((\%3C)|<)((\%69)|i|(\%49))((\%6D)|m|(\%4D))((\%67)|g|(\%47))/i, // XSS img
    /\.\.\//i, // Path traversal
    /exec(\s|\+)+(s|x)p\w+/i, // Command injection
  ];

  use(req: Request, res: Response, next: NextFunction) {
    const ip = this.getClientIp(req);
    const userAgent = req.get('User-Agent') || '';
    const url = req.url;

    // Vérifier si l'IP est bloquée
    if (this.blockedIps.has(ip)) {
      this.logSecurityEvent({
        type: 'blocked_ip',
        ip,
        userAgent,
        url,
        timestamp: new Date(),
      });
      return res.status(403).json({ message: 'Accès interdit' });
    }

    // Analyser la requête pour détecter des patterns malveillants
    const isRequestSuspicious = this.analyzeRequest(req);

    if (isRequestSuspicious) {
      this.handleSuspiciousRequest(ip, userAgent, url);
    }

    // Ajouter des headers de sécurité
    Object.entries(SECURITY_HEADERS).forEach(([header, value]) => {
      res.setHeader(header, value);
    });

    // Supprimer les headers qui révèlent des informations sensibles
    res.removeHeader('X-Powered-By');
    res.removeHeader('Server');

    // Content Security Policy
    res.setHeader(
      'Content-Security-Policy',
      "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self'; frame-ancestors 'none';",
    );

    next();
  }

  private analyzeRequest(req: Request): boolean {
    const url = decodeURIComponent(req.url);
    const query = JSON.stringify(req.query);
    const body =
      typeof req.body === 'object' ? JSON.stringify(req.body) : req.body;

    // Vérifier l'URL, les paramètres et le body
    const content = `${url} ${query} ${body}`.toLowerCase();

    return this.maliciousPatterns.some((pattern) => pattern.test(content));
  }

  private handleSuspiciousRequest(ip: string, userAgent: string, url: string) {
    const count = this.suspiciousIps.get(ip) || 0;
    this.suspiciousIps.set(ip, count + 1);

    this.logSecurityEvent({
      type: 'suspicious_request',
      ip,
      userAgent,
      url,
      timestamp: new Date(),
      details: { attemptCount: count + 1 },
    });

    // Bloquer l'IP après 3 tentatives suspectes
    if (count >= 2) {
      this.blockedIps.add(ip);
      this.logSecurityEvent({
        type: 'potential_attack',
        ip,
        userAgent,
        url,
        timestamp: new Date(),
        details: { reason: 'Multiple suspicious requests' },
      });
    }
  }

  private logSecurityEvent(event: SecurityEvent) {
    this.logger.warn(`Security event: ${event.type}`, {
      ip: event.ip,
      userAgent: event.userAgent,
      url: event.url,
      timestamp: event.timestamp,
      details: event.details,
    });
  }

  private getClientIp(req: Request): string {
    return (
      (req.headers['x-forwarded-for'] as string)?.split(',')[0] ||
      (req.headers['x-real-ip'] as string) ||
      req.socket.remoteAddress ||
      'unknown'
    );
  }
}
