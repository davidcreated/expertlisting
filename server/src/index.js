import { createApp } from './app.js';
import { describeTarget } from './db.js';

const port = Number.parseInt(process.env.PORT ?? '3000', 10);
const target = describeTarget();
const app = createApp();

app.listen(port, () => {
  console.log(`Expert Listing API listening on http://localhost:${port}`);
  console.log(`Database ${target.host}/${target.database}`);
});
