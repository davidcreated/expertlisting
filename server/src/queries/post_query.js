const AUTHOR_JSON = (alias) => `json_build_object(
  'id', ${alias}.id,
  'name', ${alias}.name,
  'username', ${alias}.username,
  'avatarUrl', ${alias}.avatar_url,
  'role', ${alias}.role
)`;

export const POST_SELECT = `
  select
    p.id,
    p.body,
    p.category,
    p.location,
    p.transaction_type,
    p.view_count,
    p.created_at,
    ${AUTHOR_JSON('au')} as author,
    coalesce(media.items, '[]'::json) as media,
    coalesce(like_count.n, 0) as like_count,
    coalesce(comment_count.n, 0) as comment_count,
    coalesce(bookmark_count.n, 0) as bookmark_count,
    (viewer_like.user_id is not null) as is_liked,
    (viewer_bookmark.user_id is not null) as is_bookmarked,
    coalesce(liked_by.items, '[]'::json) as liked_by,
    top_comment.item as top_comment
  from posts p
  join users au on au.id = p.author_id
  left join lateral (
    select json_agg(
             json_build_object(
               'id', m.id,
               'url', m.url,
               'kind', m.kind,
               'aspectRatio', m.aspect_ratio::float
             ) order by m.position, m.id
           ) as items
      from post_media m
     where m.post_id = p.id
  ) media on true
  left join lateral (
    select count(*)::int as n from likes l where l.post_id = p.id
  ) like_count on true
  left join lateral (
    select count(*)::int as n from comments c where c.post_id = p.id
  ) comment_count on true
  left join lateral (
    select count(*)::int as n from bookmarks b where b.post_id = p.id
  ) bookmark_count on true
  left join likes viewer_like
    on viewer_like.post_id = p.id and viewer_like.user_id = $1
  left join bookmarks viewer_bookmark
    on viewer_bookmark.post_id = p.id and viewer_bookmark.user_id = $1
  left join lateral (
    select json_agg(
             ${AUTHOR_JSON('lu')} order by recent.created_at desc
           ) as items
      from (
        select l.user_id, l.created_at
          from likes l
         where l.post_id = p.id
         order by l.created_at desc
         limit 3
      ) recent
      join users lu on lu.id = recent.user_id
  ) liked_by on true
  left join lateral (
    select json_build_object(
             'id', c.id,
             'postId', c.post_id,
             'body', c.body,
             'createdAt', c.created_at,
             'author', ${AUTHOR_JSON('cu')}
           ) as item
      from comments c
      join users cu on cu.id = c.author_id
     where c.post_id = p.id
     order by c.created_at desc, c.id desc
     limit 1
  ) top_comment on true
`;

export function mapPostRow(row) {
  return {
    id: row.id,
    author: row.author,
    category: row.category,
    body: row.body,
    location: row.location,
    transactionType: row.transaction_type,
    media: row.media,
    createdAt: row.created_at,
    likeCount: row.like_count,
    commentCount: row.comment_count,
    viewCount: row.view_count,
    bookmarkCount: row.bookmark_count,
    isLiked: row.is_liked,
    isBookmarked: row.is_bookmarked,
    likedBy: row.liked_by,
    topComment: row.top_comment,
  };
}

export function mapCommentRow(row) {
  return {
    id: row.id,
    postId: row.post_id,
    author: row.author,
    body: row.body,
    createdAt: row.created_at,
  };
}
