// src/firebase-admin.module.ts
import { Module, Global } from '@nestjs/common';
import * as admin from 'firebase-admin';

@Global()
@Module({
  providers: [
    {
      provide: 'FIREBASE_ADMIN',
      useFactory: () => {
        if (process.env.NODE_ENV === 'production') {
          // En production sur GCP
          return admin.initializeApp({
            credential: admin.credential.applicationDefault(),
          });
        } else {
          // En développement local ou autre environnement
          // eslint-disable-next-line @typescript-eslint/no-require-imports
          const serviceAccount = require('../../../../firebase-adminsdk.json');
          return admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
          });
        }
      },
    },
  ],
  exports: ['FIREBASE_ADMIN'],
})
export class FirebaseAdminModule {}
