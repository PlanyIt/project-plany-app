import {
  PipeTransform,
  Injectable,
  ArgumentMetadata,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { validate } from 'class-validator';
import { plainToInstance } from 'class-transformer';

@Injectable()
export class GlobalValidationPipe implements PipeTransform<any> {
  private readonly logger = new Logger(GlobalValidationPipe.name);

  async transform(value: any, { metatype }: ArgumentMetadata) {
    if (!metatype || !this.toValidate(metatype)) {
      return value;
    }

    try {
      const object = plainToInstance(metatype, value);
      const errors = await validate(object, {
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      });

      if (errors.length > 0) {
        const errorMessages = this.formatErrors(errors);
        this.logger.warn(`Validation failed: ${errorMessages.join(', ')}`);

        throw new BadRequestException({
          message: 'Données de validation invalides',
          errors: errorMessages,
          statusCode: 400,
        });
      }

      return object;
    } catch (error) {
      if (error instanceof BadRequestException) {
        throw error;
      }

      this.logger.error('Unexpected error during validation', error);
      throw new BadRequestException('Erreur de validation des données');
    }
  }

  private toValidate(metatype: new (...args: any[]) => any): boolean {
    const types: (new (...args: any[]) => any)[] = [
      String,
      Boolean,
      Number,
      Array,
      Object,
    ];
    return !types.includes(metatype);
  }

  private formatErrors(errors: any[]): string[] {
    const messages: string[] = [];

    for (const error of errors) {
      if (error.constraints) {
        messages.push(
          ...Object.values(error.constraints).map((msg) => String(msg)),
        );
      }

      if (error.children && error.children.length > 0) {
        messages.push(...this.formatErrors(error.children));
      }
    }

    return messages;
  }
}
