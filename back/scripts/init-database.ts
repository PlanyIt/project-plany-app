import * as dotenv from 'dotenv';
dotenv.config();

import { MongoClient } from 'mongodb';

const uri = process.env.MONGO_URI || 'mongodb://localhost:27017';
const dbName = 'plany';

async function main() {
  const client = new MongoClient(uri);
  await client.connect();
  const db = client.db(dbName);

  const collections = await db.listCollections().toArray();
  const names = collections.map((c) => c.name);

  const required = ['categories', 'steps', 'users', 'plans', 'comments'];
  for (const name of required) {
    if (!names.includes(name)) {
      await db.createCollection(name);
      console.log(`Collection ${name} créée.`);
    }
  }

  await client.close();
  console.log('Initialisation terminée.');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
