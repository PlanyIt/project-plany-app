import {
  Injectable,
  NotFoundException,
  BadRequestException,
  Inject,
} from '@nestjs/common';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { Cache } from 'cache-manager';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { InjectModel, InjectConnection } from '@nestjs/mongoose';
import { User, UserDocument } from './schemas/user.schema';
import { Plan, PlanDocument } from '../plan/schemas/plan.schema';
import { Comment, CommentDocument } from '../comment/schemas/comment.schema';
import { Model, Connection, isValidObjectId, Types } from 'mongoose';
import { PasswordService } from '../auth/password.service';

/**
 * Service de gestion des utilisateurs
 *
 * Gère les opérations CRUD sur les utilisateurs, les relations sociales
 * (followers/following) et les statistiques utilisateur.
 *
 * @author Équipe Plany
 * @version 1.0.0
 */
@Injectable()
export class UserService {
  constructor(
    @InjectModel(User.name) private userModel: Model<UserDocument>,
    @InjectModel(Plan.name) private planModel: Model<PlanDocument>,
    @InjectModel(Comment.name) private commentModel: Model<CommentDocument>,
    @InjectConnection() private connection: Connection,
    private passwordService: PasswordService,
    @Inject(CACHE_MANAGER) private cacheManager: Cache,
  ) {}

  private get cache(): any {
    return this.cacheManager as any;
  }

  private async invalidateUserCache(userId: string) {
    await this.cache.del(`user:${userId}`);
    await this.cache.del(`user:${userId}:stats`);
    await this.cache.del(`user:${userId}:favorites`);
    await this.cache.del(`user:${userId}:followers`);
    await this.cache.del(`user:${userId}:following`);
  }

  private isPasswordSecure(password: string): boolean {
    const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/;
    return passwordRegex.test(password);
  }

  async create(createUserDto: CreateUserDto): Promise<UserDocument> {
    if (!this.isPasswordSecure(createUserDto.password)) {
      throw new BadRequestException(
        'Le mot de passe doit contenir au moins 8 caractères, dont une majuscule, une minuscule et un chiffre',
      );
    }

    try {
      const createdUser = new this.userModel(createUserDto);
      return await createdUser.save();
    } catch (error) {
      if (error.code === 11000) {
        const field = Object.keys(error.keyPattern)[0];
        if (field === 'email') {
          throw new BadRequestException('Cet email est déjà utilisé');
        } else if (field === 'username') {
          throw new BadRequestException("Ce nom d'utilisateur est déjà pris");
        }
        throw new BadRequestException('Cette valeur est déjà utilisée');
      }
      throw error;
    }
  }

  async findAll(): Promise<UserDocument[]> {
    return this.userModel.find().exec();
  }

  async findById(id: string): Promise<UserDocument | null> {
    if (!isValidObjectId(id)) {
      return null;
    }
    const cacheKey = `user:${id}`;
    const cached = await this.cache.get(cacheKey);
    if (cached) return cached;

    const user = await this.userModel.findById(id).exec();
    await this.cache.set(cacheKey, user, 30);
    return user;
  }

  async findOneByEmail(email: string): Promise<UserDocument | undefined> {
    const cacheKey = `user:email:${email}`;
    const cached = await this.cache.get(cacheKey);
    if (cached) return cached;
    const user = await this.userModel.findOne({ email }).exec();
    await this.cache.set(cacheKey, user, 30);
    return user;
  }

  async findOneByUsername(username: string): Promise<UserDocument | undefined> {
    const cacheKey = `user:username:${username}`;
    const cached = await this.cache.get(cacheKey);
    if (cached) return cached;
    const user = await this.userModel.findOne({ username }).exec();
    await this.cache.set(cacheKey, user, 30);
    return user;
  }

  async removeById(id: string): Promise<UserDocument> {
    const session = await this.connection.startSession();

    try {
      return await session.withTransaction(async () => {
        const user = await this.userModel.findById(id).session(session);
        if (!user) {
          throw new NotFoundException(`User with ID ${id} not found`);
        }

        const userPlans = await this.planModel
          .find({ user: id })
          .session(session);
        const planIds = userPlans.map((plan) => plan._id);

        await this.commentModel
          .deleteMany({ planId: { $in: planIds } })
          .session(session);

        await this.planModel.deleteMany({ user: id }).session(session);
        await this.commentModel.deleteMany({ user: id }).session(session);
        await this.planModel
          .updateMany({ favorites: id }, { $pull: { favorites: id } })
          .session(session);

        await this.userModel
          .updateMany({ following: id }, { $pull: { following: id } })
          .session(session);
        await this.userModel
          .updateMany({ followers: id }, { $pull: { followers: id } })
          .session(session);

        const deletedUser = await this.userModel
          .findByIdAndDelete(id)
          .session(session)
          .exec();

        await this.invalidateUserCache(id);

        return deletedUser;
      });
    } finally {
      await session.endSession();
    }
  }

  async updateById(
    id: string,
    updateUserDto: UpdateUserDto,
  ): Promise<UserDocument> {
    if (updateUserDto.birthDate) {
      const parsedDate = new Date(updateUserDto.birthDate);
      updateUserDto.birthDate = new Date(
        Date.UTC(
          parsedDate.getUTCFullYear(),
          parsedDate.getUTCMonth(),
          parsedDate.getUTCDate(),
          12,
          0,
          0,
        ),
      );
    }

    if (updateUserDto.password) {
      updateUserDto.password = await this.passwordService.hashPassword(
        updateUserDto.password,
      );
    }

    const updatedUser = await this.userModel
      .findByIdAndUpdate(id, { $set: updateUserDto }, { new: true })
      .exec();

    if (!updatedUser) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }

    await this.invalidateUserCache(id);

    return updatedUser;
  }

  async getUserFavorites(userId: string) {
    const cacheKey = `user:${userId}:favorites`;
    const cached = await this.cache.get(cacheKey);
    if (cached) return cached;

    const user = await this.findById(userId);
    if (!user) {
      throw new NotFoundException(`User with ID ${userId} not found`);
    }

    const favorites = await this.planModel
      .find({ favorites: user.id })
      .sort({ createdAt: -1 })
      .exec();

    await this.cache.set(cacheKey, favorites, 30);
    return favorites;
  }

  async followUser(followerId: string, targetUserId: string) {
    const followerExists = await this.userModel.exists({ _id: followerId });
    const targetExists = await this.userModel.exists({ _id: targetUserId });

    if (!followerExists) {
      throw new NotFoundException(
        `Utilisateur avec ID ${followerId} non trouvé`,
      );
    }

    if (!targetExists) {
      throw new NotFoundException(
        `Utilisateur cible avec ID ${targetUserId} non trouvé`,
      );
    }

    const alreadyFollowing = await this.userModel.exists({
      _id: followerId,
      following: targetUserId,
    });

    if (alreadyFollowing) {
      return { message: 'Vous suivez déjà cet utilisateur', success: false };
    }

    await this.userModel.updateOne(
      { _id: followerId },
      { $addToSet: { following: targetUserId } },
    );
    await this.userModel.updateOne(
      { _id: targetUserId },
      { $addToSet: { followers: followerId } },
    );

    await this.invalidateUserCache(followerId);
    await this.invalidateUserCache(targetUserId);

    return { message: 'Abonnement réussi', success: true };
  }

  async unfollowUser(followerId: string, targetUserId: string) {
    const followerExists = await this.userModel.exists({ _id: followerId });
    const targetExists = await this.userModel.exists({ _id: targetUserId });

    if (!followerExists) {
      throw new NotFoundException(
        `Utilisateur avec ID ${followerId} non trouvé`,
      );
    }

    if (!targetExists) {
      throw new NotFoundException(
        `Utilisateur cible avec ID ${targetUserId} non trouvé`,
      );
    }

    await this.userModel.updateOne(
      { _id: followerId },
      { $pull: { following: targetUserId } },
    );
    await this.userModel.updateOne(
      { _id: targetUserId },
      { $pull: { followers: followerId } },
    );

    await this.invalidateUserCache(followerId);
    await this.invalidateUserCache(targetUserId);
    await this.cache.del(`user:${followerId}:stats`);
    await this.cache.del(`user:${targetUserId}:stats`);

    return { message: 'Désabonnement réussi', success: true };
  }

  async getUserFollowers(userId: string) {
    const cacheKey = `user:${userId}:followers`;
    const cached = await this.cache.get(cacheKey);
    if (cached) return cached;

    const user = await this.findById(userId);
    if (!user) {
      throw new NotFoundException(`Utilisateur avec ID ${userId} non trouvé`);
    }

    const populatedUser = await this.userModel
      .findById(user._id)
      .populate('followers', 'username email photoUrl followers')
      .exec();

    await this.cache.set(cacheKey, populatedUser.followers, 30);
    return populatedUser.followers;
  }

  async getUserFollowing(userId: string) {
    const cacheKey = `user:${userId}:following`;
    const cached = await this.cache.get(cacheKey);
    if (cached) return cached;

    const user = await this.userModel.findOne({ _id: userId });
    if (!user) {
      throw new NotFoundException(`Utilisateur ${userId} non trouvé`);
    }
    const populatedUser = await this.userModel
      .findById(user._id)
      .populate('following', 'username email photoUrl following followers')
      .exec();

    await this.cache.set(cacheKey, populatedUser.following, 30);
    return populatedUser.following;
  }

  async isFollowing(followerId: string, targetId: string): Promise<boolean> {
    const followerUser = await this.userModel
      .findOne({
        _id: followerId,
        following: targetId,
      })
      .exec();
    return followerUser !== null;
  }

  async getUserStats(userId: string) {
    const cacheKey = `user:${userId}:stats`;
    const cached = await this.cache.get(cacheKey);
    if (cached) return cached;

    const user = await this.findById(userId);
    if (!user) {
      throw new NotFoundException(`Utilisateur ${userId} non trouvé`);
    }
    const userObjectId = new Types.ObjectId(userId);
    const plansCount = await this.planModel.countDocuments({
      user: userObjectId,
    });
    const favoritesCount = await this.planModel.countDocuments({
      favorites: userObjectId,
    });
    const followersCount = user.followers?.length || 0;
    const followingCount = user.following?.length || 0;

    const stats = {
      plansCount,
      favoritesCount,
      followersCount,
      followingCount,
    };
    await this.cache.set(cacheKey, stats, 30);
    return stats;
  }
}
