/**
 * SceneFX — Modular Phaser 3 Shader & Particle Effects Manager
 *
 * USAGE:
 *   In your Scene's create():
 *     this.fx = new SceneFX(this);
 *     this.fx.enable('vignette', { intensity: 0.5 });
 *     this.fx.enable('scanlines', { alpha: 0.08 });
 *     this.fx.enable('chromatic', { offset: 1.5 });
 *
 *   In your Scene's update(time, delta):
 *     this.fx.update(time, delta);
 *
 *   Particle effects at a position:
 *     this.fx.burst(x, y);              // generic pulp/XP burst
 *     this.fx.explosion(x, y);          // enemy death explosion
 *     this.fx.levelUp(x, y);            // golden level-up ring
 *     this.fx.bloodSplat(x, y, color);  // enemy hit splat
 *     this.fx.sparkTrail(x, y, dir);    // sword/projectile trail
 *     this.fx.shockwave(x, y);          // area-of-effect ring
 *     this.fx.healPulse(x, y);          // green regen effect
 *     this.fx.electricArc(x, y);        // lightning zap burst
 *     this.fx.smokeCloud(x, y);         // boss/dark smoke puff
 *     this.fx.coinSpray(x, y, count);   // item drop sparkles
 *
 *   Live config tweaks:
 *     this.fx.set('vignette', { intensity: 0.8 });
 *     this.fx.disable('scanlines');
 *     this.fx.setGlobal({ timeScale: 0.5 });  // slow-mo everything
 *
 *   Screen effects:
 *     this.fx.screenShake(intensity, duration);
 *     this.fx.flashScreen(color, alpha, duration);
 *     this.fx.slowMotion(factor, duration);     // e.g. 0.3 for 300ms slow-mo
 */


// This class is used for applying extra effects and juice to scenes.
class SceneFX {
    /**
     * @param {Phaser.Scene} scene  - The scene to attach effects to
     * @param {object}       config - Optional top-level config overrides
     */
    constructor(scene, config = {}) {
        this.scene = scene;

        // ── Global state ──────────────────────────────────────────────
        this._enabled = {};   // map of effectKey → true
        this._configs = {};   // map of effectKey → config object
        this._overlays = {};   // map of effectKey → Phaser GameObjects
        this._particles = [];   // active managed emitters
        this._time = 0;
        this._timeScale = config.timeScale ?? 1;

        // Overlay depth: render above world, below HUD
        this._depth = config.depth ?? 190;

        // Camera ref (used for shake)
        this._cam = scene.cameras.main;

        // Default shader pipeline configs
        this._defaults = {
            vignette: {
                intensity: 0.55,  // 0 = none, 1 = full black edges
                color: 0x000000,
                feather: 0.45,  // softness of vignette edge
                scrollFactor: 0,
            },
            scanlines: {
                alpha: 0.07,  // opacity of scanline overlay
                lineHeight: 3,     // px per line
                color: 0x000000,
                scrollFactor: 0,
            },
            chromatic: {
                offset: 2,     // px of RGB channel split
                animated: true,  // breathe offset over time
                amplitude: 0.6,   // animation amplitude in px
                scrollFactor: 0,
            },
            grain: {
                alpha: 0.04,  // noise overlay opacity
                animated: true,  // flicker each frame
                scrollFactor: 0,
            },
            crt: {
                curvature: 0.015, // barrel distortion (cosmetic; via scale pulse)
                scrollFactor: 0,
            },
            bloom: {
                // Phaser's built-in bloom (requires WebGL)
                strength: 0.8,
                radius: 0.5,
                threshold: 0.6,
            },
            aberration: {
                // Persistent screen-edge aberration (heavier than chromatic)
                offset: 4,
                edges: true,
            },
            overlay: {
                // Tinted full-screen overlay (e.g. red for low-HP effect)
                color: 0xff0000,
                alpha: 0.0,
                scrollFactor: 0,
            },
        };

        // Merge top-level config into defaults
        if (config.defaults) {
            for (const [k, v] of Object.entries(config.defaults)) {
                this._defaults[k] = { ...this._defaults[k], ...v };
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SHADER / OVERLAY EFFECTS
    // ═══════════════════════════════════════════════════════════════════

    /**
     * Enable a named effect with optional config overrides.
     * Safe to call multiple times — re-configures if already enabled.
     * @param {string} key    - Effect name (vignette|scanlines|chromatic|grain|bloom|overlay)
     * @param {object} config - Partial config to merge into defaults
     */
    enable(key, config = {}) {
        const merged = { ...this._defaults[key], ...config };
        this._configs[key] = merged;

        if (this._enabled[key]) {
            this._applyConfig(key);
            return this;
        }

        this._enabled[key] = true;
        this._buildOverlay(key);
        return this;
    }

    /** Disable and destroy an effect overlay */
    disable(key) {
        this._enabled[key] = false;
        if (this._overlays[key]) {
            const o = this._overlays[key];
            if (Array.isArray(o)) o.forEach(x => x.destroy());
            else o.destroy?.();
            delete this._overlays[key];
        }
        return this;
    }

    /** Live-update config for an already-enabled effect */
    set(key, config = {}) {
        if (!this._configs[key]) this._configs[key] = { ...this._defaults[key] };
        Object.assign(this._configs[key], config);
        if (this._enabled[key]) this._applyConfig(key);
        return this;
    }

    /** Update global time-scale for animated effects */
    setGlobal(opts = {}) {
        if (opts.timeScale !== undefined) this._timeScale = opts.timeScale;
        return this;
    }

    /** Must be called from scene update() for animated overlays */
    update(time, delta) {
        this._time += delta * this._timeScale;
        if (this._enabled['chromatic'] && this._configs['chromatic']?.animated) {
            this._tickChromatic(time);
        }
        if (this._enabled['grain'] && this._configs['grain']?.animated) {
            this._tickGrain();
        }
        if (this._enabled['overlay']) {
            // low-hp pulse etc. handled externally via set()
        }
        // Expire dead emitters
        this._particles = this._particles.filter(e => !e.destroyed);
    }

    // ── Internal: build overlay objects ──────────────────────────────

    _buildOverlay(key) {
        const cfg = this._configs[key];
        const s = this.scene;
        const W = s.cameras.main.width;
        const H = s.cameras.main.height;
        // Use CONFIG if available, else fallback to camera dims
        const CW = (typeof CONFIG !== 'undefined' ? CONFIG.WIDTH : W);
        const CH = (typeof CONFIG !== 'undefined' ? CONFIG.HEIGHT : H);

        switch (key) {

            case 'vignette': {
                // Canvas texture vignette — radial gradient drawn once
                const key2 = '__fx_vignette_tex';
                if (!s.textures.exists(key2)) {
                    const canvas = document.createElement('canvas');
                    canvas.width = CW;
                    canvas.height = CH;
                    const ctx = canvas.getContext('2d');
                    const grd = ctx.createRadialGradient(
                        CW / 2, CH / 2, CW * cfg.feather,
                        CW / 2, CH / 2, CW * 0.85
                    );
                    grd.addColorStop(0, 'rgba(0,0,0,0)');
                    grd.addColorStop(1, `rgba(0,0,0,${cfg.intensity})`);
                    ctx.fillStyle = grd;
                    ctx.fillRect(0, 0, CW, CH);
                    s.textures.addCanvas(key2, canvas);
                }
                const img = s.add.image(CW / 2, CH / 2, key2)
                    .setScrollFactor(cfg.scrollFactor)
                    .setDepth(this._depth)
                    .setAlpha(1);
                this._overlays[key] = img;
                break;
            }

            case 'scanlines': {
                // Graphics-based scanlines
                const g = s.add.graphics()
                    .setScrollFactor(cfg.scrollFactor)
                    .setDepth(this._depth + 1);
                this._overlays[key] = g;
                this._drawScanlines(g, CW, CH, cfg);
                break;
            }

            case 'chromatic': {
                // Three colored semi-transparent rectangles that shift
                const base = cfg.offset;
                const rects = [
                    s.add.rectangle(CW / 2 - base, CH / 2, CW, CH, 0xff0000, 0.04)
                        .setScrollFactor(cfg.scrollFactor).setDepth(this._depth + 2),
                    s.add.rectangle(CW / 2, CH / 2, CW, CH, 0x00ff00, 0.04)
                        .setScrollFactor(cfg.scrollFactor).setDepth(this._depth + 2),
                    s.add.rectangle(CW / 2 + base, CH / 2, CW, CH, 0x0000ff, 0.04)
                        .setScrollFactor(cfg.scrollFactor).setDepth(this._depth + 2),
                ];
                this._overlays[key] = rects;
                break;
            }

            case 'grain': {
                // Noise overlay — regenerated each frame for animated mode
                const canvasKey = '__fx_grain_tex';
                if (!s.textures.exists(canvasKey)) {
                    const canvas = this._makeNoiseCanvas(CW, CH);
                    s.textures.addCanvas(canvasKey, canvas);
                }
                const img = s.add.image(CW / 2, CH / 2, canvasKey)
                    .setScrollFactor(cfg.scrollFactor)
                    .setDepth(this._depth + 3)
                    .setAlpha(cfg.alpha)
                    .setBlendMode(Phaser.BlendModes.MULTIPLY);
                this._overlays[key] = img;
                break;
            }

            case 'bloom': {
                // Use Phaser's built-in post-FX bloom if WebGL
                try {
                    const cam = s.cameras.main;
                    if (cam.postFX) {
                        const fx = cam.postFX.addBloom(
                            0xffffff,
                            cfg.radius,
                            cfg.radius,
                            cfg.strength,
                            cfg.threshold
                        );
                        this._overlays[key] = fx;
                    }
                } catch (e) {
                    console.warn('SceneFX: bloom requires Phaser WebGL + postFX pipeline.');
                }
                break;
            }

            case 'overlay': {
                const rect = s.add.rectangle(CW / 2, CH / 2, CW, CH, cfg.color, cfg.alpha)
                    .setScrollFactor(cfg.scrollFactor)
                    .setDepth(this._depth + 4);
                this._overlays[key] = rect;
                break;
            }

            default:
                console.warn(`SceneFX: unknown effect "${key}"`);
        }
    }

    _applyConfig(key) {
        const cfg = this._configs[key];
        const o = this._overlays[key];
        if (!o) return;
        if (key === 'overlay' && o.setFillStyle) {
            o.setFillStyle(cfg.color, cfg.alpha);
        }
        if (key === 'bloom' && o.setStrength) {
            o.setStrength(cfg.strength);
        }
    }

    _drawScanlines(g, W, H, cfg) {
        g.clear();
        g.fillStyle(cfg.color, cfg.alpha);
        for (let y = 0; y < H; y += cfg.lineHeight * 2) {
            g.fillRect(0, y, W, cfg.lineHeight);
        }
    }

    _tickChromatic(time) {
        const rects = this._overlays['chromatic'];
        if (!rects || !Array.isArray(rects)) return;
        const cfg = this._configs['chromatic'];
        const shift = cfg.offset + Math.sin(time * 0.002) * cfg.amplitude;
        const CW = (typeof CONFIG !== 'undefined' ? CONFIG.WIDTH : 800) / 2;
        rects[0].setPosition(CW - shift, rects[0].y);
        rects[2].setPosition(CW + shift, rects[2].y);
    }

    _tickGrain() {
        // Randomize alpha each frame for film-grain flicker
        const o = this._overlays['grain'];
        const cfg = this._configs['grain'];
        if (o) o.setAlpha(cfg.alpha * (0.7 + Math.random() * 0.6));
    }

    _makeNoiseCanvas(w, h) {
        const canvas = document.createElement('canvas');
        canvas.width = w;
        canvas.height = h;
        const ctx = canvas.getContext('2d');
        const img = ctx.createImageData(w, h);
        const data = img.data;
        for (let i = 0; i < data.length; i += 4) {
            const v = Math.random() * 255 | 0;
            data[i] = data[i + 1] = data[i + 2] = v;
            data[i + 3] = 255;
        }
        ctx.putImageData(img, 0, 0);
        return canvas;
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SCREEN-LEVEL EFFECTS
    // ═══════════════════════════════════════════════════════════════════

    /**
     * Camera shake
     * @param {number} intensity - shake strength in pixels (default 6)
     * @param {number} duration  - ms (default 250)
     */
    screenShake(intensity = 6, duration = 250) {
        this._cam.shake(duration, intensity / 1000);
        return this;
    }

    /**
     * Full-screen colour flash (e.g. white for hit, red for damage)
     * @param {number} color    - hex color (default 0xffffff)
     * @param {number} alpha    - peak opacity (default 0.5)
     * @param {number} duration - fade duration in ms (default 300)
     */
    flashScreen(color = 0xffffff, alpha = 0.5, duration = 300) {
        const s = this.scene;
        const CW = typeof CONFIG !== 'undefined' ? CONFIG.WIDTH : s.cameras.main.width;
        const CH = typeof CONFIG !== 'undefined' ? CONFIG.HEIGHT : s.cameras.main.height;
        const r = s.add.rectangle(CW / 2, CH / 2, CW, CH, color, alpha)
            .setScrollFactor(0)
            .setDepth(this._depth + 10);
        s.tweens.add({
            targets: r,
            alpha: 0,
            duration: duration,
            onComplete: () => r.destroy(),
        });
        return this;
    }

    /**
     * Temporarily slow scene time (affects delta-based movement if you use this._timeScale)
     * NOTE: to affect Phaser's physics/tweens natively, integrate with scene.time.timeScale
     * @param {number} factor   - time scale factor 0..1 (0.3 = very slow)
     * @param {number} duration - ms to stay slow before returning to 1
     */
    slowMotion(factor = 0.3, duration = 600) {
        this._timeScale = factor;
        this.scene.time.timeScale = factor;
        this.scene.physics?.world && (this.scene.physics.world.timeScale = 1 / factor);
        this.scene.tweens.timeScale = factor;
        this.scene.time.delayedCall(duration * factor, () => {
            this._timeScale = 1;
            this.scene.time.timeScale = 1;
            this.scene.tweens.timeScale = 1;
            this.scene.physics?.world && (this.scene.physics.world.timeScale = 1);
        });
        return this;
    }

    /**
     * Dynamic overlay alpha (e.g. pulse red at low HP)
     * Call continuously from your game loop or on HP-change event.
     * @param {number} alpha - 0..1
     */
    setOverlayAlpha(alpha) {
        const o = this._overlays['overlay'];
        if (o) o.setAlpha(alpha);
        return this;
    }

    // ═══════════════════════════════════════════════════════════════════
    //  PARTICLE EFFECTS
    //  All methods take (x, y) world coordinates + optional options.
    // ═══════════════════════════════════════════════════════════════════

    /**
     * Generic XP/pulp burst — 8 small rectangles flying out
     * @param {number} x
     * @param {number} y
     * @param {object} opts - { count, color, size, speed, lifespan }
     */
    burst(x, y, opts = {}) {
        const {
            count = 8,
            color = 0xffd700,
            size = 6,
            speed = 180,
            lifespan = 600,
        } = opts;

        for (let i = 0; i < count; i++) {
            const angle = (Math.PI * 2 / count) * i + (Math.random() - 0.5) * 0.5;
            const spd = speed * (0.6 + Math.random() * 0.8);
            const rect = this.scene.add.rectangle(x, y, size, size, color)
                .setDepth(100)
                .setAlpha(1);

            this.scene.tweens.add({
                targets: rect,
                x: x + Math.cos(angle) * spd,
                y: y + Math.sin(angle) * spd,
                alpha: 0,
                scaleX: 0.1,
                scaleY: 0.1,
                duration: lifespan,
                ease: 'Power2',
                onComplete: () => rect.destroy(),
            });
        }
        return this;
    }

    /**
     * Enemy death explosion — large burst + shockwave ring
     * @param {number} x
     * @param {number} y
     * @param {object} opts - { color, size, count, shockwave }
     */
    explosion(x, y, opts = {}) {
        const {
            color = 0xff4400,
            secondary = 0xffaa00,
            count = 16,
            size = 10,
            speed = 280,
            lifespan = 700,
            shockwave = true,
        } = opts;

        // Core particles
        for (let i = 0; i < count; i++) {
            const angle = (Math.PI * 2 / count) * i;
            const spd = speed * (0.5 + Math.random());
            const col = Math.random() > 0.5 ? color : secondary;
            const sz = size * (0.5 + Math.random() * 1.2);
            const circ = this.scene.add.circle(x, y, sz / 2, col)
                .setDepth(101).setAlpha(0.9);

            this.scene.tweens.add({
                targets: circ,
                x: x + Math.cos(angle) * spd,
                y: y + Math.sin(angle) * spd,
                alpha: 0,
                scale: 0.1,
                duration: lifespan * (0.6 + Math.random() * 0.8),
                ease: 'Power3',
                onComplete: () => circ.destroy(),
            });
        }

        if (shockwave) this.shockwave(x, y, { color });
        return this;
    }

    /**
     * Level-up golden ring + starburst
     * @param {number} x
     * @param {number} y
     * @param {object} opts - { color, ringRadius, starCount }
     */
    levelUp(x, y, opts = {}) {
        const {
            color = 0xffd700,
            ringRadius = 60,
            starCount = 12,
            lifespan = 900,
        } = opts;

        // Ring expand
        const ring = this.scene.add.circle(x, y, 4, color, 0)
            .setDepth(102)
            .setStrokeStyle(4, color, 1);
        this.scene.tweens.add({
            targets: ring,
            scaleX: ringRadius / 4,
            scaleY: ringRadius / 4,
            alpha: 0,
            duration: lifespan,
            ease: 'Power2',
            onComplete: () => ring.destroy(),
        });

        // Stars
        for (let i = 0; i < starCount; i++) {
            const angle = (Math.PI * 2 / starCount) * i;
            const dist = ringRadius * (0.7 + Math.random() * 0.6);
            const star = this._makeStar(x, y, 6, color).setDepth(103).setAlpha(1);
            this.scene.tweens.add({
                targets: star,
                x: x + Math.cos(angle) * dist,
                y: y + Math.sin(angle) * dist,
                angle: 360,
                alpha: 0,
                duration: lifespan,
                ease: 'Power2',
                onComplete: () => star.destroy(),
            });
        }
        return this;
    }

    /**
     * Hit splat — flat splatter rectangles in a random cluster
     * @param {number} x
     * @param {number} y
     * @param {number} color - hex (default 0xff0000)
     * @param {object} opts  - { count, size, spread, lifespan }
     */
    bloodSplat(x, y, color = 0xff0000, opts = {}) {
        const {
            count = 10,
            size = 5,
            spread = 28,
            lifespan = 700,
        } = opts;

        for (let i = 0; i < count; i++) {
            const ox = (Math.random() - 0.5) * spread;
            const oy = (Math.random() - 0.5) * spread;
            const w = size * (0.5 + Math.random() * 1.5);
            const h = size * (0.5 + Math.random() * 1.5);
            const spl = this.scene.add.rectangle(x + ox, y + oy, w, h, color)
                .setDepth(95).setAlpha(0.9).setAngle(Math.random() * 360);
            this.scene.tweens.add({
                targets: spl,
                alpha: 0,
                duration: lifespan,
                delay: Math.random() * 200,
                onComplete: () => spl.destroy(),
            });
        }
        return this;
    }

    /**
     * Spark trail in a direction (for projectiles/dashes)
     * @param {number} x
     * @param {number} y
     * @param {number} dirX   - normalised X direction
     * @param {number} dirY   - normalised Y direction
     * @param {object} opts   - { count, color, length, lifespan }
     */
    sparkTrail(x, y, dirX = 1, dirY = 0, opts = {}) {
        const {
            count = 6,
            color = 0xffffff,
            length = 40,
            spread = 0.4,
            lifespan = 350,
        } = opts;

        for (let i = 0; i < count; i++) {
            const angle = Math.atan2(dirY, dirX) + (Math.random() - 0.5) * spread;
            const dist = length * Math.random();
            const sp = this.scene.add.rectangle(x, y, 3, 3, color)
                .setDepth(100).setAlpha(0.9);
            this.scene.tweens.add({
                targets: sp,
                x: x - Math.cos(angle) * dist,
                y: y - Math.sin(angle) * dist,
                alpha: 0,
                scaleX: 0.1,
                scaleY: 0.1,
                duration: lifespan,
                ease: 'Power1',
                onComplete: () => sp.destroy(),
            });
        }
        return this;
    }

    /**
     * Expanding shockwave ring
     * @param {number} x
     * @param {number} y
     * @param {object} opts - { color, radius, lineWidth, duration }
     */
    shockwave(x, y, opts = {}) {
        const {
            color = 0xffffff,
            radius = 40,
            lineWidth = 3,
            duration = 500,
            alpha = 0.8,
        } = opts;

        const ring = this.scene.add.circle(x, y, 4, color, 0)
            .setDepth(104)
            .setStrokeStyle(lineWidth, color, alpha);
        this.scene.tweens.add({
            targets: ring,
            scaleX: radius / 4,
            scaleY: radius / 4,
            alpha: 0,
            duration: duration,
            ease: 'Sine.easeOut',
            onComplete: () => ring.destroy(),
        });
        return this;
    }

    /**
     * Green heal pulse — expanding ring with rising particles
     * @param {number} x
     * @param {number} y
     * @param {object} opts - { count, color }
     */
    healPulse(x, y, opts = {}) {
        const {
            count = 8,
            color = 0x44ff88,
            lifespan = 800,
        } = opts;

        this.shockwave(x, y, { color, radius: 50, lineWidth: 2, duration: 600 });

        for (let i = 0; i < count; i++) {
            const ox = (Math.random() - 0.5) * 40;
            const drop = 30 + Math.random() * 30;
            const plus = this.scene.add.text(x + ox, y, '+', {
                fontSize: '14px', color: '#44ff88', fontStyle: 'bold',
            }).setDepth(105).setAlpha(1);
            this.scene.tweens.add({
                targets: plus,
                y: y - drop,
                alpha: 0,
                duration: lifespan,
                delay: i * 60,
                ease: 'Power2',
                onComplete: () => plus.destroy(),
            });
        }
        return this;
    }

    /**
     * Electric arc burst (lightning zap style)
     * @param {number} x
     * @param {number} y
     * @param {object} opts - { branches, color, radius }
     */
    electricArc(x, y, opts = {}) {
        const {
            branches = 7,
            color = 0x88ffff,
            radius = 55,
            lifespan = 400,
        } = opts;

        const gfx = this.scene.add.graphics().setDepth(106);
        gfx.lineStyle(2, color, 0.9);

        for (let i = 0; i < branches; i++) {
            const angle = (Math.PI * 2 / branches) * i + (Math.random() - 0.5) * 0.8;
            const len = radius * (0.6 + Math.random() * 0.7);
            // Segmented lightning bolt
            let cx = x, cy = y;
            const steps = 5;
            gfx.beginPath();
            gfx.moveTo(cx, cy);
            for (let s = 1; s <= steps; s++) {
                const t = s / steps;
                cx = x + Math.cos(angle) * len * t + (Math.random() - 0.5) * 14;
                cy = y + Math.sin(angle) * len * t + (Math.random() - 0.5) * 14;
                gfx.lineTo(cx, cy);
            }
            gfx.strokePath();
        }

        this.scene.tweens.add({
            targets: gfx,
            alpha: 0,
            duration: lifespan,
            ease: 'Power2',
            onComplete: () => gfx.destroy(),
        });
        return this;
    }

    /**
     * Smoke cloud — drifting grey circles
     * @param {number} x
     * @param {number} y
     * @param {object} opts - { count, color, size, duration }
     */
    smokeCloud(x, y, opts = {}) {
        const {
            count = 10,
            color = 0x888888,
            size = 14,
            duration = 1200,
        } = opts;

        for (let i = 0; i < count; i++) {
            const ox = (Math.random() - 0.5) * 24;
            const oy = (Math.random() - 0.5) * 24;
            const sz = size * (0.6 + Math.random() * 1.0);
            const smoke = this.scene.add.circle(x + ox, y + oy, sz, color)
                .setDepth(93).setAlpha(0.55);
            this.scene.tweens.add({
                targets: smoke,
                x: x + ox + (Math.random() - 0.5) * 50,
                y: y + oy - (20 + Math.random() * 40),
                scaleX: 2 + Math.random(),
                scaleY: 2 + Math.random(),
                alpha: 0,
                duration: duration,
                delay: Math.random() * 300,
                ease: 'Sine.easeOut',
                onComplete: () => smoke.destroy(),
            });
        }
        return this;
    }

    /**
     * Coin/item drop sparkle spray
     * @param {number} x
     * @param {number} y
     * @param {number} count   - number of sparkles
     * @param {object} opts    - { colors, size, speed }
     */
    coinSpray(x, y, count = 12, opts = {}) {
        const {
            colors = [0xffd700, 0xffffff, 0xffee44],
            size = 5,
            speed = 130,
            lifespan = 700,
        } = opts;

        for (let i = 0; i < count; i++) {
            const angle = -Math.PI / 2 + (Math.random() - 0.5) * Math.PI * 1.2;
            const spd = speed * (0.5 + Math.random());
            const color = colors[Math.floor(Math.random() * colors.length)];
            const coin = this.scene.add.rectangle(x, y, size, size, color)
                .setDepth(100).setAlpha(1).setAngle(Math.random() * 360);
            this.scene.tweens.add({
                targets: coin,
                x: x + Math.cos(angle) * spd,
                y: y + Math.sin(angle) * spd + 30,
                alpha: 0,
                angle: coin.angle + 360,
                scaleX: 0.1,
                scaleY: 0.1,
                duration: lifespan,
                ease: 'Power2',
                onComplete: () => coin.destroy(),
            });
        }
        return this;
    }

    // ═══════════════════════════════════════════════════════════════════
    //  INTERNAL HELPERS
    // ═══════════════════════════════════════════════════════════════════

    /** Create a small star polygon as a Graphics object at (x, y) */
    _makeStar(x, y, radius, color) {
        const gfx = this.scene.add.graphics();
        const points = 5;
        const outer = radius;
        const inner = radius * 0.4;
        gfx.fillStyle(color, 1);
        gfx.beginPath();
        for (let i = 0; i < points * 2; i++) {
            const r = i % 2 === 0 ? outer : inner;
            const angle = (Math.PI / points) * i - Math.PI / 2;
            i === 0 ? gfx.moveTo(x + Math.cos(angle) * r, y + Math.sin(angle) * r)
                : gfx.lineTo(x + Math.cos(angle) * r, y + Math.sin(angle) * r);
        }
        gfx.closePath();
        gfx.fillPath();
        return gfx;
    }

    /** Destroy all overlays and managed particles — call from scene shutdown */
    destroy() {
        for (const key of Object.keys(this._overlays)) this.disable(key);
    }
}