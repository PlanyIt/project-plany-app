import * as mongoose from 'mongoose';
import { User, UserSchema } from './user/schemas/user.schema';
import { config } from 'dotenv';

// Charger les variables d'environnement
config();

async function bootstrap() {
  try {
    // Connexion à MongoDB
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Connected to MongoDB');

    // Créer le modèle User
    const UserModel = mongoose.model<User>('User', UserSchema);

    // Vérifier si des utilisateurs existent déjà
    const usersCount = await UserModel.countDocuments();

    if (usersCount === 0) {
      console.log('No users found, creating default admin...');

      // Créer un utilisateur administrateur par défaut
      const defaultAdmin = new UserModel({
        username: 'admin',
        email: 'admin@plany.com',
        firebaseUid: 'admin-default',
        description: 'Administrateur par défaut',
        role: 'admin',
        registrationDate: new Date(),
        isActive: true,
      });

      await defaultAdmin.save();
      console.log('Default admin created successfully');
    } else {
      console.log(`Found ${usersCount} existing users`);
    }

    console.log('Initialization complete');
  } catch (error) {
    console.error('Initialization failed:', error);
  } finally {
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
  }
}

bootstrap();
