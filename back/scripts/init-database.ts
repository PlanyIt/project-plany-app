import { MongoClient, Db } from 'mongodb';
import { config } from 'dotenv';

// Charger les variables d'environnement
config();

interface DatabaseConfig {
  uri: string;
  dbName: string;
  collections: string[];
}

interface ValidationSchema {
  [key: string]: any;
}

interface IndexConfig {
  collection: string;
  indexes: Array<{
    fields: Record<string, number>;
    options?: Record<string, any>;
  }>;
}

class DatabaseInitializer {
  private client: MongoClient;
  private db: Db;
  private config: DatabaseConfig;

  constructor() {
    this.config = {
      uri: process.env.MONGO_URI || 'mongodb://localhost:27017',
      dbName: process.env.DATABASE_NAME || 'plany',
      collections: ['categories', 'users', 'plans', 'steps', 'comments'],
    };
  }

  async initialize(): Promise<void> {
    try {
      console.log('🚀 Initializing MongoDB database...');

      // 1. Connexion à la base de données
      await this.connect();

      // 2. Créer les collections avec validation
      await this.createCollectionsWithValidation();

      // 3. Créer les index pour l'intégrité et les performances
      await this.createIndexes();

      // 4. Vérifier la configuration
      await this.validateConfiguration();

      console.log('✅ Database initialization completed successfully!');
    } catch (error) {
      console.error('❌ Database initialization failed:', error);
      throw error;
    } finally {
      await this.disconnect();
    }
  }

  private async connect(): Promise<void> {
    try {
      this.client = new MongoClient(this.config.uri);
      await this.client.connect();
      this.db = this.client.db(this.config.dbName);

      // Test de la connexion
      await this.db.admin().ping();
      console.log(`📡 Connected to MongoDB: ${this.config.dbName}`);
    } catch (error) {
      console.error('❌ Connection failed:', error);
      throw error;
    }
  }

  private async createCollectionsWithValidation(): Promise<void> {
    console.log('📋 Creating collections with validation schemas...');

    const validationSchemas: Record<string, ValidationSchema> = {
      categories: {
        $jsonSchema: {
          bsonType: 'object',
          required: ['name', 'icon', 'color'],
          properties: {
            name: {
              bsonType: 'string',
              minLength: 1,
              description: 'Category name is required',
            },
            icon: {
              bsonType: 'string',
              minLength: 1,
              description: 'Icon is required',
            },
            color: {
              bsonType: 'string',
              minLength: 1,
              description: 'Color is required',
            },
          },
        },
      },

      users: {
        $jsonSchema: {
          bsonType: 'object',
          required: ['username', 'email', 'password'],
          properties: {
            username: {
              bsonType: 'string',
              minLength: 1,
              description: 'Username is required and must be unique',
            },
            email: {
              bsonType: 'string',
              pattern: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$',
              description: 'Must be a valid email address and unique',
            },
            password: {
              bsonType: 'string',
              minLength: 8,
              description:
                'Password must be at least 8 characters (will be hashed)',
            },
            description: {
              bsonType: 'string',
              description: 'User description/bio',
            },
            isPremium: {
              bsonType: 'bool',
              description: 'Premium status, defaults to false',
            },
            photoUrl: {
              bsonType: 'string',
              description: 'Profile photo URL',
            },
            birthDate: {
              bsonType: 'date',
              description: 'User birth date',
            },
            gender: {
              bsonType: 'string',
              description: 'User gender',
            },
            role: {
              bsonType: 'string',
              description: 'User role, defaults to user',
            },
            isActive: {
              bsonType: 'bool',
              description: 'Account status, defaults to true',
            },
            followers: {
              bsonType: 'array',
              items: { bsonType: 'objectId' },
              description: 'Array of follower user IDs',
            },
            following: {
              bsonType: 'array',
              items: { bsonType: 'objectId' },
              description: 'Array of following user IDs',
            },
            createdAt: { bsonType: 'date' },
            updatedAt: { bsonType: 'date' },
          },
        },
      },

      plans: {
        $jsonSchema: {
          bsonType: 'object',
          required: ['title', 'description', 'user', 'category'],
          properties: {
            title: {
              bsonType: 'string',
              minLength: 1,
              description: 'Plan title is required',
            },
            description: {
              bsonType: 'string',
              minLength: 1,
              description: 'Plan description is required',
            },
            user: {
              bsonType: 'objectId',
              description: 'Must reference a valid user',
            },
            isPublic: {
              bsonType: 'bool',
              description: 'Plan visibility, defaults to true',
            },
            isAccessible: {
              bsonType: 'bool',
              description: 'Accessibility status, defaults to false',
            },
            category: {
              bsonType: 'objectId',
              description: 'Must reference a valid category ObjectId',
            },
            steps: {
              bsonType: 'array',
              items: { bsonType: 'objectId' },
              description: 'Array of step ObjectIds',
            },
            favorites: {
              bsonType: 'array',
              items: { bsonType: 'string' },
              description: 'Array of user IDs who favorited this plan',
            },
            totalCost: {
              bsonType: 'number',
              minimum: 0,
              description: 'Total cost of the plan',
            },
            totalDuration: {
              bsonType: 'number',
              minimum: 0,
              description: 'Total duration of the plan in minutes',
            },
            createdAt: { bsonType: 'date' },
            updatedAt: { bsonType: 'date' },
          },
        },
      },

      steps: {
        $jsonSchema: {
          bsonType: 'object',
          required: [
            'title',
            'description',
            'order',
            'image',
            'duration',
            'cost',
          ],
          properties: {
            title: {
              bsonType: 'string',
              minLength: 1,
              description: 'Step title is required',
            },
            description: {
              bsonType: 'string',
              minLength: 1,
              description: 'Step description is required',
            },
            latitude: {
              bsonType: 'number',
              minimum: -90,
              maximum: 90,
              description: 'Valid latitude coordinate',
            },
            longitude: {
              bsonType: 'number',
              minimum: -180,
              maximum: 180,
              description: 'Valid longitude coordinate',
            },
            order: {
              bsonType: 'number',
              minimum: 0,
              description: 'Step order, must be positive',
            },
            image: {
              bsonType: 'string',
              minLength: 1,
              description: 'Image URL is required',
            },
            duration: {
              bsonType: 'number',
              minimum: 0,
              description: 'Duration must be positive',
            },
            cost: {
              bsonType: 'number',
              minimum: 0,
              description: 'Cost must be positive or zero',
            },
            createdAt: { bsonType: 'date' },
            updatedAt: { bsonType: 'date' },
          },
        },
      },

      comments: {
        $jsonSchema: {
          bsonType: 'object',
          required: ['content', 'user', 'planId'],
          properties: {
            content: {
              bsonType: 'string',
              minLength: 1,
              description: 'Comment content is required',
            },
            user: {
              bsonType: 'objectId',
              description: 'Must reference a valid user',
            },
            planId: {
              bsonType: 'objectId',
              description: 'Must reference a valid plan',
            },
            likes: {
              bsonType: 'array',
              items: { bsonType: 'string' },
              description: 'Array of user IDs who liked this comment',
            },
            responses: {
              bsonType: 'array',
              items: { bsonType: 'objectId' },
              description: 'Array of response comment IDs',
            },
            parentId: {
              bsonType: 'objectId',
              description: 'Parent comment ID for threaded comments',
            },
            imageUrl: {
              bsonType: 'string',
              description: 'Optional image URL for the comment',
            },
            createdAt: { bsonType: 'date' },
            updatedAt: { bsonType: 'date' },
          },
        },
      },
    };

    // Créer chaque collection avec sa validation
    for (const collectionName of this.config.collections) {
      try {
        await this.db.createCollection(collectionName, {
          validator: validationSchemas[collectionName],
        });
        console.log(
          `✅ Collection '${collectionName}' created with validation`,
        );
      } catch (error: any) {
        if (error.code === 48) {
          // Collection already exists
          console.log(
            `⚠️  Collection '${collectionName}' already exists, updating validator...`,
          );
          await this.db.command({
            collMod: collectionName,
            validator: validationSchemas[collectionName],
          });
          console.log(`✅ Validator updated for '${collectionName}'`);
        } else {
          throw error;
        }
      }
    }
  }

  private async createIndexes(): Promise<void> {
    console.log('🔍 Creating indexes for integrity and performance...');

    const indexConfigs: IndexConfig[] = [
      {
        collection: 'categories',
        indexes: [
          {
            fields: { name: 1 },
            options: { unique: true, name: 'unique_category_name' },
          },
        ],
      },
      {
        collection: 'users',
        indexes: [
          {
            fields: { email: 1 },
            options: { unique: true, name: 'unique_email' },
          },
          {
            fields: { username: 1 },
            options: { unique: true, name: 'unique_username' },
          },
          {
            fields: { createdAt: -1 },
            options: { name: 'users_created_at_desc' },
          },
          { fields: { isActive: 1 }, options: { name: 'users_active_status' } },
          {
            fields: { isPremium: 1 },
            options: { name: 'users_premium_status' },
          },
        ],
      },
      {
        collection: 'plans',
        indexes: [
          { fields: { user: 1 }, options: { name: 'plans_user_id' } },
          { fields: { category: 1 }, options: { name: 'plans_category' } },
          {
            fields: { createdAt: -1 },
            options: { name: 'plans_created_at_desc' },
          },
          {
            fields: { isPublic: 1, createdAt: -1 },
            options: { name: 'public_plans_recent' },
          },
          {
            fields: { user: 1, isPublic: 1 },
            options: { name: 'user_public_plans' },
          },
          { fields: { totalCost: 1 }, options: { name: 'plans_total_cost' } },
          {
            fields: { totalDuration: 1 },
            options: { name: 'plans_total_duration' },
          },
        ],
      },
      {
        collection: 'steps',
        indexes: [
          { fields: { order: 1 }, options: { name: 'steps_order' } },
          { fields: { cost: 1 }, options: { name: 'steps_cost' } },
          { fields: { duration: 1 }, options: { name: 'steps_duration' } },
          {
            fields: { createdAt: -1 },
            options: { name: 'steps_created_at_desc' },
          },
        ],
      },
      {
        collection: 'comments',
        indexes: [
          {
            fields: { planId: 1, createdAt: -1 },
            options: { name: 'comments_plan_recent' },
          },
          { fields: { user: 1 }, options: { name: 'comments_user' } },
          { fields: { parentId: 1 }, options: { name: 'comments_parent' } },
          {
            fields: { createdAt: -1 },
            options: { name: 'comments_created_at_desc' },
          },
        ],
      },
    ];

    for (const config of indexConfigs) {
      const collection = this.db.collection(config.collection);
      for (const index of config.indexes) {
        try {
          await collection.createIndex(index.fields, index.options);
          console.log(
            `✅ Index '${index.options?.name}' created on '${config.collection}'`,
          );
        } catch (error: any) {
          if (error.code === 85) {
            // Index already exists
            console.log(
              `⚠️  Index '${index.options?.name}' already exists on '${config.collection}'`,
            );
          } else {
            throw error;
          }
        }
      }
    }
  }

  private async validateConfiguration(): Promise<void> {
    console.log('🔍 Validating database configuration...');

    // Vérifier que toutes les collections sont créées
    const existingCollections = await this.db.listCollections().toArray();
    const existingNames = existingCollections.map((col) => col.name);

    for (const expectedCollection of this.config.collections) {
      if (!existingNames.includes(expectedCollection)) {
        throw new Error(`Collection '${expectedCollection}' was not created`);
      }
    }

    // Vérifier les index critiques
    const criticalIndexes = [
      { collection: 'categories', index: 'unique_category_name' },
      { collection: 'users', index: 'unique_email' },
      { collection: 'users', index: 'unique_username' },
    ];

    for (const { collection, index } of criticalIndexes) {
      const indexes = await this.db
        .collection(collection)
        .listIndexes()
        .toArray();
      const indexExists = indexes.some((idx) => idx.name === index);

      if (!indexExists) {
        throw new Error(
          `Critical index '${index}' missing on collection '${collection}'`,
        );
      }
    }

    // Statistiques de la base
    const stats = await this.db.stats();
    console.log(`📊 Database '${this.config.dbName}' initialized:`);
    console.log(`   - Collections: ${existingCollections.length}`);
    console.log(
      `   - Storage size: ${Math.round(stats.storageSize / 1024)} KB`,
    );

    console.log('✅ Database configuration validation completed');
  }

  private async disconnect(): Promise<void> {
    if (this.client) {
      await this.client.close();
      console.log('📡 Disconnected from MongoDB');
    }
  }
}

// Fonction principale d'exécution
async function main() {
  const initializer = new DatabaseInitializer();

  try {
    await initializer.initialize();
    console.log('🎉 Database initialization completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('💥 Database initialization failed:', error);
    process.exit(1);
  }
}

// Exécuter si appelé directement
if (require.main === module) {
  main();
}

export { DatabaseInitializer };
