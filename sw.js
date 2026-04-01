const CACHE_NAME = 'banana-survivors-v1.02';
const ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './assets/icon.png',
  './assets/banana.png',
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

  //'https://cdnjs.cloudflare.com/ajax/libs/phaser/3.60.0/phaser.min.js',
  //'https://fonts.googleapis.com/css2?family=Fredoka+One&family=Nunito:wght@400;700&display=swap'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(ASSETS);
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
      return response || fetch(event.request);
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
