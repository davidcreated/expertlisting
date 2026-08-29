export class HttpError extends Error {
  constructor(status, code, message) {
    super(message);
    this.status = status;
    this.code = code;
  }
}

export const badRequest = (message) =>
  new HttpError(400, 'BAD_REQUEST', message);

export const notFound = (message) => new HttpError(404, 'NOT_FOUND', message);

export function errorHandler(error, req, res, _next) {
  const expected = error instanceof HttpError;
  const status = expected ? error.status : 500;
  const code = expected ? error.code : 'INTERNAL_ERROR';

  if (status >= 500) {
    console.error(`${req.method} ${req.originalUrl} failed`, error);
  }

  res.status(status).json({
    error: code,
    message:
      status >= 500
        ? 'The server could not complete that request.'
        : error.message,
  });
}

export function notFoundHandler(req, res) {
  res.status(404).json({
    error: 'NOT_FOUND',
    message: `No route for ${req.method} ${req.originalUrl}`,
  });
}

export const asyncRoute = (handler) => (req, res, next) =>
  Promise.resolve(handler(req, res, next)).catch(next);
