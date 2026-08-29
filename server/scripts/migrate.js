import { readdir, readFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import { describeTarget, pool, query } from '../src/db.js';

const here = dirname(fileURLToPath(import.meta.url));
const migrationsDir = join(here, '..', 'migrations');

const DROP_ORDER = [
  'bookmarks',
  'likes',
  'comments',
  'post_media',
  'posts',
  'users',
];

async function reset() {
  console.log('Dropping existing tables');
  for (const table of DROP_ORDER) {
    await query(`drop table if exists ${table} cascade`);
  }
}

async function main() {
  const target = describeTarget();
  console.log(`Target ${target.host}/${target.database}`);

  if (process.argv.includes('--reset')) await reset();

  const files = (await readdir(migrationsDir))
    .filter((name) => name.endsWith('.sql'))
    .sort();

  if (files.length === 0) throw new Error('No migration files found');

  for (const file of files) {
    const sql = await readFile(join(migrationsDir, file), 'utf8');
    process.stdout.write(`Applying ${file} ... `);
    await query(sql);
    console.log('ok');
  }

  const tables = await query(
    `select table_name from information_schema.tables
      where table_schema = 'public' order by table_name`,
  );

  console.log(`\nTables now present (${tables.rowCount}):`);
  for (const row of tables.rows) console.log(`  ${row.table_name}`);
}

main()
  .then(() => pool.end())
  .catch((error) => {
    console.error(`Migration failed: ${error.message}`);
    pool.end();
    process.exitCode = 1;
  });
