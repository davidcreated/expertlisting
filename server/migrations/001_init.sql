create table if not exists users (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  username    text not null,
  avatar_url  text,
  role        text check (role in ('DEVELOPER', 'BROKER', 'AGENT')),
  created_at  timestamptz not null default now()
);

create unique index if not exists users_username_key
  on users (lower(username));

create table if not exists posts (
  id                uuid primary key default gen_random_uuid(),
  author_id         uuid not null references users (id) on delete cascade,
  category          text not null default 'GENERAL'
                      check (category in ('PROPERTY', 'REQUEST', 'GENERAL')),
  body              text not null check (length(btrim(body)) > 0),
  location          text,
  transaction_type  text check (transaction_type in (
                      'FOR_SALE', 'FOR_RENT', 'LOOKING_TO_BUY', 'LOOKING_TO_RENT'
                    )),
  view_count        integer not null default 0 check (view_count >= 0),
  created_at        timestamptz not null default now()
);

create index if not exists posts_feed_order_idx
  on posts (created_at desc, id desc);

create index if not exists posts_author_idx on posts (author_id);
create index if not exists posts_category_idx on posts (category);
create index if not exists posts_transaction_type_idx on posts (transaction_type);

create table if not exists post_media (
  id            uuid primary key default gen_random_uuid(),
  post_id       uuid not null references posts (id) on delete cascade,
  url           text not null,
  kind          text not null default 'IMAGE' check (kind in ('IMAGE', 'VIDEO')),
  aspect_ratio  numeric(6, 3) not null default 1 check (aspect_ratio > 0),
  position      integer not null default 0
);

create index if not exists post_media_post_idx
  on post_media (post_id, position);

create table if not exists comments (
  id          uuid primary key default gen_random_uuid(),
  post_id     uuid not null references posts (id) on delete cascade,
  author_id   uuid not null references users (id) on delete cascade,
  body        text not null check (length(btrim(body)) > 0),
  created_at  timestamptz not null default now()
);

create index if not exists comments_post_order_idx
  on comments (post_id, created_at desc, id desc);

create table if not exists likes (
  post_id     uuid not null references posts (id) on delete cascade,
  user_id     uuid not null references users (id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (post_id, user_id)
);

create index if not exists likes_user_idx on likes (user_id);
create index if not exists likes_post_recent_idx
  on likes (post_id, created_at desc);

create table if not exists bookmarks (
  post_id     uuid not null references posts (id) on delete cascade,
  user_id     uuid not null references users (id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (post_id, user_id)
);

create index if not exists bookmarks_user_idx on bookmarks (user_id);
