import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { InjectModel } from '@nestjs/mongoose';
import { User, UserDocument } from './schemas/user.schema';
import { Model, Connection, isValidObjectId } from 'mongoose';
import { InjectConnection } from '@nestjs/mongoose';
import { Plan, PlanDocument } from '../plan/schemas/plan.schema';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UserService {
  constructor(
    @InjectModel(User.name) private userModel: Model<UserDocument>,
    @InjectModel(Plan.name) private planModel: Model<PlanDocument>,
    @InjectConnection() private connection: Connection,
  ) {}

  // Vérifier si le mot de passe est sécurisé
  private isPasswordSecure(password: string): boolean {
    // Au moins 8 caractères, une majuscule, une minuscule et un chiffre
    const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/;
    return passwordRegex.test(password);
  }

  async create(createUserDto: CreateUserDto): Promise<UserDocument> {
    // Vérifier si le mot de passe est sécurisé
    if (!this.isPasswordSecure(createUserDto.password)) {
      throw new BadRequestException(
        'Le mot de passe doit contenir au moins 8 caractères, dont une majuscule, une minuscule et un chiffre',
      );
    }

    const createdUser = new this.userModel(createUserDto);
    return createdUser.save();
  }

  async findAll(): Promise<UserDocument[]> {
    return this.userModel.find().exec();
  }

  async findById(id: string): Promise<UserDocument | null> {
    if (!isValidObjectId(id)) {
      return null;
    }
    return this.userModel.findById(id).exec();
  }

  async findByEmail(email: string): Promise<UserDocument | null> {
    return this.userModel.findOne({ email }).exec();
  }

  async removeById(id: string): Promise<UserDocument | null> {
    return this.userModel.findByIdAndDelete(id).exec();
  }

  async findByUsername(username: string): Promise<UserDocument | null> {
    return this.userModel.findOne({ username }).exec();
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

    // Si le mot de passe est mis à jour, on le hache
    if (updateUserDto.password) {
      updateUserDto.password = await bcrypt.hash(updateUserDto.password, 12);
    }

    const updatedUser = await this.userModel
      .findByIdAndUpdate(id, { $set: updateUserDto }, { new: true })
      .exec();

    if (!updatedUser) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }

    return updatedUser;
  }

  async getUserPlans(userId: string) {
    const user = await this.findById(userId);
    if (!user) {
      throw new NotFoundException(`User with ID ${userId} not found`);
    }

    return this.planModel
      .find({ userId: user.id })
      .sort({ createdAt: -1 })
      .exec();
  }

  async getUserFavorites(userId: string) {
    const user = await this.findById(userId);
    if (!user) {
      throw new NotFoundException(`User with ID ${userId} not found`);
    }

    return this.planModel
      .find({ favorites: user.id })
      .sort({ createdAt: -1 })
      .exec();
  }

  async getPremiumStatus(userId: string): Promise<boolean> {
    const user = await this.findById(userId);
    return user?.isPremium || false;
  }

  async followUser(followerId: string, targetUserId: string) {
    const followerExists = await this.userModel.exists({
      _id: followerId,
    });
    const targetExists = await this.userModel.exists({
      _id: targetUserId,
    });

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

    return { message: 'Abonnement réussi', success: true };
  }

  async unfollowUser(followerId: string, targetUserId: string) {
    const followerExists = await this.userModel.exists({
      _id: followerId,
    });
    const targetExists = await this.userModel.exists({
      _id: targetUserId,
    });

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

    return { message: 'Désabonnement réussi', success: true };
  }

  async getUserFollowers(userId: string): Promise<any[]> {
    const populatedUser = await this.userModel
      .findById(userId)
      .populate('followers', 'username email photoUrl')
      .exec();

    if (!populatedUser) {
      return [];
    }

    return populatedUser.followers;
  }

  async getUserFollowing(userId: string) {
    const user = await this.userModel.findOne({ _id: userId });

    if (!user) {
      throw new NotFoundException(`Utilisateur ${userId} non trouvé`);
    }

    const followingUsers = await this.userModel
      .find({
        _id: { $in: user.following },
      })
      .select('username photoUrl isPremium followers following');

    const formattedUsers = followingUsers.map((user) => ({
      id: user._id,
      username: user.username,
      photoUrl: user.photoUrl,
      isPremium: user.isPremium || false,
      followersCount: user.followers?.length || 0,
      followingCount: user.following?.length || 0,
    }));

    return formattedUsers;
  }

  async checkIfFollowing(userId: string, targetId: string) {
    const follower = await this.findById(userId);
    const target = await this.findById(targetId);

    if (!follower || !target) {
      throw new NotFoundException('Utilisateur non trouvé');
    }

    const isFollowing = follower.following.some(
      (id) => id.toString() === (target._id as any).toString(),
    );

    return { isFollowing };
  }

  async getUserFollowersDetails(userId: string) {
    const user = await this.findById(userId);
    if (!user) {
      throw new NotFoundException(`Utilisateur avec ID ${userId} non trouvé`);
    }

    const followers = await this.userModel
      .find({ _id: { $in: user.followers } })
      .select('username photoUrl')
      .exec();

    return followers;
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
    const user = await this.findById(userId);
    if (!user) {
      throw new NotFoundException(`Utilisateur ${userId} non trouvé`);
    }

    const plansCount = await this.planModel.countDocuments({
      userId: userId,
    });

    const favoritesCount = await this.planModel.countDocuments({
      favorites: userId,
    });

    const followersCount = user.followers?.length || 0;
    const followingCount = user.following?.length || 0;

    return {
      plansCount,
      favoritesCount,
      followersCount,
      followingCount,
    };
  }

  async updateRefreshToken(
    userId: string,
    refreshToken: string | null,
  ): Promise<void> {
    await this.userModel.updateOne({ _id: userId }, { refreshToken }).exec();
  }
}
