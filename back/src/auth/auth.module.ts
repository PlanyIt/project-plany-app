import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { FirebaseAdminModule } from 'src/firebase/firebase-admin.module';
import { FirebaseAuthGuard } from './guards/firebase-auth.guard';

@Module({
  imports: [FirebaseAdminModule], // Importation du module FirebaseAdmin
  providers: [AuthService, FirebaseAuthGuard],
  exports: [AuthService], // Exporte AuthService pour utilisation dans d'autres modules
})
export class AuthModule {}
