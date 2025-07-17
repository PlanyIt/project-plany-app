import * as dotenv from 'dotenv';
// Charge .env.test spécifiquement pour ce fichier
dotenv.config({ path: '.env.test' });

import { MongoClient, ObjectId } from 'mongodb';
import * as argon2 from 'argon2';

const uri = process.env.MONGO_URI || 'mongodb://localhost:27018';
const dbName = 'planytest'; // Important : base dédiée au test

async function main() {
  const client = new MongoClient(uri);
  await client.connect();
  const db = client.db(dbName);

  // Nettoyage complet pour des tests fiables
  await db.collection('users').deleteMany({});
  await db.collection('plans').deleteMany({});
  await db.collection('steps').deleteMany({});
  await db.collection('comments').deleteMany({});
  await db.collection('categories').deleteMany({});

  // Catégories
  const categories = [
    { name: 'Test - Weekend', icon: 'calendar_today', color: '#FF9800' },
    { name: 'Test - Vacances', icon: 'beach_access', color: '#1976D2' },
    { name: 'Test - Aventure', icon: 'terrain', color: '#388E3C' },
  ];
  await db.collection('categories').insertMany(categories);

  // Utilisateurs test
  const users = [
    {
      _id: new ObjectId(),
      username: 'test-user',
      email: 'test@example.com',
      password: await argon2.hash('Test1234', {
        type: argon2.argon2id,
        memoryCost: 65536,
        timeCost: 3,
        parallelism: 4,
      }),
      description: 'Utilisateur de test',
      isPremium: false,
      photoUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
      birthDate: new Date('1992-01-01'),
      gender: 'Autre',
      role: 'user',
      followers: [],
      following: [],
    },
  ];
  await db.collection('users').insertMany(users);

  // Plans simplifiés
  const plans = [
    {
      _id: new ObjectId(),
      title: 'Plan de Test',
      description: 'Un plan de test.',
      user: users[0]._id,
      isPublic: true,
      isAccessible: true,
      category: await db
        .collection('categories')
        .findOne({ name: 'Test - Weekend' })
        .then((c) => c?._id),
      steps: [],
      favorites: [],
      totalCost: 50,
      totalDuration: 10,
      createdAt: new Date(),
    },
  ];

  // Steps associés
  const steps = [
    {
      _id: new ObjectId(),
      title: 'Lieu test 1',
      description: 'Lieu fictif pour le test',
      latitude: 0,
      longitude: 0,
      order: 1,
      image: 'https://via.placeholder.com/800x600',
      duration: 60,
      cost: 10,
      planId: plans[0]._id,
    },
  ];

  plans[0].steps = steps.map((s) => s._id);

  await db.collection('steps').insertMany(steps);
  await db.collection('plans').insertMany(plans);

  console.log('✅ Seed test terminé dans planytest');
  await client.close();
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
