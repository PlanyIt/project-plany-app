import { Injectable, Scope, ConsoleLogger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable({ scope: Scope.TRANSIENT })
export class AppLogger extends ConsoleLogger {
  constructor(private configService: ConfigService) {
    super();
  }

  log(message: any, context?: string) {
    super.log(message, context);
    this.writeToFile('info', message, context);
  }

  error(message: any, trace?: string, context?: string) {
    super.error(message, trace, context);
    this.writeToFile('error', message, context, trace);
  }

  warn(message: any, context?: string) {
    super.warn(message, context);
    this.writeToFile('warn', message, context);
  }

  debug(message: any, context?: string) {
    if (this.configService.get('NODE_ENV') !== 'production') {
      super.debug(message, context);
      this.writeToFile('debug', message, context);
    }
  }

  verbose(message: any, context?: string) {
    if (this.configService.get('NODE_ENV') !== 'production') {
      super.verbose(message, context);
      this.writeToFile('verbose', message, context);
    }
  }

  private writeToFile(
    level: string,
    message: any,
    context?: string,
    trace?: string,
  ) {
    const logEntry = {
      timestamp: new Date().toISOString(),
      level,
      context,
      message,
      trace,
      pid: process.pid,
      environment: this.configService.get('NODE_ENV'),
    };

    // In production, you might want to use winston or pino here
    if (this.configService.get('NODE_ENV') === 'production') {
      // Add your production logging logic here
      console.log(JSON.stringify(logEntry));
    }
  }
}
