const CACHE_NAME = 'banana-survivors-v1.012';
const ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './assets/icon.png',
  './assets/banana.png',
  './assets/screenshot_wide.png',
  './assets/screenshot.png',
  './scene.fx.js',
  './noise.js',
  './config.js',
  './base.js',
  './abilities.js',
  './player.js',
  './enemies.js',
  './ui.js',
  './scenes.js',
  './phaser.min.js',
  './google_font.css',
];
self.addEventListener('install', (event) => {
  self.skipWaiting(); // Force update
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      // Use map to catch individual errors
      return Promise.allSettled(
        ASSETS.map(asset =>
          cache.add(asset).catch(err => console.warn(`Failed to cache: ${asset}`, err))
        )
      );
    })
  );
});

self.addEventListener('fetch', (event) => {
  // Only cache GET requests and local assets
  const url = new URL(event.request.url);
  const isExternal = !url.host.includes(location.host);

  if (event.request.method !== 'GET' || isExternal) {
    return; // Let browser handle it directly
  }

  event.respondWith(
    caches.match(event.request).then((response) => {
      // Return cache OR try network, and catch errors if network is down
      return response || fetch(event.request).catch((err) => {
        console.log("Network failed and not in cache");
        return err
      });
    })
  );
});


self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});
