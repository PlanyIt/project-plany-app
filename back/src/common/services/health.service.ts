import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

export interface HealthStatus {
  status: 'healthy' | 'unhealthy' | 'degraded';
  timestamp: string;
  uptime: number;
  memory: {
    used: number;
    total: number;
    percentage: number;
  };
  database: {
    connected: boolean;
    responseTime?: number;
  };
  redis?: {
    connected: boolean;
    responseTime?: number;
  };
}

@Injectable()
export class HealthService {
  private readonly logger = new Logger(HealthService.name);
  private startTime = Date.now();

  constructor(private configService: ConfigService) {}

  async getHealthStatus(): Promise<HealthStatus> {
    const memoryUsage = process.memoryUsage();
    const uptime = Date.now() - this.startTime;

    const status: HealthStatus = {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      uptime,
      memory: {
        used: memoryUsage.heapUsed,
        total: memoryUsage.heapTotal,
        percentage: (memoryUsage.heapUsed / memoryUsage.heapTotal) * 100,
      },
      database: {
        connected: true, // TODO: Check actual database connection
      },
    };

    // Check if Redis is configured
    const redisUrl = this.configService.get<string>('REDIS_URL');
    if (redisUrl) {
      status.redis = {
        connected: true, // TODO: Check actual Redis connection
      };
    }

    // Determine overall status
    if (status.memory.percentage > 90) {
      status.status = 'degraded';
      this.logger.warn('High memory usage detected', {
        percentage: status.memory.percentage,
      });
    }

    if (
      !status.database.connected ||
      (status.redis && !status.redis.connected)
    ) {
      status.status = 'unhealthy';
      this.logger.error('Database or Redis connection issue');
    }

    return status;
  }

  async logMetrics(): Promise<void> {
    const health = await this.getHealthStatus();

    this.logger.log('Health check', {
      status: health.status,
      uptime: health.uptime,
      memoryUsage: health.memory.percentage,
      databaseConnected: health.database.connected,
      redisConnected: health.redis?.connected,
    });
  }
}
