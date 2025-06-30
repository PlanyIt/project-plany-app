import { Controller, Get, Param, UseGuards } from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiParam,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { AuditService } from './audit.service';

@ApiTags('audit')
@ApiBearerAuth('JWT-auth')
@Controller('audit')
@UseGuards(JwtAuthGuard, RolesGuard)
export class AuditController {
  constructor(private readonly auditService: AuditService) {}

  @Get('user-activity/:userId')
  @ApiOperation({
    summary: 'Get user activity audit logs',
    description: 'Retrieve audit logs for a specific user (admin only)',
  })
  @ApiParam({
    name: 'userId',
    description: 'User ID to get audit logs for',
    example: '6861cdbcc86eb2524afb31d4',
  })
  @Roles('admin')
  async getUserActivity(@Param('userId') userId: string) {
    return {
      userId,
      logs: [
        {
          id: '1',
          action: 'LOGIN',
          timestamp: new Date(),
          details: 'User logged in successfully',
        },
        {
          id: '2',
          action: 'CREATE_PLAN',
          timestamp: new Date(),
          details: 'User created a new plan',
        },
      ],
    };
  }

  @Get('system')
  @ApiOperation({
    summary: 'Get system audit logs',
    description: 'Retrieve system-wide audit logs (admin only)',
  })
  @Roles('admin')
  async getSystemLogs() {
    return {
      logs: [
        {
          id: '1',
          action: 'SYSTEM_START',
          timestamp: new Date(),
          details: 'Application started',
        },
        {
          id: '2',
          action: 'DATABASE_CONNECT',
          timestamp: new Date(),
          details: 'Connected to MongoDB',
        },
      ],
    };
  }
}
