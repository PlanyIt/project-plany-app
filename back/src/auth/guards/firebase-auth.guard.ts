import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
} from '@nestjs/common';
import * as admin from 'firebase-admin';

@Injectable()
export class FirebaseAuthGuard implements CanActivate {
  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const authorization = request.headers['authorization'];

    if (!authorization) {
      throw new UnauthorizedException('No token provided');
    }

    const token = authorization.split(' ')[1];

    try {
      const decodedToken = await admin.auth().verifyIdToken(token);
      request.userId = decodedToken.uid; // Injecting userId into the request
      return true;
    } catch (error) {
      throw new UnauthorizedException('Invalid token', error);
    }
  }
}
