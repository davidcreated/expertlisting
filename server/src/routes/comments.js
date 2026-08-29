import { Router } from 'express';

import { decodeCursor, encodeCursor } from '../cursor.js';
import { query } from '../db.js';
import { asyncRoute, badRequest, notFound } from '../errors.js';
import { mapCommentRow } from '../queries/post_query.js';

const DEFAULT_LIMIT = 15;
const MAX_LIMIT = 50;
const MAX_BODY_LENGTH = 1000;

const COMMENT_SELECT = `
  select
    c.id,
    c.post_id,
    c.body,
    c.created_at,
    json_build_object(
      'id', cu.id,
      'name', cu.name,
      'username', cu.username,
      'avatarUrl', cu.avatar_url,
      'role', cu.role
    ) as author
  from comments c
  join users cu on cu.id = c.author_id
`;

async function assertPostExists(postId) {
  const post = await query('select id from posts where id = $1', [postId]);
  if (post.rowCount === 0) throw notFound(`No post with id ${postId}`);
}

const router = Router();

router.get(
  '/:id/comments',
  asyncRoute(async (req, res) => {
    const { id } = req.params;

    let limit = DEFAULT_LIMIT;
    if (req.query.limit !== undefined) {
      const parsed = Number.parseInt(req.query.limit, 10);
      if (Number.isNaN(parsed) || parsed < 1) {
        throw badRequest('limit must be a positive integer');
      }
      limit = Math.min(parsed, MAX_LIMIT);
    }

    if (req.query.cursor && !decodeCursor(req.query.cursor)) {
      throw badRequest('cursor is not a valid pagination cursor');
    }
    const cursor = decodeCursor(req.query.cursor);

    await assertPostExists(id);

    const params = [id];
    let keyset = '';

    if (cursor) {
      params.push(cursor.createdAt, cursor.id);
      keyset =
        `and (c.created_at, c.id) < ` +
        `($${params.length - 1}::timestamptz, $${params.length}::uuid)`;
    }

    params.push(limit + 1);

    const result = await query(
      `${COMMENT_SELECT}
        where c.post_id = $1 ${keyset}
        order by c.created_at desc, c.id desc
        limit $${params.length}`,
      params,
    );

    const hasMore = result.rows.length > limit;
    const rows = hasMore ? result.rows.slice(0, limit) : result.rows;

    res.json({
      data: rows.map(mapCommentRow),
      nextCursor: hasMore ? encodeCursor(rows[rows.length - 1]) : null,
      hasMore,
    });
  }),
);

router.post(
  '/:id/comments',
  asyncRoute(async (req, res) => {
    const { id } = req.params;
    const body = typeof req.body?.body === 'string' ? req.body.body.trim() : '';

    if (body.length === 0) throw badRequest('body is required');
    if (body.length > MAX_BODY_LENGTH) {
      throw badRequest(`body must be ${MAX_BODY_LENGTH} characters or fewer`);
    }

    await assertPostExists(id);

    const inserted = await query(
      `insert into comments (post_id, author_id, body)
       values ($1, $2, $3)
       returning id`,
      [id, req.currentUserId, body],
    );

    const created = await query(`${COMMENT_SELECT} where c.id = $1`, [
      inserted.rows[0].id,
    ]);

    res.status(201).json(mapCommentRow(created.rows[0]));
  }),
);

export default router;
