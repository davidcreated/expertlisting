import { describeTarget, pool, query } from '../src/db.js';

async function main() {
  const target = describeTarget();
  console.log('Connecting to:');
  console.log(`  host     ${target.host}`);
  console.log(`  port     ${target.port}`);
  console.log(`  database ${target.database}`);
  console.log(`  user     ${target.user}`);
  console.log('');

  const started = Date.now();
  const version = await query(
    'select version() as version, current_database() as db, now() as at',
  );
  const elapsed = Date.now() - started;

  const row = version.rows[0];
  console.log('CONNECTED');
  console.log(`  round trip   ${elapsed}ms`);
  console.log(`  database     ${row.db}`);
  console.log(`  server time  ${row.at.toISOString()}`);
  console.log(`  version      ${row.version.split(' on ')[0]}`);
  console.log('');

  const tables = await query(
    `select table_name
       from information_schema.tables
      where table_schema = 'public'
      order by table_name`,
  );

  if (tables.rowCount === 0) {
    console.log('public schema is empty. Run: npm run db:migrate');
  } else {
    console.log(`public tables (${tables.rowCount}):`);
    for (const { table_name: name } of tables.rows) {
      const count = await query(`select count(*)::int as n from "${name}"`);
      console.log(`  ${name.padEnd(14)} ${count.rows[0].n} rows`);
    }
  }
}

main()
  .then(() => pool.end())
  .catch((error) => {
    console.error('FAILED');
    console.error(`  ${error.message}`);
    if (error.code) console.error(`  code: ${error.code}`);
    pool.end();
    process.exitCode = 1;
  });
