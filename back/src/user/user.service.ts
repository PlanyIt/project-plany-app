import { Injectable } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { InjectModel } from '@nestjs/mongoose';
import { User, UserDocument } from './schemas/user.schema';
import { Model } from 'mongoose';

@Injectable()
export class UserService {
  constructor(@InjectModel(User.name) private userModel: Model<UserDocument>) {}

  // Création d'un utilisateur
  async create(createUserDto: CreateUserDto): Promise<UserDocument> {
    const createdUser = new this.userModel(createUserDto);
    return createdUser.save();
  }

  // Récupération de tous les utilisateurs
  async findAll(): Promise<UserDocument[]> {
    return this.userModel.find().exec();
  }

  // Récupération d'un utilisateur par FirebaseUid
  async findOneByFirebaseUid(
    firebaseUid: string,
  ): Promise<UserDocument | undefined> {
    return this.userModel.findOne({ firebaseUid }).exec();
  }

  // Suppression d'un utilisateur par firebaseUid
  async removeByFirebaseUid(firebaseUid: string): Promise<UserDocument> {
    return this.userModel.findOneAndDelete({ firebaseUid }).exec();
  }

  // Récupération d'un utilisateur par son nom d'utilisateur
  async findOneByUsername(username: string): Promise<UserDocument | undefined> {
    return this.userModel.findOne({ username }).exec();
  }

  // Récupération d'un utilisateur par son adresse e-mail
  async findOneByEmail(email: string): Promise<UserDocument | undefined> {
    return this.userModel.findOne({ email }).exec();
  }

  // Mise à jour d'un utilisateur par firebaseUid
  async updateByFirebaseUid(
    firebaseUid: string,
    updateUserDto: UpdateUserDto,
  ): Promise<UserDocument> {
    return this.userModel
      .findOneAndUpdate({ firebaseUid }, updateUserDto, { new: true })
      .exec();
  }
}
