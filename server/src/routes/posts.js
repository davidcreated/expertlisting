import { Router } from 'express';

import { decodeCursor, encodeCursor } from '../cursor.js';
import { query, withTransaction } from '../db.js';
import { asyncRoute, badRequest, notFound } from '../errors.js';
import { mapPostRow, POST_SELECT } from '../queries/post_query.js';

const CATEGORIES = ['PROPERTY', 'REQUEST', 'GENERAL'];
const TRANSACTION_TYPES = [
  'FOR_SALE',
  'FOR_RENT',
  'LOOKING_TO_BUY',
  'LOOKING_TO_RENT',
];
const MEDIA_KINDS = ['IMAGE', 'VIDEO'];

const DEFAULT_LIMIT = 10;
const MAX_LIMIT = 50;
const MAX_BODY_LENGTH = 2000;
const MAX_MEDIA = 4;

function parseLimit(raw) {
  if (raw === undefined) return DEFAULT_LIMIT;
  const value = Number.parseInt(raw, 10);
  if (Number.isNaN(value) || value < 1) {
    throw badRequest('limit must be a positive integer');
  }
  return Math.min(value, MAX_LIMIT);
}

function parseEnumList(raw, allowed, field) {
  if (!raw) return null;
  const values = String(raw)
    .split(',')
    .map((value) => value.trim().toUpperCase())
    .filter(Boolean);

  if (values.length === 0) return null;

  const invalid = values.filter((value) => !allowed.includes(value));
  if (invalid.length > 0) {
    throw badRequest(
      `${field} contains unsupported values: ${invalid.join(', ')}. ` +
        `Allowed: ${allowed.join(', ')}`,
    );
  }

  return values;
}

const router = Router();

router.get(
  '/',
  asyncRoute(async (req, res) => {
    const limit = parseLimit(req.query.limit);
    const categories = parseEnumList(req.query.category, CATEGORIES, 'category');
    const transactionTypes = parseEnumList(
      req.query.transactionType,
      TRANSACTION_TYPES,
      'transactionType',
    );
    const location = req.query.location?.trim();

    if (req.query.cursor && !decodeCursor(req.query.cursor)) {
      throw badRequest('cursor is not a valid pagination cursor');
    }
    const cursor = decodeCursor(req.query.cursor);

    const params = [req.currentUserId];
    const conditions = [];

    if (categories) {
      params.push(categories);
      conditions.push(`p.category = any($${params.length})`);
    }

    if (transactionTypes) {
      params.push(transactionTypes);
      conditions.push(`p.transaction_type = any($${params.length})`);
    }

    if (location) {
      params.push(`%${location}%`);
      conditions.push(`p.location ilike $${params.length}`);
    }

    if (cursor) {
      params.push(cursor.createdAt, cursor.id);
      conditions.push(
        `(p.created_at, p.id) < ($${params.length - 1}::timestamptz, $${params.length}::uuid)`,
      );
    }

    params.push(limit + 1);

    const sql = `
      ${POST_SELECT}
      ${conditions.length > 0 ? `where ${conditions.join(' and ')}` : ''}
      order by p.created_at desc, p.id desc
      limit $${params.length}
    `;

    const result = await query(sql, params);

    const hasMore = result.rows.length > limit;
    const rows = hasMore ? result.rows.slice(0, limit) : result.rows;

    res.json({
      data: rows.map(mapPostRow),
      nextCursor: hasMore ? encodeCursor(rows[rows.length - 1]) : null,
      hasMore,
    });
  }),
);

router.post(
  '/',
  asyncRoute(async (req, res) => {
    const body = typeof req.body?.body === 'string' ? req.body.body.trim() : '';
    const media = Array.isArray(req.body?.media) ? req.body.media : [];

    if (body.length === 0 && media.length === 0) {
      throw badRequest('A post needs a body or at least one media item');
    }

    if (body.length > MAX_BODY_LENGTH) {
      throw badRequest(`body must be ${MAX_BODY_LENGTH} characters or fewer`);
    }

    if (media.length > MAX_MEDIA) {
      throw badRequest(`A post accepts at most ${MAX_MEDIA} media items`);
    }

    const category = (req.body?.category ?? 'GENERAL').toUpperCase();
    if (!CATEGORIES.includes(category)) {
      throw badRequest(
        `category must be one of ${CATEGORIES.join(', ')}`,
      );
    }

    const transactionTypeRaw = req.body?.transactionType;
    const transactionType = transactionTypeRaw
      ? String(transactionTypeRaw).toUpperCase()
      : null;

    if (transactionType && !TRANSACTION_TYPES.includes(transactionType)) {
      throw badRequest(
        `transactionType must be one of ${TRANSACTION_TYPES.join(', ')}`,
      );
    }

    for (const item of media) {
      if (typeof item?.url !== 'string' || item.url.trim().length === 0) {
        throw badRequest('Every media item needs a url');
      }
      const kind = (item.kind ?? 'IMAGE').toUpperCase();
      if (!MEDIA_KINDS.includes(kind)) {
        throw badRequest(`media kind must be one of ${MEDIA_KINDS.join(', ')}`);
      }
    }

    const location = req.body?.location?.trim() || null;

    const postId = await withTransaction(async (client) => {
      const inserted = await client.query(
        `insert into posts (author_id, category, body, location, transaction_type)
         values ($1, $2, $3, $4, $5)
         returning id`,
        [req.currentUserId, category, body, location, transactionType],
      );

      const id = inserted.rows[0].id;

      for (const [index, item] of media.entries()) {
        await client.query(
          `insert into post_media (post_id, url, kind, aspect_ratio, position)
           values ($1, $2, $3, $4, $5)`,
          [
            id,
            item.url.trim(),
            (item.kind ?? 'IMAGE').toUpperCase(),
            Number(item.aspectRatio) > 0 ? Number(item.aspectRatio) : 1,
            index,
          ],
        );
      }

      return id;
    });

    const created = await query(`${POST_SELECT} where p.id = $2`, [
      req.currentUserId,
      postId,
    ]);

    res.status(201).json(mapPostRow(created.rows[0]));
  }),
);

router.post(
  '/:id/like',
  asyncRoute(async (req, res) => {
    const { id } = req.params;

    const result = await withTransaction(async (client) => {
      const post = await client.query('select id from posts where id = $1', [
        id,
      ]);
      if (post.rowCount === 0) throw notFound(`No post with id ${id}`);

      const deleted = await client.query(
        'delete from likes where post_id = $1 and user_id = $2 returning post_id',
        [id, req.currentUserId],
      );

      if (deleted.rowCount === 0) {
        await client.query(
          `insert into likes (post_id, user_id) values ($1, $2)
           on conflict (post_id, user_id) do nothing`,
          [id, req.currentUserId],
        );
      }

      const count = await client.query(
        'select count(*)::int as n from likes where post_id = $1',
        [id],
      );

      return {
        isLiked: deleted.rowCount === 0,
        likeCount: count.rows[0].n,
      };
    });

    res.json(result);
  }),
);

router.post(
  '/:id/bookmark',
  asyncRoute(async (req, res) => {
    const { id } = req.params;

    const result = await withTransaction(async (client) => {
      const post = await client.query('select id from posts where id = $1', [
        id,
      ]);
      if (post.rowCount === 0) throw notFound(`No post with id ${id}`);

      const deleted = await client.query(
        `delete from bookmarks where post_id = $1 and user_id = $2
         returning post_id`,
        [id, req.currentUserId],
      );

      if (deleted.rowCount === 0) {
        await client.query(
          `insert into bookmarks (post_id, user_id) values ($1, $2)
           on conflict (post_id, user_id) do nothing`,
          [id, req.currentUserId],
        );
      }

      const count = await client.query(
        'select count(*)::int as n from bookmarks where post_id = $1',
        [id],
      );

      return {
        isBookmarked: deleted.rowCount === 0,
        bookmarkCount: count.rows[0].n,
      };
    });

    res.json(result);
  }),
);

export default router;
