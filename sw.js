const CACHE_NAME = 'banana-survivors-v1';

// Core files to pre-cache on install
const PRECACHE_URLS = [
  './',
  './index.html',
  './google_font.css',
  './phaser.min.js',
  './noise.js',
  './config.js',
  './base.js',
  './abilities.js',
  './player.js',
  './enemies.js',
  './ui.js',
  './scenes.js',
  './scene.fx.js',
  './lootlocker.js',
  './manifest.json',
  './assets/icon.png',
  './assets/banana.png'
];

// Install: pre-cache core files
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(PRECACHE_URLS);
    }).then(() => self.skipWaiting())
  );
});

// Activate: clean up old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames
          .filter((name) => name !== CACHE_NAME)
          .map((name) => caches.delete(name))
      );
    }).then(() => self.clients.claim())
  );
});

// Fetch: stale-while-revalidate for assets, network-first for API calls
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);

  // Let LootLocker API calls always go to network
  if (url.hostname !== location.hostname) {
    return;
  }

  event.respondWith(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.match(event.request).then((cachedResponse) => {
        const fetchPromise = fetch(event.request).then((networkResponse) => {
          // Cache successful responses
          if (networkResponse && networkResponse.status === 200) {
            cache.put(event.request, networkResponse.clone());
          }
          return networkResponse;
        }).catch(() => {
          // Network failed, return cached or nothing
          return cachedResponse;
        });

        // Return cached response immediately, update in background
        return cachedResponse || fetchPromise;
      });
    })
  );
});
