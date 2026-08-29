import 'dotenv/config';
import pg from 'pg';

const { Pool } = pg;

let executor = null;

function connectionString() {
  const value = process.env.DATABASE_URL;
  if (!value) {
    throw new Error(
      'DATABASE_URL is not set. Copy server/.env.example to server/.env and add your connection string.',
    );
  }
  return value;
}

function createPool() {
  const url = connectionString();
  const isLocal = url.includes('localhost') || url.includes('127.0.0.1');

  return new Pool({
    connectionString: url,
    ssl: isLocal ? false : { rejectUnauthorized: false },
    max: 10,
    idleTimeoutMillis: 30_000,
    connectionTimeoutMillis: 15_000,
  });
}

function getExecutor() {
  if (!executor) executor = createPool();
  return executor;
}

export function setExecutor(custom) {
  executor = custom;
}

export function query(text, params) {
  return getExecutor().query(text, params);
}

export async function withTransaction(handler) {
  const current = getExecutor();

  if (typeof current.connect !== 'function') {
    await current.query('begin');
    try {
      const result = await handler(current);
      await current.query('commit');
      return result;
    } catch (error) {
      await current.query('rollback');
      throw error;
    }
  }

  const client = await current.connect();
  try {
    await client.query('begin');
    const result = await handler(client);
    await client.query('commit');
    return result;
  } catch (error) {
    await client.query('rollback');
    throw error;
  } finally {
    client.release();
  }
}

export async function closePool() {
  if (executor && typeof executor.end === 'function') await executor.end();
  executor = null;
}

export const pool = {
  end: closePool,
};

export function describeTarget() {
  const url = new URL(connectionString());
  return {
    host: url.hostname,
    port: url.port || '5432',
    database: url.pathname.replace('/', ''),
    user: url.username,
  };
}
