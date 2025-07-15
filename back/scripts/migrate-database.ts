import * as dotenv from 'dotenv';
dotenv.config();

import { MongoClient } from 'mongodb';

const uri = process.env.MONGO_URI || 'mongodb://localhost:27017';
const dbName = 'plany';

async function addActiveToCategories(db: any) {
  await db
    .collection('categories')
    .updateMany({ active: { $exists: false } }, { $set: { active: true } });
  console.log("Champ 'active' ajouté à categories.");
}

async function renameUserField(db: any) {
  // Exemple : renommer 'photoUrl' en 'avatarUrl' dans users
  await db
    .collection('users')
    .updateMany({ photoUrl: { $exists: true } }, [
      { $set: { avatarUrl: '$photoUrl' } },
      { $unset: 'photoUrl' },
    ]);
  console.log("Champ 'photoUrl' renommé en 'avatarUrl' dans users.");
}

async function removeObsoleteField(db: any) {
  // Exemple : supprimer un champ obsolète 'oldField' dans plans
  await db.collection('plans').updateMany({}, { $unset: { oldField: '' } });
  console.log("Champ 'oldField' supprimé de plans.");
}

async function main() {
  const client = new MongoClient(uri);
  await client.connect();
  const db = client.db(dbName);

  const arg = process.argv[2];

  if (!arg) {
    console.log(
      'Usage: ts-node migrate-database.ts [all|categories-active|rename-user-photo|remove-obsolete]',
    );
    await client.close();
    process.exit(1);
  }

  if (arg === 'all' || arg === 'categories-active')
    await addActiveToCategories(db);
  if (arg === 'all' || arg === 'rename-user-photo') await renameUserField(db);
  if (arg === 'all' || arg === 'remove-obsolete') await removeObsoleteField(db);

  await client.close();
  console.log('Migration(s) appliquée(s).');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
