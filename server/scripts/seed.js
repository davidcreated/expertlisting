import { pool, query, withTransaction } from '../src/db.js';

const USERS = [
  { key: 'me', name: 'David Roberts', username: 'david.r', img: 13, role: 'AGENT' },
  { key: 'felix', name: 'Felix Okon', username: 'felix.okon', img: 12, role: null },
  { key: 'maurice', name: 'Maurice U', username: 'maurice.u', img: 45, role: null },
  { key: 'boyd', name: 'Boyd From', username: 'boyd.from', img: 33, role: 'DEVELOPER' },
  { key: 'tunde', name: 'Tunde Bakare', username: 'tunde_b', img: 15, role: null },
  { key: 'amaka', name: 'Amaka Eze', username: 'amaka.eze', img: 47, role: 'AGENT' },
  { key: 'ramos', name: 'RamosRealty', username: 'ramosrealty', img: 68, role: 'DEVELOPER' },
  { key: 'jordan', name: 'Jordan', username: 'jordan.a', img: 11, role: null },
  { key: 'taylor', name: 'Taylor', username: 'taylor.w', img: 52, role: null },
  { key: 'jamie', name: 'Jamie', username: 'jamie.k', img: 14, role: null },
  { key: 'chidi', name: 'Chidi Nwosu', username: 'chidi.n', img: 60, role: 'BROKER' },
  { key: 'miracle', name: 'Miracle Hassan', username: 'miracle.h', img: 49, role: null },
];

const LEKKI = 'Lekki Phase 1, Lagos';
const YABA = 'Yaba, Lagos';
const IKOYI = 'Ikoyi, Lagos';
const AJAH = 'Ajah, Lagos';

const UNSPLASH = (id, width = 1000) =>
  `https://images.unsplash.com/photo-${id}?w=${width}&q=80`;

const minutes = (n) => n * 60 * 1000;
const hours = (n) => minutes(60) * n;
const days = (n) => hours(24) * n;

const POSTS = [
  {
    author: 'felix',
    category: 'REQUEST',
    body:
      'Looking for a 2-bedroom apartment in Yaba or Akoka. Must have constant ' +
      'water and parking for one car.',
    location: LEKKI,
    transactionType: 'LOOKING_TO_BUY',
    ago: minutes(1),
    likes: ['miracle'],
    views: 0,
  },
  {
    author: 'maurice',
    category: 'GENERAL',
    body:
      'How is everyone holding up with the flooding in Lekki this week? Stay ' +
      'safe out there and let me know if anyone needs a temporary place to crash.',
    location: LEKKI,
    ago: minutes(2),
    views: 700,
    likes: ['miracle', 'tunde', 'jordan', 'amaka', 'chidi', 'taylor', 'jamie', 'ramos'],
    bookmarks: ['me', 'amaka'],
    comments: [
      { author: 'tunde', body: 'Roads around Admiralty are still bad. Thanks for checking in.', ago: minutes(12) },
      { author: 'amaka', body: 'We have two spare rooms in Ikate if anyone is stuck tonight.', ago: minutes(26) },
      { author: 'jordan', body: 'Water finally went down on my street this morning.', ago: minutes(41) },
      { author: 'chidi', body: 'Avoid the Admiralty Way stretch, still waist deep.', ago: hours(1) },
      { author: 'taylor', body: 'Sharing this with my estate group, thank you.', ago: hours(2) },
      { author: 'jamie', body: 'Stay safe everyone.', ago: hours(3) },
      { author: 'ramos', body: 'Our Lekki site is closed today for safety.', ago: hours(4) },
      { author: 'felix', body: 'Appreciate the update.', ago: hours(5) },
    ],
  },
  {
    author: 'boyd',
    category: 'PROPERTY',
    body:
      'Newly serviced 3-bedroom apartment with fitted kitchen, parking for 3 ' +
      'cars, and 24/7 power. Inspection opens this Saturday.',
    location: LEKKI,
    transactionType: 'FOR_RENT',
    ago: hours(2),
    views: 1000,
    media: [{ url: UNSPLASH('1600585154340-be6161a56a0c'), aspectRatio: 1.05 }],
    likes: ['miracle', 'tunde', 'jordan', 'amaka', 'chidi', 'taylor', 'jamie', 'ramos', 'felix', 'maurice', 'me'],
    bookmarks: ['me', 'jordan'],
  },
  {
    author: 'felix',
    category: 'REQUEST',
    body:
      'Looking for a 2-bedroom apartment in Yaba or Akoka. Must have constant ' +
      'water and parking for one car. Moving in by the end of next month.',
    location: YABA,
    transactionType: 'LOOKING_TO_RENT',
    ago: hours(22),
    likes: ['miracle'],
    views: 0,
  },
  {
    author: 'felix',
    category: 'PROPERTY',
    body:
      'New 2-bedroom apartment in Yaba with constant water, parking for one ' +
      'car and a fitted kitchen. Inspection opens this Saturday.',
    location: YABA,
    transactionType: 'FOR_SALE',
    ago: days(3),
    views: 2400,
    media: [
      { url: UNSPLASH('1586023492125-27b2c045efd7'), kind: 'VIDEO', aspectRatio: 1.1 },
    ],
    likes: ['miracle', 'tunde', 'jordan', 'amaka', 'chidi', 'taylor', 'jamie', 'ramos', 'boyd', 'maurice', 'me', 'jamie'],
    bookmarks: ['me'],
    comments: [
      { author: 'amaka', body: 'Is the price negotiable?', ago: days(2) },
      { author: 'jordan', body: 'Sent you a message about inspection.', ago: days(2) + hours(4) },
      { author: 'tunde', body: 'Does it come with a BQ?', ago: days(2) + hours(9) },
    ],
  },
  {
    author: 'amaka',
    category: 'PROPERTY',
    body:
      'Just listed: 4-bedroom semi detached duplex in Ikoyi. BQ, elevator ' +
      'access and a shared pool. Serious enquiries only.',
    location: IKOYI,
    transactionType: 'FOR_SALE',
    ago: days(4),
    views: 5200,
    media: [{ url: UNSPLASH('1600596542815-ffad4c1539a9'), aspectRatio: 1.2 }],
    likes: ['miracle', 'tunde', 'jordan', 'chidi', 'taylor', 'jamie', 'ramos', 'boyd', 'maurice', 'me', 'felix'],
    bookmarks: ['me', 'jordan', 'taylor'],
    comments: [
      { author: 'chidi', body: 'I have a client for this. Calling you now.', ago: days(3) },
      { author: 'boyd', body: 'Clean finish. Well done.', ago: days(3) + hours(6) },
      { author: 'taylor', body: 'What is the service charge like?', ago: days(3) + hours(11) },
      { author: 'jamie', body: 'Is the pool shared with the next block?', ago: days(3) + hours(15) },
      { author: 'felix', body: 'Beautiful property.', ago: days(3) + hours(20) },
      { author: 'maurice', body: 'Ikoyi prices are wild these days.', ago: days(4) },
    ],
  },
  {
    author: 'chidi',
    category: 'REQUEST',
    body:
      'Client needs a mini flat around Ajah, budget is 1.2m annually. Water ' +
      'and light must be steady. Who has something?',
    location: AJAH,
    transactionType: 'LOOKING_TO_RENT',
    ago: days(5),
    views: 320,
    likes: ['tunde', 'jordan', 'amaka', 'taylor'],
    comments: [
      { author: 'taylor', body: 'I have a mini flat in Badore, slightly above that budget.', ago: days(4) },
      { author: 'amaka', body: 'Sending you two options now.', ago: days(4) + hours(8) },
    ],
  },
  {
    author: 'ramos',
    category: 'PROPERTY',
    body:
      'Off plan units now open at our Ajah development. 2 and 3 bedroom flats, ' +
      'flexible payment over 18 months.',
    location: AJAH,
    transactionType: 'FOR_SALE',
    ago: days(6),
    views: 12400,
    media: [{ url: UNSPLASH('1512917774080-9991f1c4c750'), aspectRatio: 1.15 }],
    likes: ['miracle', 'tunde', 'jordan', 'amaka', 'chidi', 'taylor', 'jamie', 'boyd', 'maurice', 'me', 'felix'],
    bookmarks: ['me', 'jordan', 'taylor', 'jamie'],
  },
  {
    author: 'maurice',
    category: 'GENERAL',
    body:
      'Reminder for anyone renting this season: always confirm the agent is ' +
      'registered before you pay an inspection fee.',
    ago: days(7),
    views: 8900,
    likes: ['miracle', 'tunde', 'jordan', 'amaka', 'chidi', 'taylor', 'jamie', 'ramos', 'boyd', 'me', 'felix'],
    bookmarks: ['me', 'amaka', 'chidi'],
    comments: [
      { author: 'chidi', body: 'This cannot be said enough.', ago: days(6) },
      { author: 'amaka', body: 'Ask for the CAC registration too.', ago: days(6) + hours(5) },
    ],
  },
  {
    author: 'jordan',
    category: 'REQUEST',
    body:
      'Looking to buy land in Ibeju Lekki with a clean title. Governor consent ' +
      'preferred, budget up to 25m.',
    location: 'Ibeju Lekki, Lagos',
    transactionType: 'LOOKING_TO_BUY',
    ago: days(9),
    views: 640,
    likes: ['tunde', 'amaka', 'chidi', 'me', 'miracle', 'felix'],
    comments: [
      { author: 'chidi', body: 'I have two plots with C of O. Will send details.', ago: days(8) },
    ],
  },
  {
    author: 'taylor',
    category: 'PROPERTY',
    body:
      'Short let studio in Victoria Island available from next week. Fully ' +
      'furnished, 24/7 power, secure estate.',
    location: 'Victoria Island, Lagos',
    transactionType: 'FOR_RENT',
    ago: days(11),
    views: 2100,
    media: [{ url: UNSPLASH('1522708323590-d24dbb6b0267'), aspectRatio: 1.3 }],
    likes: ['miracle', 'tunde', 'jordan', 'amaka', 'chidi', 'jamie', 'ramos', 'boyd', 'me'],
    bookmarks: ['me', 'jordan'],
    comments: [
      { author: 'jamie', body: 'What is the nightly rate?', ago: days(10) },
    ],
  },
  {
    author: 'amaka',
    category: 'GENERAL',
    body:
      'Market note: rents around Lekki Phase 1 have moved about 15% since ' +
      'January. Plan renewals early.',
    location: LEKKI,
    ago: days(13),
    views: 6700,
    likes: ['miracle', 'tunde', 'jordan', 'chidi', 'taylor', 'jamie', 'ramos', 'boyd', 'maurice', 'me'],
    bookmarks: ['me', 'felix'],
  },
  {
    author: 'jamie',
    category: 'REQUEST',
    body:
      'Anyone with a 3-bedroom in Surulere for a family relocating from Abuja? ' +
      'Needed by month end.',
    location: 'Surulere, Lagos',
    transactionType: 'LOOKING_TO_RENT',
    ago: days(15),
    views: 280,
    likes: ['jordan', 'amaka', 'me'],
  },
  {
    author: 'boyd',
    category: 'PROPERTY',
    body:
      'Terrace units in Ikoyi, ready for occupancy. Fitted wardrobes, ample ' +
      'parking, dedicated transformer.',
    location: IKOYI,
    transactionType: 'FOR_RENT',
    ago: days(18),
    views: 4300,
    media: [{ url: UNSPLASH('1560448204-e02f11c3d0e2'), aspectRatio: 1.25 }],
    likes: ['miracle', 'tunde', 'jordan', 'amaka', 'chidi', 'taylor', 'jamie', 'ramos', 'me'],
    bookmarks: ['me', 'amaka'],
  },
];

async function main() {
  const now = Date.now();

  await withTransaction(async (client) => {
    console.log('Clearing existing rows');
    await client.query('truncate bookmarks, likes, comments, post_media, posts, users cascade');

    const userIds = new Map();

    for (const user of USERS) {
      const inserted = await client.query(
        `insert into users (name, username, avatar_url, role)
         values ($1, $2, $3, $4)
         returning id`,
        [
          user.name,
          user.username,
          `https://i.pravatar.cc/200?img=${user.img}`,
          user.role,
        ],
      );
      userIds.set(user.key, inserted.rows[0].id);
    }
    console.log(`Inserted ${userIds.size} users`);

    let postCount = 0;
    let commentCount = 0;
    let likeCount = 0;
    let bookmarkCount = 0;
    let mediaCount = 0;

    for (const post of POSTS) {
      const createdAt = new Date(now - post.ago).toISOString();

      const inserted = await client.query(
        `insert into posts
           (author_id, category, body, location, transaction_type, view_count, created_at)
         values ($1, $2, $3, $4, $5, $6, $7)
         returning id`,
        [
          userIds.get(post.author),
          post.category,
          post.body,
          post.location ?? null,
          post.transactionType ?? null,
          post.views ?? 0,
          createdAt,
        ],
      );

      const postId = inserted.rows[0].id;
      postCount += 1;

      for (const [index, item] of (post.media ?? []).entries()) {
        await client.query(
          `insert into post_media (post_id, url, kind, aspect_ratio, position)
           values ($1, $2, $3, $4, $5)`,
          [postId, item.url, item.kind ?? 'IMAGE', item.aspectRatio ?? 1, index],
        );
        mediaCount += 1;
      }

      const likers = [...new Set(post.likes ?? [])];
      for (const [index, key] of likers.entries()) {
        await client.query(
          `insert into likes (post_id, user_id, created_at)
           values ($1, $2, $3)
           on conflict do nothing`,
          [
            postId,
            userIds.get(key),
            new Date(now - post.ago + minutes(index + 1)).toISOString(),
          ],
        );
        likeCount += 1;
      }

      for (const key of [...new Set(post.bookmarks ?? [])]) {
        await client.query(
          `insert into bookmarks (post_id, user_id) values ($1, $2)
           on conflict do nothing`,
          [postId, userIds.get(key)],
        );
        bookmarkCount += 1;
      }

      for (const comment of post.comments ?? []) {
        await client.query(
          `insert into comments (post_id, author_id, body, created_at)
           values ($1, $2, $3, $4)`,
          [
            postId,
            userIds.get(comment.author),
            comment.body,
            new Date(now - comment.ago).toISOString(),
          ],
        );
        commentCount += 1;
      }
    }

    console.log(`Inserted ${postCount} posts`);
    console.log(`Inserted ${mediaCount} media items`);
    console.log(`Inserted ${likeCount} likes`);
    console.log(`Inserted ${bookmarkCount} bookmarks`);
    console.log(`Inserted ${commentCount} comments`);
  });

  const me = await query(
    "select id, username from users where username = 'david.r'",
  );
  console.log(`\nMocked current user: ${me.rows[0].username} (${me.rows[0].id})`);
}

main()
  .then(() => pool.end())
  .catch((error) => {
    console.error(`Seed failed: ${error.message}`);
    pool.end();
    process.exitCode = 1;
  });
