// filepath: c:\Users\gaell\Documents\Dev\plany\back\src\common\config\logger.config.ts
import { Logger } from '@nestjs/common';

export class LoggerConfig {
  static createLogger(): Logger {
    return new Logger();
  }

  static logInfo(message: string, context?: string): void {
    const logger = new Logger(context || 'Application');
    logger.log(message);
  }

  static logError(message: string, trace?: string, context?: string): void {
    const logger = new Logger(context || 'Application');
    logger.error(message, trace);
  }

  static logWarn(message: string, context?: string): void {
    const logger = new Logger(context || 'Application');
    logger.warn(message);
  }

  static logDebug(message: string, context?: string): void {
    const logger = new Logger(context || 'Application');
    logger.debug(message);
  }

  static logVerbose(message: string, context?: string): void {
    const logger = new Logger(context || 'Application');
    logger.verbose(message);
  }
}
