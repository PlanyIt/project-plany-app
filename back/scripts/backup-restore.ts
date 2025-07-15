import { execSync } from 'child_process';
import * as path from 'path';
import * as fs from 'fs';

const dbName = 'plany';
const backupDir = path.resolve(__dirname, '../../backups');

function ensureBackupDir() {
  if (!fs.existsSync(backupDir)) fs.mkdirSync(backupDir, { recursive: true });
}

function backup() {
  ensureBackupDir();
  const date = new Date().toISOString().replace(/[:.]/g, '-');
  const out = path.join(backupDir, `backup-${date}`);
  execSync(`mongodump --db=${dbName} --out="${out}"`, { stdio: 'inherit' });
  console.log(`Backup créé: ${out}`);
}

function restore() {
  ensureBackupDir();
  const backups = fs
    .readdirSync(backupDir)
    .filter((f) => f.startsWith('backup-'));
  if (backups.length === 0) {
    console.error('Aucun backup trouvé.');
    process.exit(1);
  }
  const last = backups.sort().reverse()[0];
  const backupPath = path.join(backupDir, last, dbName);
  execSync(`mongorestore --drop --db=${dbName} "${backupPath}"`, {
    stdio: 'inherit',
  });
  console.log(`Backup restauré: ${last}`);
}

function list() {
  ensureBackupDir();
  const backups = fs
    .readdirSync(backupDir)
    .filter((f) => f.startsWith('backup-'));
  if (backups.length === 0) {
    console.log('Aucun backup trouvé.');
    return;
  }
  backups
    .sort()
    .reverse()
    .forEach((b) => console.log(b));
}

const cmd = process.argv[2];
if (cmd === 'backup') backup();
else if (cmd === 'restore') restore();
else if (cmd === 'list') list();
else {
  console.log('Usage: ts-node backup-restore.ts [backup|restore|list]');
  process.exit(1);
}
