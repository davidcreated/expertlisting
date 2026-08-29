import cors from 'cors';
import express from 'express';

import { attachCurrentUser } from './current_user.js';
import { errorHandler, notFoundHandler } from './errors.js';
import commentsRouter from './routes/comments.js';
import postsRouter from './routes/posts.js';

export function createApp() {
  const app = express();

  app.use(cors());
  app.use(express.json({ limit: '1mb' }));

  app.get('/health', (req, res) => res.json({ status: 'ok' }));

  app.use('/posts', attachCurrentUser, postsRouter);
  app.use('/posts', attachCurrentUser, commentsRouter);

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}
