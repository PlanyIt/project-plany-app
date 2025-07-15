import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { InjectModel } from '@nestjs/mongoose';
import { User, UserDocument } from './schemas/user.schema';
import { Model, Connection, isValidObjectId, Types } from 'mongoose';
import { InjectConnection } from '@nestjs/mongoose';
import { Plan, PlanDocument } from '../plan/schemas/plan.schema';
import { Comment, CommentDocument } from '../comment/schemas/comment.schema';
import { PasswordService } from 'src/auth/password.service';

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
  ) {}

  /**
   * Vérifie la sécurité d'un mot de passe
   *
   * @private
   * @param password - Mot de passe à vérifier
   * @returns true si le mot de passe respecte les règles de sécurité
   */
  private isPasswordSecure(password: string): boolean {
    // Au moins 8 caractères, une majuscule, une minuscule et un chiffre
    const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/;
    return passwordRegex.test(password);
  }

  /**
   * Crée un nouvel utilisateur
   *
   * @param createUserDto - Données de l'utilisateur à créer
   * @returns Utilisateur créé
   * @throws {BadRequestException} Si le mot de passe n'est pas sécurisé ou si l'email/username existe déjà
   */
  async create(createUserDto: CreateUserDto): Promise<UserDocument> {
    // Vérifier si le mot de passe est sécurisé
    if (!this.isPasswordSecure(createUserDto.password)) {
      throw new BadRequestException(
        'Le mot de passe doit contenir au moins 8 caractères, dont une majuscule, une minuscule et un chiffre',
      );
    }

    try {
      const createdUser = new this.userModel(createUserDto);
      return await createdUser.save();
    } catch (error) {
      // Gérer les erreurs de duplication de MongoDB
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

  /**
   * Récupère tous les utilisateurs
   *
   * @returns Liste de tous les utilisateurs
   */
  async findAll(): Promise<UserDocument[]> {
    return this.userModel.find().exec();
  }

  /**
   * Récupère un utilisateur par son ID
   *
   * @param id - ID de l'utilisateur
   * @returns Utilisateur trouvé ou null si inexistant/ID invalide
   */
  async findById(id: string): Promise<UserDocument | null> {
    if (!isValidObjectId(id)) {
      return null;
    }
    return this.userModel.findById(id).exec();
  }

  /**
   * Récupère un utilisateur par son email
   *
   * @param email - Adresse email de l'utilisateur
   * @returns Utilisateur trouvé ou undefined
   */
  async findOneByEmail(email: string): Promise<UserDocument | undefined> {
    return this.userModel.findOne({ email }).exec();
  }

  /**
   * Récupère un utilisateur par son nom d'utilisateur
   *
   * @param username - Nom d'utilisateur
   * @returns Utilisateur trouvé ou undefined
   */
  async findOneByUsername(username: string): Promise<UserDocument | undefined> {
    return this.userModel.findOne({ username }).exec();
  }

  /**
   * Supprime un utilisateur et toutes ses données associées
   *
   * Effectue une suppression en cascade pour maintenir l'intégrité des données :
   * - Supprime tous les plans de l'utilisateur
   * - Supprime tous les commentaires de l'utilisateur
   * - Retire l'utilisateur des favoris de tous les plans
   * - Met à jour les relations followers/following
   *
   * @param id - ID de l'utilisateur à supprimer
   * @returns Utilisateur supprimé
   * @throws {NotFoundException} Si l'utilisateur n'existe pas
   */
  async removeById(id: string): Promise<UserDocument> {
    const session = await this.connection.startSession();

    try {
      return await session.withTransaction(async () => {
        // 1. Vérifier que l'utilisateur existe
        const user = await this.userModel.findById(id).session(session);
        if (!user) {
          throw new NotFoundException(`User with ID ${id} not found`);
        }

        // 2. Supprimer tous les plans de cet utilisateur
        const userPlans = await this.planModel
          .find({ user: id })
          .session(session);
        const planIds = userPlans.map((plan) => plan._id);

        // Supprimer les commentaires sur ces plans
        await this.commentModel
          .deleteMany({
            planId: { $in: planIds },
          })
          .session(session);

        // Supprimer les plans
        await this.planModel.deleteMany({ user: id }).session(session);

        // 3. Supprimer tous les commentaires de cet utilisateur (sur d'autres plans)
        await this.commentModel.deleteMany({ user: id }).session(session);

        // 4. Retirer cet utilisateur des favoris de tous les plans
        await this.planModel
          .updateMany({ favorites: id }, { $pull: { favorites: id } })
          .session(session);

        // 5. Mettre à jour les relations sociales
        // Retirer cet utilisateur de la liste "following" des autres
        await this.userModel
          .updateMany({ following: id }, { $pull: { following: id } })
          .session(session);

        // Retirer cet utilisateur de la liste "followers" des autres
        await this.userModel
          .updateMany({ followers: id }, { $pull: { followers: id } })
          .session(session);

        // 6. Supprimer l'utilisateur
        const deletedUser = await this.userModel
          .findByIdAndDelete(id)
          .session(session)
          .exec();

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

    // Si le mot de passe est mis à jour, on le hache
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

    return updatedUser;
  }

  /**
   * Récupère les plans favoris d'un utilisateur
   *
   * @param userId - ID de l'utilisateur
   * @returns Liste des plans favoris triés par date de création
   * @throws {NotFoundException} Si l'utilisateur n'existe pas
   */
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

  /**
   * Permet à un utilisateur de suivre un autre utilisateur
   *
   * @param followerId - ID de l'utilisateur qui suit
   * @param targetUserId - ID de l'utilisateur à suivre
   * @returns Résultat de l'opération avec message de succès/erreur
   * @throws {NotFoundException} Si l'un des utilisateurs n'existe pas
   */
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

  /**
   * Permet à un utilisateur de ne plus suivre un autre utilisateur
   *
   * Met à jour les listes following/followers des deux utilisateurs concernés.
   *
   * @param followerId - ID de l'utilisateur qui ne veut plus suivre
   * @param targetUserId - ID de l'utilisateur à ne plus suivre
   * @returns Résultat de l'opération avec message de succès
   * @throws {NotFoundException} Si l'un des utilisateurs n'existe pas
   */
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

  /**
   * Récupère la liste des abonnés d'un utilisateur
   *
   * @param userId - ID de l'utilisateur
   * @returns Liste des abonnés avec informations de base
   * @throws {NotFoundException} Si l'utilisateur n'existe pas
   */
  async getUserFollowers(userId: string) {
    const user = await this.findById(userId);

    if (!user) {
      throw new NotFoundException(`Utilisateur avec ID ${userId} non trouvé`);
    }

    const populatedUser = await this.userModel
      .findById(user._id)
      .populate('followers', 'username email photoUrl')
      .exec();

    return populatedUser.followers;
  }

  /**
   * Récupère la liste des abonnements d'un utilisateur
   *
   * @param userId - ID de l'utilisateur
   * @returns Liste des utilisateurs suivis avec informations de base
   * @throws {NotFoundException} Si l'utilisateur n'existe pas
   */
  async getUserFollowing(userId: string) {
    const user = await this.userModel.findOne({ _id: userId });

    if (!user) {
      throw new NotFoundException(`Utilisateur ${userId} non trouvé`);
    }
    const populatedUser = await this.userModel
      .findById(user._id)
      .populate('following', 'username email photoUrl')
      .exec();

    return populatedUser.following;
  }

  /**
   * Vérifie si un utilisateur suit un autre utilisateur
   *
   * @param followerId - ID de l'utilisateur potentiel suiveur
   * @param targetId - ID de l'utilisateur potentiellement suivi
   * @returns true si followerId suit targetId, false sinon
   */
  async isFollowing(followerId: string, targetId: string): Promise<boolean> {
    const followerUser = await this.userModel
      .findOne({
        _id: followerId,
        following: targetId,
      })
      .exec();

    return followerUser !== null;
  }

  /**
   * Récupère les statistiques d'un utilisateur
   *
   * @param userId - ID de l'utilisateur
   * @returns Statistiques (nombre de plans, favoris, followers, following)
   * @throws {NotFoundException} Si l'utilisateur n'existe pas
   */
  async getUserStats(userId: string) {
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
    return {
      plansCount,
      favoritesCount,
      followersCount,
      followingCount,
    };
  }
}
