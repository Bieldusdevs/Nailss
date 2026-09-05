import { readFile, writeFile } from 'node:fs/promises';
const buildId = (await readFile('.next/BUILD_ID', 'utf8')).trim();
const source = await readFile('public/sw.js', 'utf8');
await writeFile(
  'public/sw.js',
  source.replace(/const VERSION = '[^']+';/, `const VERSION = 'lumiere-${buildId}';`),
);
console.log('PWA cache version matches this build.');
