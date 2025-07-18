import * as dotenv from 'dotenv';
dotenv.config();

import { MongoClient, ObjectId } from 'mongodb';
import * as argon2 from 'argon2';

const uri = process.env.MONGO_URI || 'mongodb://localhost:27017';
const dbName = 'plany';

async function main() {
  const client = new MongoClient(uri);
  await client.connect();
  const db = client.db(dbName);

  // Nettoyage
  await db.collection('users').deleteMany({});
  await db.collection('plans').deleteMany({});
  await db.collection('steps').deleteMany({});
  await db.collection('comments').deleteMany({});
  await db.collection('categories').deleteMany({});

  // 0. Catégories
  const categories = [
    { name: 'Weekend', icon: 'calendar_today', color: '#FF9800' },
    { name: 'Vacances', icon: 'beach_access', color: '#1976D2' }, // bleu foncé
    { name: 'Escapade en amoureux', icon: 'favorite', color: '#D81B60' }, // rose foncé
    { name: 'Sortie entre amis', icon: 'group', color: '#616161' }, // gris foncé
    { name: 'Aventure', icon: 'terrain', color: '#388E3C' }, // vert foncé
    { name: 'Culture', icon: 'theaters', color: '#7B1FA2' }, // violet foncé
    { name: 'Gastronomie', icon: 'restaurant', color: '#B8860B' }, // brun doré foncé
    { name: 'Bien-être', icon: 'spa', color: '#388E3C' }, // vert foncé
    { name: 'Shopping', icon: 'shopping_cart', color: '#E64A19' }, // orange/rouge foncé
    { name: 'Sport', icon: 'directions_run', color: '#303F9F' }, // bleu nuit
    { name: 'Nature', icon: 'eco', color: '#009688' }, // vert sarcelle
    { name: 'Musique', icon: 'music_note', color: '#512DA8' }, // violet profond
    { name: 'Art', icon: 'palette', color: '#FF5722' }, // orange vif foncé
    { name: 'Fête', icon: 'celebration', color: '#C2185B' }, // rose foncé
    { name: 'Autre', icon: 'help_outline', color: '#455A64' }, // bleu-gris foncé
  ];
  await db.collection('categories').insertMany(categories);

  // 1. Faux utilisateurs
  const users = [
    {
      _id: new ObjectId(),
      username: 'alice',
      email: 'alice@example.com',
      password: await argon2.hash('Alice1234', {
        type: argon2.argon2id,
        memoryCost: 65536,
        timeCost: 3,
        parallelism: 4,
      }),
      description: 'Voyageuse passionnée',
      isPremium: true,
      photoUrl: 'https://randomuser.me/api/portraits/women/68.jpg',
      birthDate: new Date('1990-05-15'),
      gender: 'Femme',
      role: 'user',
      followers: [],
      following: [],
    },
    {
      _id: new ObjectId(),
      username: 'bob',
      email: 'bob@example.com',
      password: await argon2.hash('Bob12345', {
        type: argon2.argon2id,
        memoryCost: 65536,
        timeCost: 3,
        parallelism: 4,
      }),
      description: 'Aventurier urbain',
      isPremium: false,
      photoUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
      birthDate: new Date('1985-11-23'),
      gender: 'Homme',
      role: 'user',
      followers: [],
      following: [],
    },
    {
      _id: new ObjectId(),
      username: 'carol',
      email: 'carol@example.com',
      password: await argon2.hash('Carol123', {
        type: argon2.argon2id,
        memoryCost: 65536,
        timeCost: 3,
        parallelism: 4,
      }),
      description: 'Amatrice de gastronomie',
      isPremium: false,
      photoUrl: 'https://randomuser.me/api/portraits/women/65.jpg',
      birthDate: new Date('1995-07-08'),
      gender: 'Femme',
      role: 'user',
      followers: [],
      following: [],
    },
  ];
  await db.collection('users').insertMany(users);

  // 2. Plans et steps (lieux réels, images réseau)
  const plans = [
    {
      _id: new ObjectId(),
      title: 'Visite de Paris en 2 jours',
      description: 'Découvrez les incontournables de Paris en un week-end.',
      user: users[0]._id,
      isPublic: true,
      isAccessible: false,
      category: await db
        .collection('categories')
        .findOne({ name: 'Weekend' })
        .then((c) => c?._id),
      steps: [],
      favorites: [users[1]._id.toString()],
      totalCost: 80,
      totalDuration: 16,
      createdAt: new Date(),
    },
    {
      _id: new ObjectId(),
      title: "Road trip Côte d'Azur",
      description: 'Un itinéraire ensoleillé de Nice à Saint-Tropez.',
      user: users[1]._id,
      isPublic: true,
      isAccessible: true,
      category: await db
        .collection('categories')
        .findOne({ name: 'Vacances' })
        .then((c) => c?._id),
      steps: [],
      favorites: [users[0]._id.toString(), users[2]._id.toString()],
      totalCost: 200,
      totalDuration: 24,
      createdAt: new Date(),
    },
    {
      _id: new ObjectId(),
      title: 'Gastronomie à Lyon',
      description: 'Parcours gourmand dans la capitale de la gastronomie.',
      user: users[2]._id,
      isPublic: true,
      isAccessible: false,
      category: await db
        .collection('categories')
        .findOne({ name: 'Gastronomie' })
        .then((c) => c?._id),
      steps: [],
      favorites: [],
      totalCost: 120,
      totalDuration: 8,
      createdAt: new Date(),
    },
  ];

  // Steps pour chaque plan
  const steps = [
    // Paris
    {
      _id: new ObjectId(),
      title: 'Tour Eiffel',
      description: 'Montez au sommet de la Tour Eiffel.',
      latitude: 48.8584,
      longitude: 2.2945,
      order: 1,
      image:
        'https://plus.unsplash.com/premium_photo-1661963064037-cfcf2e10db2d?q=80&auto=format&fit=crop&w=800&h=600',
      duration: 120, // 2h
      cost: 25,
      planId: plans[0]._id,
    },
    {
      _id: new ObjectId(),
      title: 'Musée du Louvre',
      description: 'Visitez le plus grand musée du monde.',
      latitude: 48.8606,
      longitude: 2.3376,
      order: 2,
      image:
        'https://images.unsplash.com/photo-1567942585146-33d62b775db0?q=80&auto=format&fit=crop&w=800&h=600',
      duration: 180, // 3h
      cost: 17,
      planId: plans[0]._id,
    },
    {
      _id: new ObjectId(),
      title: 'Montmartre',
      description: 'Balade dans le quartier des artistes.',
      latitude: 48.8867,
      longitude: 2.3431,
      order: 3,
      image:
        'https://images.unsplash.com/photo-1682372249522-6e827e57e818?q=80&auto=format&fit=crop&w=800&h=600',
      duration: 90, // 1h30
      cost: 0,
      planId: plans[0]._id,
    },
    // Côte d'Azur
    {
      _id: new ObjectId(),
      title: 'Promenade des Anglais',
      description: 'Marchez le long de la mer à Nice.',
      latitude: 43.6959,
      longitude: 7.2659,
      order: 1,
      image:
        'https://plus.unsplash.com/premium_photo-1742457620013-6a9c3b0efdca?q=80&auto=format&fit=crop&w=800&h=600',
      duration: 90, // 1h30
      cost: 0,
      planId: plans[1]._id,
    },
    {
      _id: new ObjectId(),
      title: 'Cannes - La Croisette',
      description: 'Flânez sur la célèbre Croisette.',
      latitude: 43.5513,
      longitude: 7.0174,
      order: 2,
      image:
        'https://images.unsplash.com/photo-1659642081604-8c2eef905d9b?q=80&auto=format&fit=crop&w=800&h=600',
      duration: 90, // 1h30
      cost: 0,
      planId: plans[1]._id,
    },
    {
      _id: new ObjectId(),
      title: 'Saint-Tropez',
      description: 'Terminez à Saint-Tropez, village mythique.',
      latitude: 43.2672,
      longitude: 6.64,
      order: 3,
      image:
        'https://plus.unsplash.com/premium_photo-1661963861529-02951a02a25f?q=80&auto=format&fit=crop&w=800&h=600',
      duration: 120, // 2h
      cost: 30,
      planId: plans[1]._id,
    },
    // Lyon
    {
      _id: new ObjectId(),
      title: 'Les Halles de Lyon Paul Bocuse',
      description: 'Dégustez des spécialités lyonnaises.',
      latitude: 45.764,
      longitude: 4.858,
      order: 1,
      image:
        'https://images.unsplash.com/photo-1644534226966-539b8e1e0879?q=80&auto=format&fit=crop&w=800&h=600',
      duration: 120, // 2h
      cost: 40,
      planId: plans[2]._id,
    },
    {
      _id: new ObjectId(),
      title: 'Vieux Lyon',
      description: 'Promenade dans le quartier historique.',
      latitude: 45.7622,
      longitude: 4.8277,
      order: 2,
      image:
        'https://images.unsplash.com/photo-1600775653108-3e08a69d224c?q=80&auto=format&fit=crop&w=800&h=600',
      duration: 90, // 1h30
      cost: 0,
      planId: plans[2]._id,
    },
    {
      _id: new ObjectId(),
      title: 'Bouchon lyonnais',
      description: 'Déjeuner dans un bouchon traditionnel.',
      latitude: 45.764,
      longitude: 4.8357,
      order: 3,
      image:
        'https://plus.unsplash.com/premium_photo-1680296811745-ae5f6b076472?q=80&auto=format&fit=crop&w=800&h=600',
      duration: 120, // 2h
      cost: 40,
      planId: plans[2]._id,
    },
    // Bordeaux/Mérignac - nouveaux plans
    {
      _id: new ObjectId(),
      title: 'Place de la Bourse',
      description: "Admirez le miroir d'eau et l'architecture emblématique.",
      latitude: 44.841225,
      longitude: -0.56935,
      order: 1,
      image:
        'https://images.unsplash.com/photo-1698608216843-67ae1151b2b8?q=80&w=1170&auto=format&fit=crop&w=800&h=600',
      duration: 60, // 1h
      cost: 0,
      planId: null,
    },
    {
      _id: new ObjectId(),
      title: 'Cité du Vin',
      description: "Découvrez l'univers du vin à Bordeaux.",
      latitude: 44.8622,
      longitude: -0.5516,
      order: 2,
      image:
        'https://images.unsplash.com/photo-1624278132164-9e86246fd4b1?q=80&w=1121&auto=format&fit=crop&w=800&h=600',
      duration: 120, // 2h
      cost: 20,
      planId: null,
    },
    {
      _id: new ObjectId(),
      title: 'Parc Bordelais',
      description: 'Balade et détente dans le plus grand parc de Bordeaux.',
      latitude: 44.8491,
      longitude: -0.6066,
      order: 3,
      image:
        'https://images.unsplash.com/photo-1624671419184-769963ae6920?q=80&w=1025&auto=format&fit=crop&w=800&h=600',
      duration: 90, // 1h30
      cost: 0,
      planId: null,
    },
    {
      _id: new ObjectId(),
      title: 'Parc de Bourran',
      description: 'Parc arboré à Mérignac, idéal pour un pique-nique.',
      latitude: 44.8417,
      longitude: -0.6389,
      order: 1,
      image:
        'https://images.unsplash.com/photo-1666544835456-b248a0f71445?q=80&w=2574&auto=format&fit=crop&w=800&h=600',
      duration: 90, // 1h30
      cost: 0,
      planId: null,
    },
    {
      _id: new ObjectId(),
      title: 'Château Luchey-Halde',
      description: "Visite d'un vignoble urbain à Mérignac.",
      latitude: 44.8346,
      longitude: -0.6291,
      order: 2,
      image:
        'https://images.unsplash.com/photo-1668506031516-9f47c9576ce4?q=80&w=688&auto=format&fit=crop&w=800&h=600',
      duration: 120, // 2h
      cost: 15,
      planId: null,
    },
    {
      _id: new ObjectId(),
      title: 'Bowling de Mérignac',
      description: 'Soirée entre amis au bowling.',
      latitude: 44.8325,
      longitude: -0.6707,
      order: 3,
      image:
        'https://images.unsplash.com/photo-1614713568397-b31b779d0498?q=80&w=1125&auto=format&fit=crop&w=800&h=600',
      duration: 150, // 2h30
      cost: 10,
      planId: null,
    },
  ];

  // Création des nouveaux plans Bordeaux/Mérignac
  const bordeauxPlans = [
    {
      _id: new ObjectId(),
      title: 'Découverte de Bordeaux',
      description: 'Un après-midi entre patrimoine et détente.',
      user: users[0]._id,
      isPublic: true,
      isAccessible: true,
      category: await db
        .collection('categories')
        .findOne({ name: 'Culture' })
        .then((c) => c?._id),
      steps: [],
      favorites: [users[1]._id.toString()],
      totalCost: 20,
      totalDuration: 5,
      createdAt: new Date(),
    },
    {
      _id: new ObjectId(),
      title: 'Nature à Mérignac',
      description: 'Balade et découverte de la nature à Mérignac.',
      user: users[1]._id,
      isPublic: true,
      isAccessible: true,
      category: await db
        .collection('categories')
        .findOne({ name: 'Nature' })
        .then((c) => c?._id),
      steps: [],
      favorites: [users[2]._id.toString()],
      totalCost: 15,
      totalDuration: 4,
      createdAt: new Date(),
    },
    {
      _id: new ObjectId(),
      title: 'Soirée entre amis à Mérignac',
      description: 'Bowling et détente pour une soirée conviviale.',
      user: users[2]._id,
      isPublic: true,
      isAccessible: true,
      category: await db
        .collection('categories')
        .findOne({ name: 'Sortie entre amis' })
        .then((c) => c?._id),
      steps: [],
      favorites: [users[0]._id.toString()],
      totalCost: 10,
      totalDuration: 2,
      createdAt: new Date(),
    },
  ];

  // Associer les steps aux plans Bordeaux/Mérignac
  // Place de la Bourse, Cité du Vin, Parc Bordelais -> Découverte de Bordeaux
  steps[9].planId = bordeauxPlans[0]._id;
  steps[10].planId = bordeauxPlans[0]._id;
  steps[11].planId = bordeauxPlans[0]._id;
  bordeauxPlans[0].steps = [steps[9]._id, steps[10]._id, steps[11]._id];

  // Parc de Bourran, Château Luchey-Halde -> Nature à Mérignac
  steps[12].planId = bordeauxPlans[1]._id;
  steps[13].planId = bordeauxPlans[1]._id;
  bordeauxPlans[1].steps = [steps[12]._id, steps[13]._id];

  // Bowling de Mérignac -> Soirée entre amis à Mérignac
  steps[14].planId = bordeauxPlans[2]._id;
  bordeauxPlans[2].steps = [steps[14]._id];

  // Associer les steps aux plans existants (Paris, Côte d'Azur, Lyon)
  plans[0].steps = steps
    .filter((s) => s.planId && s.planId.equals(plans[0]._id))
    .map((s) => s._id);
  plans[1].steps = steps
    .filter((s) => s.planId && s.planId.equals(plans[1]._id))
    .map((s) => s._id);
  plans[2].steps = steps
    .filter((s) => s.planId && s.planId.equals(plans[2]._id))
    .map((s) => s._id);

  await db.collection('steps').insertMany(steps);
  await db.collection('plans').insertMany([...plans, ...bordeauxPlans]);

  // 3. Commentaires
  const comments = [
    {
      _id: new ObjectId(),
      content: 'Super plan, merci !',
      user: users[1]._id,
      planId: plans[0]._id.toString(),
      likes: [users[2]._id.toString()],
      responses: [],
      createdAt: new Date(),
      updatedAt: new Date(),
    },
    {
      _id: new ObjectId(),
      content: 'J’ai adoré la balade à Montmartre.',
      user: users[2]._id,
      planId: plans[0]._id.toString(),
      likes: [],
      responses: [],
      createdAt: new Date(),
      updatedAt: new Date(),
    },
    {
      _id: new ObjectId(),
      content: 'La Croisette, un incontournable !',
      user: users[0]._id,
      planId: plans[1]._id.toString(),
      likes: [users[2]._id.toString()],
      responses: [],
      createdAt: new Date(),
      updatedAt: new Date(),
    },
    {
      _id: new ObjectId(),
      content: 'Les Halles de Lyon, un régal.',
      user: users[1]._id,
      planId: plans[2]._id.toString(),
      likes: [users[0]._id.toString()],
      responses: [],
      createdAt: new Date(),
      updatedAt: new Date(),
    },
  ];
  await db.collection('comments').insertMany(comments);

  // 4. Followers/following (relations croisées)
  // alice suit bob, bob suit carol, carol suit alice
  await db
    .collection('users')
    .updateOne(
      { _id: users[0]._id },
      { $set: { following: [users[1]._id], followers: [users[2]._id] } },
    );
  await db
    .collection('users')
    .updateOne(
      { _id: users[1]._id },
      { $set: { following: [users[2]._id], followers: [users[0]._id] } },
    );
  await db
    .collection('users')
    .updateOne(
      { _id: users[2]._id },
      { $set: { following: [users[0]._id], followers: [users[1]._id] } },
    );

  console.log('Seed terminé !');
  await client.close();
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
