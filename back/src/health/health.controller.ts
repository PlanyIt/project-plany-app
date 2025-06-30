import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import {
  HealthCheckService,
  HealthCheck,
  MongooseHealthIndicator,
  DiskHealthIndicator,
} from '@nestjs/terminus';

@Controller('health')
@ApiTags('Health')
export class HealthController {
  constructor(
    private health: HealthCheckService,
    private db: MongooseHealthIndicator,
    private disk: DiskHealthIndicator,
  ) {}

  @Get()
  @HealthCheck()
  @ApiOperation({
    summary: 'Health Check',
    description: 'Vérifie la santé globale de l\'application et de ses dépendances',
  })
  @ApiResponse({
    status: 200,
    description: 'Health check successful',
    schema: {
      example: {
        status: 'ok',
        info: {
          mongodb: {
            status: 'up',
          },
          disk: {
            status: 'up',
            free: '123456789',
            size: '987654321',
          },
        },
        error: {},
        details: {
          mongodb: {
            status: 'up',
          },
          disk: {
            status: 'up',
            free: '123456789',
            size: '987654321',
          },
        },
      },
    },
  })
  @ApiResponse({
    status: 503,
    description: 'Health check failed',
    schema: {
      example: {
        status: 'error',
        info: {},
        error: {
          mongodb: {
            status: 'down',
            message: 'Connection failed',
          },
        },
        details: {
          mongodb: {
            status: 'down',
            message: 'Connection failed',
          },
        },
      },
    },
  })
  check() {
    return this.health.check([
      () => this.db.pingCheck('database'),
      () =>
        this.disk.checkStorage('storage', {
          path: process.platform === 'win32' ? 'C:\\' : '/',
          thresholdPercent: 0.9,
        }),
    ]);
  }
}
