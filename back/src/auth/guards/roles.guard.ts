import { Injectable, CanActivate, ExecutionContext, Logger } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES_KEY } from '../decorators/roles.decorator';

export enum UserRole {
  USER = 'user',
  ADMIN = 'admin',
}

@Injectable()
export class RolesGuard implements CanActivate {
  private readonly logger = new Logger(RolesGuard.name);

  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<UserRole[]>(
      ROLES_KEY,
      [context.getHandler(), context.getClass()],
    );

    if (!requiredRoles) {
      this.logger.debug('No roles required for this endpoint');
      return true;
    }

    const { user } = context.switchToHttp().getRequest();
    if (!user) {
      this.logger.warn('No user found in request');
      return false;
    }

    this.logger.debug('Required roles:', requiredRoles);
    this.logger.debug('User role:', user.role);
    this.logger.debug('User object:', user);

    const hasRole = requiredRoles.includes(user.role);
    this.logger.debug('Has required role:', hasRole);

    return hasRole;
  }
}
