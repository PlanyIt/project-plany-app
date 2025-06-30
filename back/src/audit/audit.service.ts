import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { AuditLog, AuditLogDocument } from './schemas/audit-log.schema';

export interface AuditLogEntry {
  userId: string;
  action: string;
  resource: string;
  resourceId?: string;
  metadata?: Record<string, any>;
  ipAddress?: string;
  userAgent?: string;
  result?: 'success' | 'failure';
  errorMessage?: string;
}

@Injectable()
export class AuditService {
  constructor(
    @InjectModel(AuditLog.name)
    private auditLogModel: Model<AuditLogDocument>,
  ) {}

  async logAction(entry: AuditLogEntry): Promise<AuditLog> {
    const auditLog = new this.auditLogModel({
      ...entry,
      timestamp: new Date(),
    });
    return auditLog.save();
  }

  async getAuditLogs(
    userId?: string,
    resource?: string,
    action?: string,
    limit: number = 100,
    offset: number = 0,
  ): Promise<AuditLog[]> {
    const filter: any = {};
    if (userId) filter.userId = userId;
    if (resource) filter.resource = resource;
    if (action) filter.action = action;

    return this.auditLogModel
      .find(filter)
      .sort({ timestamp: -1 })
      .limit(limit)
      .skip(offset)
      .exec();
  }

  async getFailedActions(limit: number = 50): Promise<AuditLog[]> {
    return this.auditLogModel
      .find({ result: 'failure' })
      .sort({ timestamp: -1 })
      .limit(limit)
      .exec();
  }

  async deleteOldLogs(olderThanDays: number): Promise<number> {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - olderThanDays);

    const result = await this.auditLogModel.deleteMany({
      timestamp: { $lt: cutoffDate },
    });

    return result.deletedCount;
  }

  async getSecurityAlerts(limit: number = 100): Promise<AuditLog[]> {
    return this.auditLogModel
      .find({
        $or: [
          { result: 'failure' },
          { action: { $in: ['login', 'access_denied', 'permission_denied'] } },
        ],
      })
      .sort({ timestamp: -1 })
      .limit(limit)
      .exec();
  }

  async getAuditLogsByDateRange(
    startDate: Date,
    endDate: Date,
    userId?: string,
  ): Promise<AuditLog[]> {
    const filter: any = {
      timestamp: { $gte: startDate, $lte: endDate },
    };

    if (userId) {
      filter.userId = userId;
    }

    return this.auditLogModel.find(filter).sort({ timestamp: -1 }).exec();
  }

  async getUserActivitySummary(userId: string, days: number = 30) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const totalActions = await this.auditLogModel.countDocuments({
      userId,
      timestamp: { $gte: startDate },
    });

    const successfulActions = await this.auditLogModel.countDocuments({
      userId,
      result: 'success',
      timestamp: { $gte: startDate },
    });

    const failedActions = await this.auditLogModel.countDocuments({
      userId,
      result: 'failure',
      timestamp: { $gte: startDate },
    });

    const recentActions = await this.auditLogModel
      .find({ userId, timestamp: { $gte: startDate } })
      .sort({ timestamp: -1 })
      .limit(20)
      .exec();

    const actionsByResource = await this.auditLogModel.aggregate([
      {
        $match: {
          userId,
          timestamp: { $gte: startDate },
        },
      },
      {
        $group: {
          _id: '$resource',
          count: { $sum: 1 },
        },
      },
      {
        $sort: { count: -1 },
      },
    ]);

    return {
      userId,
      period: `${days} days`,
      summary: {
        totalActions,
        successfulActions,
        failedActions,
        successRate:
          totalActions > 0 ? (successfulActions / totalActions) * 100 : 0,
      },
      recentActions,
      actionsByResource,
    };
  }
}
