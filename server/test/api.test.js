import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { after, before, describe, test } from 'node:test';
import { fileURLToPath } from 'node:url';

import { PGlite } from '@electric-sql/pglite';

import { createApp } from '../src/app.js';
import { setExecutor } from '../src/db.js';

const here = dirname(fileURLToPath(import.meta.url));

let db;
let server;
let baseUrl;
let seeded;

async function api(path, options = {}) {
  const response = await fetch(`${baseUrl}${path}`, {
    ...options,
    headers: { 'content-type': 'application/json', ...options.headers },
  });
  const text = await response.text();
  return {
    status: response.status,
    body: text.length > 0 ? JSON.parse(text) : null,
  };
}

before(async () => {
  db = new PGlite();
  setExecutor(db);

  const migration = await readFile(
    join(here, '..', 'migrations', '001_init.sql'),
    'utf8',
  );
  await db.exec(migration);

  const me = await db.query(
    `insert into users (name, username, role)
     values ('David Roberts', 'david.r', 'AGENT') returning id`,
  );
  const boyd = await db.query(
    `insert into users (name, username, role)
     values ('Boyd From', 'boyd.from', 'DEVELOPER') returning id`,
  );

  const postIds = [];
  for (let index = 0; index < 12; index += 1) {
    const created = await db.query(
      `insert into posts (author_id, category, body, location, transaction_type, created_at)
       values ($1, $2, $3, $4, $5, $6) returning id`,
      [
        index % 2 === 0 ? boyd.rows[0].id : me.rows[0].id,
        index % 3 === 0 ? 'PROPERTY' : 'GENERAL',
        `Seeded post number ${index}.`,
        index % 2 === 0 ? 'Lekki Phase 1, Lagos' : 'Yaba, Lagos',
        index % 3 === 0 ? 'FOR_RENT' : null,
        new Date(Date.UTC(2026, 7, 10 + index, 9)).toISOString(),
      ],
    );
    postIds.push(created.rows[0].id);
  }

  seeded = { me: me.rows[0].id, boyd: boyd.rows[0].id, postIds };

  process.env.CURRENT_USER_ID = seeded.me;

  const app = createApp();
  server = app.listen(0);
  await new Promise((resolve) => server.once('listening', resolve));
  baseUrl = `http://127.0.0.1:${server.address().port}`;
});

after(async () => {
  await new Promise((resolve) => server.close(resolve));
  await db.close();
});

describe('GET /posts', () => {
  test('returns a page with the cursor envelope', async () => {
    const { status, body } = await api('/posts?limit=5');

    assert.equal(status, 200);
    assert.equal(body.data.length, 5);
    assert.equal(body.hasMore, true);
    assert.ok(typeof body.nextCursor === 'string');
  });

  test('paginates without repeating or skipping posts', async () => {
    const seen = [];
    let cursor = null;
    let guard = 0;

    do {
      const path = cursor
        ? `/posts?limit=5&cursor=${encodeURIComponent(cursor)}`
        : '/posts?limit=5';
      const { body } = await api(path);
      seen.push(...body.data.map((post) => post.id));
      cursor = body.nextCursor;
      guard += 1;
    } while (cursor && guard < 10);

    assert.equal(seen.length, 12);
    assert.equal(new Set(seen).size, 12);
  });

  test('the last page reports hasMore false and a null cursor', async () => {
    const { body } = await api('/posts?limit=50');

    assert.equal(body.data.length, 12);
    assert.equal(body.hasMore, false);
    assert.equal(body.nextCursor, null);
  });

  test('filters by category', async () => {
    const { body } = await api('/posts?category=PROPERTY&limit=50');

    assert.ok(body.data.length > 0);
    assert.ok(body.data.every((post) => post.category === 'PROPERTY'));
  });

  test('filters by transaction type and location together', async () => {
    const { body } = await api(
      '/posts?transactionType=FOR_RENT&location=lekki&limit=50',
    );

    assert.ok(body.data.length > 0);
    assert.ok(
      body.data.every(
        (post) =>
          post.transactionType === 'FOR_RENT' &&
          post.location.toLowerCase().includes('lekki'),
      ),
    );
  });

  test('an unsupported filter value is rejected with 400', async () => {
    const { status, body } = await api('/posts?category=ANNOUNCEMENT');

    assert.equal(status, 400);
    assert.equal(body.error, 'BAD_REQUEST');
    assert.match(body.message, /ANNOUNCEMENT/);
  });

  test('a malformed cursor is rejected with 400', async () => {
    const { status, body } = await api('/posts?cursor=nonsense');

    assert.equal(status, 400);
    assert.equal(body.error, 'BAD_REQUEST');
  });

  test('a non numeric limit is rejected with 400', async () => {
    const { status } = await api('/posts?limit=abc');
    assert.equal(status, 400);
  });
});

describe('POST /posts/:id/like', () => {
  test('toggles on, then off, and the count follows', async () => {
    const postId = seeded.postIds[0];

    const liked = await api(`/posts/${postId}/like`, { method: 'POST' });
    assert.equal(liked.status, 200);
    assert.equal(liked.body.isLiked, true);
    assert.equal(liked.body.likeCount, 1);

    const unliked = await api(`/posts/${postId}/like`, { method: 'POST' });
    assert.equal(unliked.body.isLiked, false);
    assert.equal(unliked.body.likeCount, 0);
  });

  test('the like is reflected in the feed for the same viewer', async () => {
    const postId = seeded.postIds[1];
    await api(`/posts/${postId}/like`, { method: 'POST' });

    const { body } = await api('/posts?limit=50');
    const post = body.data.find((item) => item.id === postId);

    assert.equal(post.isLiked, true);
    assert.equal(post.likeCount, 1);
    assert.equal(post.likedBy.length, 1);
    assert.equal(post.likedBy[0].username, 'david.r');
  });

  test('liking an unknown post returns 404', async () => {
    const { status, body } = await api(
      '/posts/3f7c1b2e-0000-4000-8000-000000000000/like',
      { method: 'POST' },
    );

    assert.equal(status, 404);
    assert.equal(body.error, 'NOT_FOUND');
  });
});

describe('comments', () => {
  test('posting a comment returns 201 and the created comment', async () => {
    const postId = seeded.postIds[2];

    const { status, body } = await api(`/posts/${postId}/comments`, {
      method: 'POST',
      body: JSON.stringify({ body: 'Is the inspection fee refundable?' }),
    });

    assert.equal(status, 201);
    assert.equal(body.body, 'Is the inspection fee refundable?');
    assert.equal(body.postId, postId);
    assert.equal(body.author.username, 'david.r');
    assert.ok(body.id);
    assert.ok(body.createdAt);
  });

  test('the new comment appears in the list and bumps the feed count',
    async () => {
      const postId = seeded.postIds[2];

      const list = await api(`/posts/${postId}/comments`);
      assert.equal(list.status, 200);
      assert.equal(list.body.data.length, 1);
      assert.equal(list.body.hasMore, false);

      const feed = await api('/posts?limit=50');
      const post = feed.body.data.find((item) => item.id === postId);

      assert.equal(post.commentCount, 1);
      assert.equal(post.topComment.body, 'Is the inspection fee refundable?');
    });

  test('comments paginate newest first', async () => {
    const postId = seeded.postIds[3];

    for (const text of ['first', 'second', 'third']) {
      await api(`/posts/${postId}/comments`, {
        method: 'POST',
        body: JSON.stringify({ body: text }),
      });
    }

    const page = await api(`/posts/${postId}/comments?limit=2`);
    assert.equal(page.body.data.length, 2);
    assert.equal(page.body.hasMore, true);
    assert.equal(page.body.data[0].body, 'third');

    const next = await api(
      `/posts/${postId}/comments?limit=2&cursor=${encodeURIComponent(page.body.nextCursor)}`,
    );
    assert.equal(next.body.data.length, 1);
    assert.equal(next.body.data[0].body, 'first');
    assert.equal(next.body.hasMore, false);
  });

  test('an empty comment body is rejected with 400', async () => {
    const { status, body } = await api(
      `/posts/${seeded.postIds[4]}/comments`,
      { method: 'POST', body: JSON.stringify({ body: '   ' }) },
    );

    assert.equal(status, 400);
    assert.equal(body.error, 'BAD_REQUEST');
  });

  test('commenting on an unknown post returns 404', async () => {
    const { status } = await api(
      '/posts/3f7c1b2e-0000-4000-8000-000000000000/comments',
      { method: 'POST', body: JSON.stringify({ body: 'hello' }) },
    );

    assert.equal(status, 404);
  });
});

describe('POST /posts', () => {
  test('creates a post and returns it in the client contract', async () => {
    const { status, body } = await api('/posts', {
      method: 'POST',
      body: JSON.stringify({
        body: 'Newly listed 2 bedroom in Yaba.',
        category: 'PROPERTY',
        location: 'Yaba, Lagos',
        transactionType: 'FOR_SALE',
        media: [
          { url: 'https://example.com/a.jpg', kind: 'IMAGE', aspectRatio: 1.2 },
        ],
      }),
    });

    assert.equal(status, 201);
    assert.equal(body.category, 'PROPERTY');
    assert.equal(body.transactionType, 'FOR_SALE');
    assert.equal(body.author.username, 'david.r');
    assert.equal(body.media.length, 1);
    assert.equal(body.media[0].aspectRatio, 1.2);
    assert.equal(body.likeCount, 0);
    assert.equal(body.isLiked, false);
  });

  test('the created post is first in the feed', async () => {
    const { body } = await api('/posts?limit=1');
    assert.equal(body.data[0].body, 'Newly listed 2 bedroom in Yaba.');
  });

  test('a post with neither body nor media is rejected', async () => {
    const { status } = await api('/posts', {
      method: 'POST',
      body: JSON.stringify({ body: '  ' }),
    });

    assert.equal(status, 400);
  });

  test('an unsupported transaction type is rejected', async () => {
    const { status, body } = await api('/posts', {
      method: 'POST',
      body: JSON.stringify({ body: 'Rent to own.', transactionType: 'RENT_TO_OWN' }),
    });

    assert.equal(status, 400);
    assert.match(body.message, /transactionType/);
  });
});

describe('routing', () => {
  test('health check responds', async () => {
    const { status, body } = await api('/health');
    assert.equal(status, 200);
    assert.equal(body.status, 'ok');
  });

  test('an unknown route returns a JSON 404', async () => {
    const { status, body } = await api('/nope');
    assert.equal(status, 404);
    assert.equal(body.error, 'NOT_FOUND');
  });
});
