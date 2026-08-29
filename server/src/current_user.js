import { query } from './db.js';

const FALLBACK_USERNAME = 'david.r';

let cachedUserId = null;

export async function resolveCurrentUserId() {
  if (cachedUserId) return cachedUserId;

  const configured = process.env.CURRENT_USER_ID?.trim();
  if (configured) {
    const found = await query('select id from users where id = $1', [
      configured,
    ]);
    if (found.rowCount === 1) {
      cachedUserId = found.rows[0].id;
      return cachedUserId;
    }
    console.warn(
      `CURRENT_USER_ID ${configured} was not found. Falling back to ${FALLBACK_USERNAME}.`,
    );
  }

  const fallback = await query(
    'select id from users where lower(username) = lower($1)',
    [FALLBACK_USERNAME],
  );

  if (fallback.rowCount === 1) {
    cachedUserId = fallback.rows[0].id;
    return cachedUserId;
  }

  const anyUser = await query(
    'select id from users order by created_at asc limit 1',
  );

  if (anyUser.rowCount === 0) {
    throw new Error(
      'No users in the database. Run npm run db:seed before starting the API.',
    );
  }

  cachedUserId = anyUser.rows[0].id;
  return cachedUserId;
}

export async function attachCurrentUser(req, res, next) {
  try {
    req.currentUserId = await resolveCurrentUserId();
    next();
  } catch (error) {
    next(error);
  }
}
