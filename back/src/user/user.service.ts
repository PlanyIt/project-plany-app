import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { InjectModel } from '@nestjs/mongoose';
import { User, UserDocument } from './schemas/user.schema';
import { Model, Connection, isValidObjectId } from 'mongoose';
import { InjectConnection } from '@nestjs/mongoose';
import { Plan, PlanDocument } from '../plan/schemas/plan.schema';

@Injectable()
export class UserService {
  constructor(
    @InjectModel(User.name) private userModel: Model<UserDocument>,
    @InjectModel(Plan.name) private planModel: Model<PlanDocument>,
    @InjectConnection() private connection: Connection,
  ) {}

  async create(createUserDto: CreateUserDto): Promise<UserDocument> {
    const createdUser = new this.userModel(createUserDto);
    return createdUser.save();
  }

  async findAll(): Promise<UserDocument[]> {
    return this.userModel.find().exec();
  }

  async findOneByFirebaseUid(
    firebaseUid: string,
  ): Promise<UserDocument | undefined> {
    return this.userModel.findOne({ firebaseUid }).exec();
  }

  async removeByFirebaseUid(firebaseUid: string): Promise<UserDocument> {
    return this.userModel.findOneAndDelete({ firebaseUid }).exec();
  }

  async findOneByUsername(username: string): Promise<UserDocument | undefined> {
    return this.userModel.findOne({ username }).exec();
  }

  async findOneByEmail(email: string): Promise<UserDocument | undefined> {
    return this.userModel.findOne({ email }).exec();
  }

  async updateByFirebaseUid(
    firebaseUid: string,
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

    const updatedUser = await this.userModel
      .findOneAndUpdate({ firebaseUid }, { $set: updateUserDto }, { new: true })
      .exec();

    if (!updatedUser) {
      throw new NotFoundException(
        `User with Firebase UID ${firebaseUid} not found`,
      );
    }

    return updatedUser;
  }

  async getUserPlans(firebaseUid: string) {
    const user = await this.findOneByFirebaseUid(firebaseUid);
    if (!user) {
      throw new NotFoundException(
        `User with Firebase UID ${firebaseUid} not found`,
      );
    }

    return this.planModel
      .find({ userId: user.id })
      .sort({ createdAt: -1 })
      .exec();
  }

  async getUserFavorites(firebaseUid: string) {
    const user = await this.findOneByFirebaseUid(firebaseUid);
    if (!user) {
      throw new NotFoundException(
        `User with Firebase UID ${firebaseUid} not found`,
      );
    }

    return this.planModel
      .find({ favorites: user.id })
      .sort({ createdAt: -1 })
      .exec();
  }

  async getPremiumStatus(firebaseUid: string): Promise<boolean> {
    const user = await this.findOneByFirebaseUid(firebaseUid);
    return user?.isPremium || false;
  }

  async findById(id: string): Promise<UserDocument | null> {
    return this.userModel.findById(id).exec();
  }

  async followUser(followerId: string, targetUserId: string) {
    const followerExists = await this.userModel.exists({
      firebaseUid: followerId,
    });
    const targetExists = await this.userModel.exists({
      firebaseUid: targetUserId,
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
      firebaseUid: followerId,
      following: targetUserId,
    });

    if (alreadyFollowing) {
      return { message: 'Vous suivez déjà cet utilisateur', success: false };
    }

    await this.userModel.updateOne(
      { firebaseUid: followerId },
      { $addToSet: { following: targetUserId } },
    );

    await this.userModel.updateOne(
      { firebaseUid: targetUserId },
      { $addToSet: { followers: followerId } },
    );

    return { message: 'Abonnement réussi', success: true };
  }

  async unfollowUser(followerId: string, targetUserId: string) {
    const followerExists = await this.userModel.exists({
      firebaseUid: followerId,
    });
    const targetExists = await this.userModel.exists({
      firebaseUid: targetUserId,
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
      { firebaseUid: followerId },
      { $pull: { following: targetUserId } },
    );

    await this.userModel.updateOne(
      { firebaseUid: targetUserId },
      { $pull: { followers: followerId } },
    );

    return { message: 'Désabonnement réussi', success: true };
  }

  async getUserFollowers(userId: string) {
    let user;

    if (isValidObjectId(userId)) {
      user = await this.findById(userId);
    } else {
      user = await this.findOneByFirebaseUid(userId);
    }

    if (!user) {
      throw new NotFoundException(`Utilisateur avec ID ${userId} non trouvé`);
    }

    const populatedUser = await this.userModel
      .findById(user._id)
      .populate('followers', 'username photoUrl firebaseUid')
      .exec();

    return populatedUser.followers;
  }

  async getUserFollowing(userId: string) {
    const user = await this.userModel.findOne({ firebaseUid: userId });

    if (!user) {
      throw new NotFoundException(`Utilisateur ${userId} non trouvé`);
    }

    const followingUsers = await this.userModel
      .find({
        firebaseUid: { $in: user.following },
      })
      .select('username photoUrl firebaseUid isPremium followers following');

    const formattedUsers = followingUsers.map((user) => ({
      id: user.firebaseUid,
      username: user.username,
      photoUrl: user.photoUrl,
      isPremium: user.isPremium || false,
      followersCount: user.followers?.length || 0,
      followingCount: user.following?.length || 0,
    }));

    return formattedUsers;
  }

  async checkIfFollowing(userId: string, targetId: string) {
    let follower;
    let target;

    if (isValidObjectId(userId)) {
      follower = await this.findById(userId);
    } else {
      follower = await this.findOneByFirebaseUid(userId);
    }

    if (isValidObjectId(targetId)) {
      target = await this.findById(targetId);
    } else {
      target = await this.findOneByFirebaseUid(targetId);
    }

    if (!follower || !target) {
      throw new NotFoundException('Utilisateur non trouvé');
    }

    const isFollowing = follower.following.some(
      (id) => id.toString() === target._id.toString(),
    );

    return { isFollowing };
  }

  async getUserFollowersDetails(userId: string) {
    const user = await this.findOneByFirebaseUid(userId);
    if (!user) {
      throw new NotFoundException(`Utilisateur avec ID ${userId} non trouvé`);
    }

    const followers = await this.userModel
      .find({ firebaseUid: { $in: user.followers } })
      .select('username photoUrl firebaseUid')
      .exec();

    return followers;
  }

  async isFollowing(followerId: string, targetId: string): Promise<boolean> {
    const followerUser = await this.userModel
      .findOne({
        firebaseUid: followerId,
        following: targetId,
      })
      .exec();

    return followerUser !== null;
  }

  async getUserStats(userId: string) {
    const user = await this.userModel.findOne({ firebaseUid: userId });
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
}
