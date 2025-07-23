import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Cron, CronExpression } from '@nestjs/schedule';
import { User, UserDocument } from '../user/schemas/user.schema';
import {
  RefreshToken,
  RefreshTokenDocument,
} from '../auth/schemas/refresh-token.schema';

@Injectable()
export class RgpdCleanupService {
  private readonly logger = new Logger(RgpdCleanupService.name);

  constructor(
    @InjectModel(User.name) private userModel: Model<UserDocument>,
    @InjectModel(RefreshToken.name)
    private refreshTokenModel: Model<RefreshTokenDocument>,
  ) {}

  @Cron(CronExpression.EVERY_WEEK)
  async handleUserCleanup() {
    const threeYearsAgo = new Date();
    threeYearsAgo.setFullYear(threeYearsAgo.getFullYear() - 3);

    // Trouver les userId dont le dernier refresh token non révoqué date de plus de 3 ans
    const inactiveUserIds = await this.refreshTokenModel
      .aggregate([
        { $match: { revoked: false } },
        { $sort: { updatedAt: -1 } },
        {
          $group: {
            _id: '$userId',
            lastTokenDate: { $first: '$updatedAt' },
          },
        },
        { $match: { lastTokenDate: { $lt: threeYearsAgo } } },
        { $project: { _id: 1 } },
      ])
      .exec();

    const ids = inactiveUserIds.map((u) => u._id);

    if (ids.length > 0) {
      const result = await this.userModel.deleteMany({ _id: { $in: ids } });
      this.logger.log(
        `🧹 ${result.deletedCount} utilisateur(s) inactif(s) supprimé(s) (dernier refresh token > 3 ans)`,
      );
    }
  }
}
