const CACHE_NAME = 'banana-survivors-v2.03';
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
    './google_font.css'
];

self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(CACHE_NAME).then((cache) => {
            return cache.addAll(ASSETS);
        })
    );
});

self.addEventListener('fetch', (event) => {
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