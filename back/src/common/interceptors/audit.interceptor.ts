import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Observable } from 'rxjs';
import { tap, catchError } from 'rxjs/operators';
import { throwError } from 'rxjs';
import { AuditService } from '../../audit/audit.service';
import { AUDIT_KEY, AuditOptions } from '../decorators/audit.decorator';

@Injectable()
export class AuditInterceptor implements NestInterceptor {
  constructor(
    private readonly auditService: AuditService,
    private readonly reflector: Reflector,
  ) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const auditOptions = this.reflector.get<AuditOptions>(
      AUDIT_KEY,
      context.getHandler(),
    );

    if (!auditOptions) {
      return next.handle();
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user) {
      return next.handle();
    }

    const metadata: any = {};

    if (auditOptions.includeParams) {
      metadata.params = request.params;
    }

    if (auditOptions.includeBody) {
      metadata.body = request.body;
    }

    const baseAuditEntry = {
      userId: user.userId || user.id,
      action: auditOptions.action,
      resource: auditOptions.resource,
      resourceId: request.params?.id,
      metadata,
      ipAddress: request.ip,
      userAgent: request.get('user-agent'),
    };

    return next.handle().pipe(
      tap(() => {
        // Log successful action
        this.auditService.logAction({
          ...baseAuditEntry,
          result: 'success',
        });
      }),
      catchError((error) => {
        // Log failed action
        this.auditService.logAction({
          ...baseAuditEntry,
          result: 'failure',
          errorMessage: error.message,
        });
        return throwError(error);
      }),
    );
  }
}
