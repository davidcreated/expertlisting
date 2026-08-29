# Expert Listing

A property feed built for the Expert Listing assessment. It has a Flutter mobile client and a Node with Postgres API. Liking a post, viewing and adding comments, filtering the feed and creating a post are all wired to real state, not mocked visuals.

<br>

## What is in the repository

<br>

```
lib/            Flutter client
server/         Node with Express API and Postgres schema
assets/         Icons, images and the Open Runde font
test/           Flutter tests
server/test/    API and schema tests
docs/           Screenshots
```

<br>

## Running it

<br>

### 1. The API

<br>

You need a Postgres database. Supabase works. Copy the example environment file and put your connection string in it.

<br>

```bash
cd server
cp .env.example .env
npm install
```

<br>

Open `server/.env` and set `DATABASE_URL` to your Supabase connection string. Use the session pooler on port 5432 rather than the transaction pooler on 6543, because the migration needs statements the transaction pooler does not allow.

<br>

Then confirm the connection, create the tables and load the sample feed.

<br>

```bash
npm run db:probe
npm run db:migrate
npm run db:seed
npm run dev
```

<br>

`npm run db:probe` prints the host, the server version and a row count for every table, so a bad password or a blocked network shows up immediately with a clear message instead of a stack trace. The API listens on `http://localhost:3000`.

<br>

### 2. The Flutter client

<br>

```bash
flutter pub get
dart run build_runner build
flutter run
```

<br>

The client starts against an in memory repository so it runs with no backend at all. To point it at the API instead:

<br>

```bash
flutter run --dart-define=USE_FAKE_DATA=false --dart-define=API_BASE_URL=http://localhost:3000
```

<br>

On an Android emulator use `http://10.0.2.2:3000` for the base URL.

<br>

### 3. Tests

<br>

```bash
flutter test          # 38 tests
cd server && npm test # 40 tests
```

<br>

The API tests run against PGlite, which is real Postgres compiled to WebAssembly and pulled in as a dev dependency. They apply the same migration file that production uses, so the schema, the feed query, the pagination and every endpoint are exercised without needing a database installed on the machine.

<br>

## Endpoints

<br>

Every response is camelCase JSON. Paginated endpoints return the same envelope: a `data` array, a `nextCursor` string that is null on the last page, and a `hasMore` boolean.

<br>

### GET /posts

<br>

Returns the feed, newest first. Query parameters are all optional.

<br>

`limit` defaults to 10 and is capped at 50.

`cursor` is the opaque `nextCursor` from the previous page.

`category` accepts `PROPERTY`, `REQUEST` or `GENERAL`, comma separated for more than one.

`transactionType` accepts `FOR_SALE`, `FOR_RENT`, `LOOKING_TO_BUY` or `LOOKING_TO_RENT`, comma separated.

`location` is a partial, case insensitive match.

<br>

Each post carries its author, media, counts for likes, comments, views and bookmarks, whether the current user has liked or bookmarked it, a preview of up to three recent likers, and the most recent comment.

<br>

### POST /posts

<br>

Creates a post. Accepts `body`, `category`, `location`, `transactionType` and a `media` array of up to four items. A post needs either a body or at least one media item. Returns 201 with the created post in the same shape the feed uses.

<br>

### POST /posts/:id/like

<br>

Toggles the like for the current user and returns `{ isLiked, likeCount }`. The brief listed one like endpoint rather than a pair, so this single route toggles in both directions and the response is the authority on the result. The client updates optimistically and then reconciles against this response, rolling back if the call fails.

<br>

### GET /posts/:id/comments

<br>

Returns comments newest first, using the same cursor envelope. Accepts `limit` and `cursor`.

<br>

### POST /posts/:id/comments

<br>

Accepts `{ body }` and returns 201 with the created comment.

<br>

### POST /posts/:id/bookmark

<br>

Toggles the bookmark and returns `{ isBookmarked, bookmarkCount }`. This one is not in the brief. I added it because the design shows a bookmark control with a count, and a control that looks saved but saves nothing is worse than no control at all.

<br>

## Database schema

<br>

Six tables. Users, Posts, Comments and Likes are the four the brief asked for. Post media and bookmarks exist because the design needs them.

<br>

```
users
  id uuid primary key
  name text
  username text, unique on lower(username)
  avatar_url text
  role text, one of DEVELOPER, BROKER, AGENT, or null
  created_at timestamptz

posts
  id uuid primary key
  author_id uuid references users on delete cascade
  category text, one of PROPERTY, REQUEST, GENERAL
  body text, must not be blank
  location text
  transaction_type text, one of FOR_SALE, FOR_RENT, LOOKING_TO_BUY, LOOKING_TO_RENT, or null
  view_count integer
  created_at timestamptz

post_media
  id uuid primary key
  post_id uuid references posts on delete cascade
  url text
  kind text, IMAGE or VIDEO
  aspect_ratio numeric
  position integer

comments
  id uuid primary key
  post_id uuid references posts on delete cascade
  author_id uuid references users on delete cascade
  body text, must not be blank
  created_at timestamptz

likes
  post_id uuid references posts on delete cascade
  user_id uuid references users on delete cascade
  created_at timestamptz
  primary key (post_id, user_id)

bookmarks
  post_id uuid references posts on delete cascade
  user_id uuid references users on delete cascade
  created_at timestamptz
  primary key (post_id, user_id)
```

<br>

Notes on the schema. Likes and bookmarks use a composite primary key, so one user cannot like the same post twice and no application code is needed to enforce it. Every count is derived from its table at read time rather than stored in a column, so a count can never drift from the rows it describes. Every child row cascades on delete, so removing a post cleans up its media, comments, likes and bookmarks in one statement. The feed is indexed on `(created_at desc, id desc)`, which is the exact ordering the pagination uses.

<br>

## Pagination

<br>

The feed uses keyset pagination rather than offset. The cursor encodes the `created_at` and `id` of the last row on the page, and the next query asks for rows strictly older than that pair. Offset pagination shifts every row when someone posts while a user is scrolling, which duplicates or skips items. Keyset pagination does not. The id is part of the key so that posts sharing a timestamp still have a stable, total order.

<br>

Endpoints fetch one row more than the requested limit. If that extra row comes back, `hasMore` is true and the extra row is dropped. This means `hasMore` is a fact about the database rather than a guess from the page being full.

<br>

## Client architecture

<br>

The client is organised by feature. Each feature holds its screens at the root with `widgets`, `providers` and `domain` beneath it.

<br>

```
lib/core/       Theme tokens, typed errors, network client, shared widgets
lib/features/
  feed/         The feed screen, the post card and its parts
  comments/     The comments sheet
  filters/      The filters sheet
  composer/     The create post screen
  shell/        The bottom navigation
```

<br>

State is Riverpod with code generation. The data layer sits behind a `PostRepository` interface with two implementations, one backed by the API over Dio and one in memory. A single flag chooses between them, so the client runs with or without a backend and the swap is configuration rather than a code change.

<br>

Likes, bookmarks and comments update optimistically. The widget changes immediately, the request goes out, and the server response replaces the guess. If the request fails the change is reverted and a message is shown. The rollback is covered by tests, because a like that silently stays on after a failed request is the kind of bug that reads as working.

<br>

Every enum crossing the network keeps an explicit mapping between its wire value and its display label, and unknown values parse to null instead of falling into a default. A test asserts every member round trips, so adding a value to the backend without adding it here fails the build rather than silently dropping data.

<br>

## Assumptions

<br>

There is no authentication, so the current user is hardcoded. On the API it resolves from `CURRENT_USER_ID` if set, otherwise from the seeded `david.r` account. On the client it is a constant. Every like, bookmark, comment and post is attributed to that user.

<br>

Stories are presentational. The design shows a story rail, but the brief did not describe stories, so there is no stories table and no endpoint. The rail is served from a provider and shows the seeded users, which keeps the feed screen honest about where its data comes from without inventing a feature.

<br>

View counts are seeded rather than measured. Counting a view needs a definition of what a view is, and the brief did not give one, so the column is populated by the seed and never incremented.

<br>

Two captions in the design contain what looks like a copy and paste artifact, the fragment "month.rviced" in the middle of a sentence. I wrote clean copy for those two posts rather than reproducing the artifact.

<br>

The transaction type chips use tag and key icons that are not in the asset folder, so Material equivalents stand in. The supplied `filter.png` turned out to be a full 95 by 35 pixel pill with its border and label baked in rather than an icon, so the Filters control is rebuilt from the theme and uses a Material icon. The like, comment, share and bookmark icons are 16 pixel exports and have no filled variants, so the provided assets are used for the inactive state and Material fills are used for the active state.

<br>

Colours are taken from the mock. The greys and the chip tints match the Untitled UI ramp exactly, which the watermarks in the mock images corroborate, so those values were used directly rather than sampled by eye from a screenshot.

<br>

## What I skipped

<br>

Authentication, login, email verification and payments are all out of scope per the brief, and none of them are stubbed.

<br>

There is no Redis, no CDN and no image upload service. The composer picks images from the device and sends their local paths. Wiring that to real object storage is the missing piece before this handles uploads for real.

<br>

Video posts render a poster frame with a play control but do not play. The design shows the control, the brief did not ask for playback, and shipping a play button that does nothing when tapped would be the dishonest option, so tapping it does nothing visible rather than pretending to start.

<br>

Search, notifications and the profile tab are not built. Their tabs are in the bottom navigation because the design shows five, and each one states plainly that it is not part of this build rather than showing invented content.

<br>

The API has no rate limiting, no request logging beyond errors, and permissive CORS. All three are deliberate for a local assessment and all three would need attention before this was exposed publicly.

<br>

## Testing

<br>

78 tests in total. They were written to catch the failures that review would miss rather than to cover lines.

<br>

On the client, 38 tests cover the wire value mappings for every enum, parsing a representative payload into a fully populated model, pagination appending without duplicating and stopping at the end, a concurrent load not fetching the same page twice, the optimistic like rolling back on failure, and filters resetting pagination instead of appending to it.

<br>

On the API, 40 tests cover the schema constraints, the feed query shape against the client contract, keyset pagination across every page with no overlap, each filter, the like toggle in both directions, comment pagination, and the validation and not found paths for every endpoint.

<br>

Two real bugs were caught this way. The liked by avatars came back in arbitrary order because `json_agg` does not inherit a subquery ordering, and the optimistic rollback silently did not run when no widget happened to be listening to the mutation provider. Both are fixed and both have a test holding them in place.

<br>

## Screenshots

<br>

See `docs/screenshots`.
