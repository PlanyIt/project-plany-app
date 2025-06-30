import { Controller, Get, Header } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { MetricsService } from './metrics.service';

@ApiTags('Metrics')
@Controller('metrics')
export class MetricsController {
  constructor(private readonly metricsService: MetricsService) {}

  @Get()
  @Header('Content-Type', 'text/plain')
  @ApiOperation({
    summary: 'Get Prometheus metrics',
    description:
      'Endpoint pour récupérer toutes les métriques au format Prometheus',
  })
  @ApiResponse({
    status: 200,
    description: 'Métriques récupérées avec succès',
    content: {
      'text/plain': {
        schema: {
          type: 'string',
          example: `# HELP http_requests_total Total number of HTTP requests
# TYPE http_requests_total counter
http_requests_total{method="GET",route="/api/plans",status_code="200"} 150

# HELP users_total Total number of users
# TYPE users_total gauge
users_total 1250

# HELP plans_total Total number of plans
# TYPE plans_total gauge
plans_total 850`,
        },
      },
    },
  })
  async getMetrics(): Promise<string> {
    return this.metricsService.getMetrics();
  }
}
