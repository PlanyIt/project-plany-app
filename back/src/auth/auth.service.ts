import { Injectable, Inject, UnauthorizedException } from '@nestjs/common';
import * as admin from 'firebase-admin';

@Injectable()
export class AuthService {
  constructor(
    @Inject('FIREBASE_ADMIN') private readonly firebaseAdmin: admin.app.App,
  ) {}

  async verifyToken(token: string): Promise<string> {
    try {
      const decodedToken = await this.firebaseAdmin.auth().verifyIdToken(token);
      return decodedToken.uid;
    } catch (error) {
      throw new UnauthorizedException(error.message);
    }
  }
}
