const V = 'tb2';
const CACHE = ['./', './index.html', './icon.svg'];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(V).then(async cache => {
      await Promise.all(
        CACHE.map(async url => {
          try {
            const response = await fetch(url, { cache: 'reload' });
            if (response.ok) {
              await cache.put(url, response);
            }
          } catch (error) {
            console.warn('Cache:', url, error);
          }
        })
      );
    })
  );
  self.skipWaiting();
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys()
      .then(keys => Promise.all(
        keys.filter(key => key !== V)
          .map(key => caches.delete(key))
      ))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', event => {
  const request = event.request;
  const url = new URL(request.url);

  if (request.method !== 'GET' ||
      url.origin !== self.location.origin) return;

  if (url.pathname.endsWith('/config.js')) return;

  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request)
        .then(response => {
          if (response.ok) {
            const copy = response.clone();
            caches.open(V).then(cache =>
              cache.put('./index.html', copy)
            );
          }
          return response;
        })
        .catch(async () => {
          return await caches.match('./index.html') ||
                 await caches.match('./');
        })
    );
    return;
  }

  event.respondWith(
    fetch(request)
      .then(response => {
        if (response.ok) {
          const copy = response.clone();
          caches.open(V).then(cache =>
            cache.put(request, copy)
          );
        }
        return response;
      })
      .catch(() => caches.match(request))
  );
});
