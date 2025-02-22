import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UserModule } from './user/user.module';
import { MongooseModule } from '@nestjs/mongoose';
import { ConfigModule } from '@nestjs/config';
import { PlanModule } from './plan/plan.module';
import { AuthModule } from './auth/auth.module';
import { FirebaseAdminModule } from './firebase/firebase-admin.module';
import { CommentModule } from './comment/comment.module';
import { StepModule } from './step/step.module';
import { CategoryModule } from './category/category.module';
import { TagModule } from './tag/tag.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    MongooseModule.forRoot(process.env.MONGO_URI),
    UserModule,
    PlanModule,
    AuthModule,
    CommentModule,
    FirebaseAdminModule,
    StepModule,
    CategoryModule,
    TagModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
