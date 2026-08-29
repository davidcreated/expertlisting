import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { after, before, describe, test } from 'node:test';
import { fileURLToPath } from 'node:url';

import { PGlite } from '@electric-sql/pglite';

import { decodeCursor, encodeCursor } from '../src/cursor.js';
import { mapPostRow, POST_SELECT } from '../src/queries/post_query.js';

const here = dirname(fileURLToPath(import.meta.url));

let db;
let users;
let posts;

async function insertUser(name, username, role = null) {
  const result = await db.query(
    `insert into users (name, username, avatar_url, role)
     values ($1, $2, $3, $4) returning id`,
    [name, username, `https://example.com/${username}.jpg`, role],
  );
  return result.rows[0].id;
}

async function insertPost(fields) {
  const result = await db.query(
    `insert into posts
       (author_id, category, body, location, transaction_type, view_count, created_at)
     values ($1, $2, $3, $4, $5, $6, $7)
     returning id`,
    [
      fields.authorId,
      fields.category,
      fields.body,
      fields.location ?? null,
      fields.transactionType ?? null,
      fields.viewCount ?? 0,
      fields.createdAt,
    ],
  );
  return result.rows[0].id;
}

async function selectFeed({ viewerId, where = '', params = [], limit = 10 }) {
  const all = [viewerId, ...params, limit];
  const result = await db.query(
    `${POST_SELECT}
     ${where ? `where ${where}` : ''}
     order by p.created_at desc, p.id desc
     limit $${all.length}`,
    all,
  );
  return result.rows.map(mapPostRow);
}

before(async () => {
  db = new PGlite();
  const migration = await readFile(
    join(here, '..', 'migrations', '001_init.sql'),
    'utf8',
  );
  await db.exec(migration);

  users = {
    me: await insertUser('David Roberts', 'david.r', 'AGENT'),
    boyd: await insertUser('Boyd From', 'boyd.from', 'DEVELOPER'),
    tunde: await insertUser('Tunde Bakare', 'tunde_b'),
    amaka: await insertUser('Amaka Eze', 'amaka.eze', 'AGENT'),
    jordan: await insertUser('Jordan', 'jordan.a'),
    miracle: await insertUser('Miracle Hassan', 'miracle.h'),
  };

  posts = {
    oldest: await insertPost({
      authorId: users.boyd,
      category: 'GENERAL',
      body: 'Oldest post in the feed.',
      createdAt: '2026-08-20T09:00:00.000Z',
    }),
    request: await insertPost({
      authorId: users.amaka,
      category: 'REQUEST',
      body: 'Looking for a 2 bedroom in Yaba.',
      location: 'Yaba, Lagos',
      transactionType: 'LOOKING_TO_RENT',
      createdAt: '2026-08-24T09:00:00.000Z',
    }),
    property: await insertPost({
      authorId: users.boyd,
      category: 'PROPERTY',
      body: 'Newly serviced 3 bedroom apartment.',
      location: 'Lekki Phase 1, Lagos',
      transactionType: 'FOR_RENT',
      viewCount: 1000,
      createdAt: '2026-08-28T09:00:00.000Z',
    }),
  };

  await db.query(
    `insert into post_media (post_id, url, kind, aspect_ratio, position)
     values ($1, $2, 'IMAGE', 1.05, 0)`,
    [posts.property, 'https://example.com/card.png'],
  );

  const likers = [users.miracle, users.tunde, users.jordan, users.amaka];
  for (const [index, userId] of likers.entries()) {
    await db.query(
      `insert into likes (post_id, user_id, created_at) values ($1, $2, $3)`,
      [
        posts.property,
        userId,
        new Date(Date.parse('2026-08-28T10:00:00.000Z') + index * 60000)
          .toISOString(),
      ],
    );
  }

  await db.query(
    `insert into bookmarks (post_id, user_id) values ($1, $2)`,
    [posts.property, users.me],
  );

  await db.query(
    `insert into comments (post_id, author_id, body, created_at)
     values ($1, $2, $3, $4), ($1, $5, $6, $7)`,
    [
      posts.property,
      users.tunde,
      'Is the inspection fee refundable?',
      '2026-08-28T11:00:00.000Z',
      users.amaka,
      'Sending this to a client now.',
      '2026-08-28T12:00:00.000Z',
    ],
  );
});

after(async () => {
  await db.close();
});

describe('feed query', () => {
  test('returns posts newest first with the full client contract', async () => {
    const rows = await selectFeed({ viewerId: users.me });

    assert.equal(rows.length, 3);
    assert.equal(rows[0].id, posts.property);
    assert.equal(rows[2].id, posts.oldest);

    const post = rows[0];
    for (const field of [
      'id',
      'author',
      'category',
      'body',
      'location',
      'transactionType',
      'media',
      'createdAt',
      'likeCount',
      'commentCount',
      'viewCount',
      'bookmarkCount',
      'isLiked',
      'isBookmarked',
      'likedBy',
      'topComment',
    ]) {
      assert.ok(field in post, `missing field ${field}`);
    }

    assert.equal(post.category, 'PROPERTY');
    assert.equal(post.transactionType, 'FOR_RENT');
    assert.equal(post.viewCount, 1000);
    assert.equal(post.author.username, 'boyd.from');
    assert.equal(post.author.role, 'DEVELOPER');
  });

  test('counts come from the join tables, not from columns', async () => {
    const [post] = await selectFeed({
      viewerId: users.me,
      where: 'p.id = $2',
      params: [posts.property],
    });

    assert.equal(post.likeCount, 4);
    assert.equal(post.commentCount, 2);
    assert.equal(post.bookmarkCount, 1);
  });

  test('viewer state is per viewer', async () => {
    const [asMe] = await selectFeed({
      viewerId: users.me,
      where: 'p.id = $2',
      params: [posts.property],
    });
    const [asTunde] = await selectFeed({
      viewerId: users.tunde,
      where: 'p.id = $2',
      params: [posts.property],
    });

    assert.equal(asMe.isLiked, false);
    assert.equal(asMe.isBookmarked, true);
    assert.equal(asTunde.isLiked, true);
    assert.equal(asTunde.isBookmarked, false);
  });

  test('likedBy previews at most three of the most recent likers', async () => {
    const [post] = await selectFeed({
      viewerId: users.me,
      where: 'p.id = $2',
      params: [posts.property],
    });

    assert.equal(post.likedBy.length, 3);
    assert.equal(post.likedBy[0].username, 'amaka.eze');
    assert.ok(post.likeCount > post.likedBy.length);
  });

  test('topComment is the most recent comment', async () => {
    const [post] = await selectFeed({
      viewerId: users.me,
      where: 'p.id = $2',
      params: [posts.property],
    });

    assert.equal(post.topComment.body, 'Sending this to a client now.');
    assert.equal(post.topComment.author.username, 'amaka.eze');
    assert.equal(post.topComment.postId, posts.property);
  });

  test('media aspectRatio is a number, not a numeric string', async () => {
    const [post] = await selectFeed({
      viewerId: users.me,
      where: 'p.id = $2',
      params: [posts.property],
    });

    assert.equal(post.media.length, 1);
    assert.equal(typeof post.media[0].aspectRatio, 'number');
    assert.equal(post.media[0].aspectRatio, 1.05);
    assert.equal(post.media[0].kind, 'IMAGE');
  });

  test('a post with no media, likes or comments returns empty collections',
    async () => {
      const [post] = await selectFeed({
        viewerId: users.me,
        where: 'p.id = $2',
        params: [posts.oldest],
      });

      assert.deepEqual(post.media, []);
      assert.deepEqual(post.likedBy, []);
      assert.equal(post.topComment, null);
      assert.equal(post.likeCount, 0);
      assert.equal(post.isLiked, false);
      assert.equal(post.location, null);
      assert.equal(post.transactionType, null);
    });
});

describe('keyset pagination', () => {
  test('a cursor returns strictly older posts with no overlap', async () => {
    const firstPage = await selectFeed({ viewerId: users.me, limit: 1 });
    assert.equal(firstPage.length, 1);
    assert.equal(firstPage[0].id, posts.property);

    const raw = await db.query(
      'select id, created_at from posts where id = $1',
      [posts.property],
    );
    const cursor = encodeCursor(raw.rows[0]);
    const decoded = decodeCursor(cursor);

    const secondPage = await selectFeed({
      viewerId: users.me,
      where: '(p.created_at, p.id) < ($2::timestamptz, $3::uuid)',
      params: [decoded.createdAt, decoded.id],
      limit: 10,
    });

    assert.equal(secondPage.length, 2);
    assert.ok(!secondPage.some((post) => post.id === posts.property));
    assert.equal(secondPage[0].id, posts.request);
  });

  test('cursors round trip and reject malformed input', () => {
    const row = { id: 'a3f1c2d4-0000-4000-8000-000000000000', created_at: new Date('2026-08-28T09:00:00.000Z') };
    const decoded = decodeCursor(encodeCursor(row));

    assert.equal(decoded.id, row.id);
    assert.equal(decoded.createdAt, '2026-08-28T09:00:00.000Z');

    assert.equal(decodeCursor('not-a-cursor'), null);
    assert.equal(decodeCursor(''), null);
    assert.equal(decodeCursor(undefined), null);
  });
});

describe('filters', () => {
  test('category filter narrows the feed', async () => {
    const rows = await selectFeed({
      viewerId: users.me,
      where: 'p.category = any($2)',
      params: [['PROPERTY']],
    });

    assert.equal(rows.length, 1);
    assert.equal(rows[0].id, posts.property);
  });

  test('transaction type filter narrows the feed', async () => {
    const rows = await selectFeed({
      viewerId: users.me,
      where: 'p.transaction_type = any($2)',
      params: [['LOOKING_TO_RENT']],
    });

    assert.equal(rows.length, 1);
    assert.equal(rows[0].id, posts.request);
  });

  test('location filter is case insensitive and partial', async () => {
    const rows = await selectFeed({
      viewerId: users.me,
      where: 'p.location ilike $2',
      params: ['%lekki%'],
    });

    assert.equal(rows.length, 1);
    assert.equal(rows[0].id, posts.property);
  });

  test('combined filters that match nothing return an empty feed', async () => {
    const rows = await selectFeed({
      viewerId: users.me,
      where: 'p.category = any($2) and p.transaction_type = any($3)',
      params: [['PROPERTY'], ['FOR_SALE']],
    });

    assert.deepEqual(rows, []);
  });
});

describe('schema constraints', () => {
  test('username is unique regardless of case', async () => {
    await assert.rejects(() => insertUser('Impostor', 'DAVID.R'));
  });

  test('a like cannot be recorded twice for the same viewer', async () => {
    await assert.rejects(() =>
      db.query('insert into likes (post_id, user_id) values ($1, $2)', [
        posts.property,
        users.tunde,
      ]),
    );
  });

  test('an unsupported transaction type is rejected', async () => {
    await assert.rejects(() =>
      insertPost({
        authorId: users.me,
        category: 'PROPERTY',
        body: 'Rent to own scheme.',
        transactionType: 'RENT_TO_OWN',
        createdAt: '2026-08-28T09:00:00.000Z',
      }),
    );
  });

  test('an empty body is rejected', async () => {
    await assert.rejects(() =>
      insertPost({
        authorId: users.me,
        category: 'GENERAL',
        body: '   ',
        createdAt: '2026-08-28T09:00:00.000Z',
      }),
    );
  });

  test('deleting a post removes its comments and likes', async () => {
    const throwaway = await insertPost({
      authorId: users.me,
      category: 'GENERAL',
      body: 'Temporary post.',
      createdAt: '2026-08-19T09:00:00.000Z',
    });

    await db.query('insert into likes (post_id, user_id) values ($1, $2)', [
      throwaway,
      users.tunde,
    ]);
    await db.query(
      'insert into comments (post_id, author_id, body) values ($1, $2, $3)',
      [throwaway, users.tunde, 'Temporary comment.'],
    );

    await db.query('delete from posts where id = $1', [throwaway]);

    const likes = await db.query('select 1 from likes where post_id = $1', [
      throwaway,
    ]);
    const comments = await db.query(
      'select 1 from comments where post_id = $1',
      [throwaway],
    );

    assert.equal(likes.rows.length, 0);
    assert.equal(comments.rows.length, 0);
  });
});
