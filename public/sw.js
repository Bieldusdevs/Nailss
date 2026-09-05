/* Public content only. Never cache identities, availability, holds or payment responses. */
const VERSION = 'lumiere-336YjjyPHy8Xp_LiNnAzO';
const STATIC = `${VERSION}:static`, PAGES = `${VERSION}:pages`, PUBLIC = `${VERSION}:public`;
const ORIGIN = self.location.origin;
const assets = ['/offline.html', '/offline.css', '/offline.js', '/manifest.json', '/fonts/syne.woff2', '/fonts/jakarta.woff2', '/fonts/symbols.woff2', '/icons/brand.svg', '/icons/icon-192.png', '/icons/icon-512.png', '/images/hero-editorial.jpg', '/images/polish.jpg', '/images/manicure.jpg', '/images/ritual.jpg', '/images/nailart.jpg', '/images/care.jpg', '/images/interior.jpg'];
const publicPages = ['/', '/servicos', '/galeria', '/marcar', '/atelier', '/equipa', '/contactos', '/clube', '/privacidade', '/termos', '/cancelamento', '/cookies', '/reclamacoes', '/creditos'];
const isPage = pathname => publicPages.includes(pathname) || /^\/servicos\/[a-z0-9-]+$/.test(pathname);
const isAsset = pathname => pathname.startsWith('/_next/static/') || /^\/(images|icons|fonts)\//.test(pathname) || assets.includes(pathname);
async function storeAsset(url) { const cache = await caches.open(STATIC); if (await cache.match(url)) return; const response = await fetch(url, { credentials: 'omit' }); if (response.ok) await cache.put(url, response); }
async function storePage(pathname) {
  const response = await fetch(pathname, { credentials: 'omit', headers: { Accept: 'text/html' }, cache: 'no-store' });
  if (!response.ok) return;
  const html = await response.clone().text(); await (await caches.open(PAGES)).put(pathname, response);
  const referenced = [...new Set(html.match(/\/_next\/static\/[^"'\\\s<>]+/g) || [])].map(value => value.replaceAll('&amp;', '&'));
  for (let i = 0; i < referenced.length; i += 6) await Promise.allSettled(referenced.slice(i, i + 6).map(storeAsset));
}
self.addEventListener('install', event => event.waitUntil((async () => {
  const cache = await caches.open(STATIC); await cache.addAll(assets);
  let treatments = [];
  try { const response = await fetch('/api/domains/catalog', { credentials: 'omit', cache: 'no-store' }); if (response.ok) { const content = await response.clone().json(); treatments = content.treatments.map(t => `/servicos/${t.slug}`); await (await caches.open(PUBLIC)).put('/api/domains/catalog', response); } } catch {}
  const pages = [...publicPages, ...treatments];
  for (let i = 0; i < pages.length; i += 3) await Promise.allSettled(pages.slice(i, i + 3).map(storePage));
})()));
self.addEventListener('activate', event => event.waitUntil((async () => { for (const key of await caches.keys()) if (key.startsWith('lumiere-') && !key.startsWith(VERSION + ':')) await caches.delete(key); await self.clients.claim(); })()));
self.addEventListener('message', event => { if (event.data?.type === 'SKIP_WAITING') self.skipWaiting(); });
async function navigation(request) {
  const url = new URL(request.url);
  try {
    const response = await fetch(request);
    if (response.ok && isPage(url.pathname) && !url.search) await (await caches.open(PAGES)).put(url.pathname, response.clone());
    if (response.status < 500) return response;
    throw new Error('temporarily unavailable');
  } catch {
    if (isPage(url.pathname)) { const saved = await (await caches.open(PAGES)).match(url.pathname); if (saved) return saved; }
    return (await caches.match('/offline.html')) || new Response('Sem ligação. As marcações exigem acesso ao atelier.', { status: 503 });
  }
}
async function publicCollection(request) {
  const cache = await caches.open(PUBLIC);
  try { const response = await fetch(request); if (response.ok) await cache.put(request, response.clone()); if (response.status < 500) return response; throw new Error('unavailable'); }
  catch { const saved = await cache.match(request); if (!saved) return offlineApi(); const data = await saved.json(); return Response.json(Array.isArray(data) ? data : { ...data, offline: true }, { headers: { 'Cache-Control': 'no-store', 'X-Lumiere-Offline': '1' } }); }
}
function offlineApi() { return Response.json({ code: 'OFFLINE', error: 'Sem ligação ao atelier. Consulte o catálogo guardado e confirme a disponibilidade quando voltar a estar online.' }, { status: 503, headers: { 'Cache-Control': 'no-store, private' } }); }
async function staticAsset(request) {
  const cache = await caches.open(STATIC), saved = await cache.match(request);
  if (saved) return saved;
  try { const response = await fetch(request); if (response.ok) { await cache.put(request, response.clone()); const keys = await cache.keys(); if (keys.length > 260) await cache.delete(keys[assets.length]); } return response; }
  catch { const url = new URL(request.url); if (url.pathname === '/_next/image') { const original = url.searchParams.get('url'); if (original?.startsWith('/images/')) { const image = await cache.match(original); if (image) return image; } } return new Response('', { status: 503 }); }
}
self.addEventListener('fetch', event => {
  const request = event.request, url = new URL(request.url);
  if (url.origin !== ORIGIN || request.method !== 'GET') return;
  if (request.mode === 'navigate') { event.respondWith(navigation(request)); return; }
  if (url.pathname === '/api/domains/catalog' || url.pathname === '/api/domains/artist') { event.respondWith(publicCollection(request)); return; }
  if (url.pathname.startsWith('/api/')) { event.respondWith(fetch(request).catch(offlineApi)); return; }
  if (isAsset(url.pathname) || url.pathname === '/_next/image') event.respondWith(staticAsset(request));
});
