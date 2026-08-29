export function encodeCursor(row) {
  const createdAt = row.created_at instanceof Date
    ? row.created_at.toISOString()
    : new Date(row.created_at).toISOString();

  return Buffer.from(`${createdAt}|${row.id}`, 'utf8').toString('base64url');
}

export function decodeCursor(cursor) {
  if (!cursor) return null;

  let decoded;
  try {
    decoded = Buffer.from(cursor, 'base64url').toString('utf8');
  } catch {
    return null;
  }

  const separator = decoded.lastIndexOf('|');
  if (separator === -1) return null;

  const createdAt = decoded.slice(0, separator);
  const id = decoded.slice(separator + 1);

  const parsed = new Date(createdAt);
  if (Number.isNaN(parsed.getTime()) || id.length === 0) return null;

  return { createdAt: parsed.toISOString(), id };
}
