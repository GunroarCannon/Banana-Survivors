// ============================================================
//  BootScene — generate placeholder assets procedurally
// ============================================================
class BootScene extends Phaser.Scene {
    constructor() { super('Boot'); }

    preload() {
        this.load.image('banana_icon', 'assets/icons/delapouite/banana-peeled.png');
        this.load.image('zombie', 'assets/icons/delapouite/shambling-zombie.png');
        this.load.image('heart', 'assets/icons/lorc/heart-drop.png');
        this.load.image('heart_organ', 'assets/icons/lorc/heart-organ.png');
        this.load.image('skull', 'assets/icons/sbed/death-skull.png');
        this.load.image('trophy', 'assets/icons/lorc/trophy.png');
        this.load.image('ghost', 'assets/icons/lorc/ghost.png');
        this.load.image('star', 'assets/icons/delapouite/round-star.png');
        this.load.image('potion', 'assets/icons/lorc/potion-ball.png');
        this.load.image('banana', 'assets/banana.png')


        const sources = {
            zombie_banana: 'assets/enemies/zombie.png',
            maggot: 'assets/enemies/maggot.png',
            fungal_horror: 'assets/enemies/fungal_horror.png',
            spore_moth: 'assets/enemies/spore_moth.png',
            rot_god: 'assets/enemies/rotgod.png',

            bat: 'assets/bat.png',

            alchemist: 'assets/players/alchemist.png',
            bruiser: 'assets/players/bruiser.png',
            grave_ripener: 'assets/players/grave_ripener.png',
            iron_husk: 'assets/players/iron_husk.png',
            overseer: 'assets/players/overseer.png',
            slicer: 'assets/players/slicer.png',

        }


        Object.entries(sources).forEach(([k, v]) => {
            this.load.image(k, v)
        })

        const icons = {
            ei_tentacles_skull: 'lorc/tentacles-skull',
            heart: 'skoll/hearts', skull: 'lorc/skull-crack', lightning: 'lorc/lightning-trio',
            magnet: 'lorc/magnet', leaf: 'lorc/leaf-swirl', explosion: 'lorc/explosion-rays',
            potion: 'caro-asercion/round-potion', trophy: 'delapouite/diamond-trophy', blood: 'skoll/blood',
            gun: 'john-colburn/pistol-gun', stopwatch: 'lorc/stopwatch', heart_organ: 'lorc/heart-organ'
        };

        Object.entries(icons).forEach(([k, i]) => {
            console.log("loading icon image png ", i);
            this.load.image(k, `assets/icons/${i}.png`)
        });

        this.load.image('lightning', 'assets/icons/lorc/lightning-arc.png');
        this.load.image('stopwatch', 'assets/icons/lorc/stopwatch.png');
        this.load.image('magnet', 'assets/icons/lorc/magnet.png');
        this.load.image('leaf', 'assets/icons/lorc/vine-leaf.png');
        this.load.image('gun', 'assets/icons/john-colburn/pistol-gun.png');
        this.load.image('explosion', 'assets/icons/lorc/bright-explosion.png');
        this.load.image('blood', 'assets/icons/lorc/bleeding-heart.png');
        this.load.image('play', 'assets/icons/guard13007/play-button.png');
        this.load.image('home', 'assets/icons/delapouite/house.png');
        this.load.image('padlock', 'assets/icons/delapouite/plain-padlock.png');
        this.load.image('pause', 'assets/icons/guard13007/pause-button.png');

        // Load Audio
        if (CONFIG.MUSIC) {
            CONFIG.MUSIC.forEach((m, i) => {
                console.log("loaded music ", m, i);
                this.load.audio('music_' + i, "./" + m)
            });
        }
        if (CONFIG.SFX) {
            this.load.on('progress', (value) => {
                const loader = document.getElementById('loader-fill');
                if (loader) loader.style.width = (value * 100) + '%';
            });

            Object.entries(CONFIG.SFX).forEach(([k, v]) => {
                console.log("loading sfx ", k, v);
                this.sound.unlock();
                this.load.audio('sfx_' + k, v);
                this.load.once('filecomplete-audio-sfx_' + k, () => {
                    console.log("Sound is now ready:", k, this.sound.add('sfx_' + k));
                });
            });
        }
        // backward-compat alias for old key 'death' referenced in player._die()
        // (now split into death_enemy / death_player — we alias sfx_death → death_enemy)
    }

    create() {
        // PLEASE WAIT... text
        const W = CONFIG.WIDTH, H = CONFIG.HEIGHT;
        this.add.text(W / 2, H / 2, 'PLEASE WAIT...', {
            fontFamily: "'Fredoka One', sans-serif", fontSize: '24px', fill: '#ffffff'
        }).setOrigin(0.5);

        // Generate background texture (monochrome muddy floor)
        this._generateFloorTexture();

        // Generate rounded rect textures for UI
        const g2 = this.make.graphics({ add: false });
        g2.fillStyle(0xfdfae6, 1);
        //g2.lineStyle(2, 0x1a1a1a, 1);
        g2.fillRoundedRect(0, 0, 64, 64, 16);
        //g2.strokeRoundedRect(0, 0, 64, 64, 16);
        g2.generateTexture('round_rect', 64, 64);

        // Generate a clean, white, borderless rounded rectangle texture
        g2.clear()
        g2.fillStyle(0xffffff, 1); // Pure white for perfect tinting
        g2.fillRoundedRect(0, 0, 64, 64, 8); // 16px corner radius
        g2.generateTexture('bar_round_rect', 64, 64);

        g2.clear();
        g2.lineStyle(4, 0x1a1a1a, 1);
        g2.strokeRoundedRect(2, 2, 60, 60, 16);
        g2.generateTexture('round_rect_outline', 64, 64);
        g2.destroy();

        // Generate placeholder enemy sprites per def.
        // For enemies with an `icon` field the procedural texture is overlaid
        // with the icon image (the icon is drawn at 60% body size, centred).
        for (const [key, def] of Object.entries(ENEMY_DEFS)) {
            this._genEnemyTexture(key, def);
        }

        console.log(":loot? ")

        // Load enemy icon images so they can be overlaid on the procedural texture.
        // Each icon uses a prefixed key 'ei_<name>' so it doesn't clash with UI icons.
        for (const [key, def] of Object.entries(ENEMY_DEFS)) {
            if (!def.icon) continue;
            // The icon field is already the full prefixed key e.g. 'ei_mushroom'.
            // Derive the filename: strip 'ei_' prefix → 'mushroom' → 'lorc/mushroom.png'
            const filename = def.icon.replace(/^ei_/, '').replace(/_/g, '-') + '.png';
            if (!this.textures.exists(def.icon)) {
                this.load.image(def.icon, `assets/icons/lorc/${filename}`);
            }
        }
        this.load.once('complete', () => {
            // Second pass: re-draw enemy textures that have icons now loaded
            for (const [key, def] of Object.entries(ENEMY_DEFS)) {
                if (!def.icon || !this.textures.exists(def.icon)) continue;
                this._genEnemyTextureWithIcon(key, def);
            }
        });
        this.load.start(); // flush the icon requests

        // Player placeholder textures per class
        for (const [key, def] of Object.entries(CLASS_DEFS)) {
            this._genPlayerTexture('player_' + key, def.color, 42, 52);
        }

        // Initialize LootLocker
        if (window.lootLocker) {
            console.log("STARTING LOOTLOCKER SESSION")
            window.lootLocker.startSession();
        }
        else console.log("NOT STARTING LOOTLOCKER SESSION")

        // Hide HTML loading screen
        const loading = document.getElementById('loading');
        if (loading) {
            loading.style.opacity = '0';
            setTimeout(() => loading.remove(), 500);
        }

        this.scene.start('MainMenu');
    }

    _generateFloorTexture() {
        const g = this.make.graphics({ add: false });
        const W = 512, H = 512;
        // Off-white paper background
        g.fillStyle(0xfdfae6);
        g.fillRect(0, 0, W, H);

        // Light blue horizontal lines (college ruled)
        g.lineStyle(2, 0xa2c4c9, 0.8);
        for (let y = 32; y < H; y += 32) g.lineBetween(0, y, W, y);

        // Red vertical margin
        g.lineStyle(3, 0xeaaeb8, 0.9);
        g.lineBetween(60, 0, 60, H);

        g.generateTexture('background', W, H);
        g.destroy();
    }

    // Generate enemy texture WITH an icon image overlaid on the body.
    // Called after all icon images have finished loading.
    _genEnemyTextureWithIcon(key, def) {
        const w = def.width || 32, h = def.height || 32;
        const g = this.make.graphics({ add: false });
        const col = def.color || 0xff00ff;

        // Body fill
        g.fillStyle(col, 1);
        g.fillRoundedRect(0, 0, w, h, Math.min(w, h) * 0.25);

        // Inner highlight
        g.fillStyle(0xffffff, 0.25);
        g.fillRoundedRect(4, 4, w - 8, (h - 8) * 0.45, 4);

        // Elite / boss glow border
        if (def.isElite || def.isBoss) {
            g.lineStyle(3, 0xffffff, 0.8);
            g.strokeRoundedRect(1, 1, w - 2, h - 2, Math.min(w, h) * 0.25);
        }

        g.generateTexture('_ei_body_' + key, w, h);
        g.destroy();

        // Compose: body + icon using RenderTexture
        const rt = this.add.renderTexture(0, 0, w, h).setVisible(false);
        rt.draw('_ei_body_' + key, 0, 0);

        // Draw icon centred at 65% body size, tinted black
        const iconSize = Math.min(w, h) * 0.65;
        rt.draw(def.icon,
            (w - iconSize) / 2, (h - iconSize) / 2,
            1  // alpha
        );
        // Tint icon black on the RenderTexture isn't directly possible; instead
        // we snapshot and replace the game texture.
        rt.saveTexture(key);
        rt.destroy();
    }

    _genEnemyTexture(key, def) {
        const w = def.width || 32, h = def.height || 32;
        const g = this.make.graphics({ add: false });
        const col = def.color || 0xff00ff;

        g.fillStyle(col, 1);
        g.fillRoundedRect(0, 0, w, h, Math.min(w, h) * 0.25);

        // Inner highlight
        g.fillStyle(0xffffff, 0.25);
        g.fillRoundedRect(4, 4, w - 8, (h - 8) * 0.45, 4);

        // Eyes
        g.fillStyle(0x000000, 0.85);
        g.fillCircle(w * 0.3, h * 0.3, Math.max(2, w * 0.08));
        g.fillCircle(w * 0.7, h * 0.3, Math.max(2, w * 0.08));
        // pupils
        g.fillStyle(0xff0000, 0.7);
        g.fillCircle(w * 0.3, h * 0.3, Math.max(1, w * 0.04));
        g.fillCircle(w * 0.7, h * 0.3, Math.max(1, w * 0.04));

        // Mouth (angry zigzag)
        g.lineStyle(2, 0x000000, 0.9);
        g.beginPath();
        const mx = w * 0.2, my = h * 0.6, mw = w * 0.6;
        g.moveTo(mx, my);
        for (let i = 1; i <= 4; i++) {
            g.lineTo(mx + mw * (i / 4), my + (i % 2 === 0 ? -4 : 4));
        }
        g.strokePath();

        // Elite glow border
        if (def.isElite || def.isBoss) {
            g.lineStyle(3, 0xffffff, 0.8);
            g.strokeRoundedRect(1, 1, w - 2, h - 2, Math.min(w, h) * 0.25);
        }

        g.generateTexture(key, w, h);
        g.destroy();
    }

    _genPlayerTexture(key, color, w, h) {
        const g = this.make.graphics({ add: false });
        // Body (banana-shaped oval)
        g.fillStyle(color, 1);
        g.fillEllipse(w / 2, h / 2, w - 6, h - 10);

        // Shine
        g.fillStyle(0xffffff, 0.35);
        g.fillEllipse(w / 2 - 4, h / 2 - 8, w * 0.35, h * 0.25);

        // Eyes
        g.fillStyle(0x000000, 0.9);
        g.fillCircle(w * 0.35, h * 0.38, 4);
        g.fillCircle(w * 0.65, h * 0.38, 4);
        g.fillStyle(0xffffff, 0.9);
        g.fillCircle(w * 0.36, h * 0.37, 1.5);
        g.fillCircle(w * 0.66, h * 0.37, 1.5);

        // Smile
        g.lineStyle(2.5, 0x2c3e50, 0.9);
        g.arc(w / 2, h * 0.55, w * 0.18, 0.1 * Math.PI, 0.9 * Math.PI, false);
        g.strokePath();

        // Stem
        g.fillStyle(0x5d4037, 1);
        g.fillRoundedRect(w / 2 - 3, 2, 6, 12, 3);

        g.generateTexture(key, w, h);
        g.destroy();
    }
}

// ============================================================
//  ClassSelectScene
// ============================================================
class ClassSelectScene extends Phaser.Scene {
    constructor() { super('ClassSelect'); }

    create() {
        const W = CONFIG.WIDTH, H = CONFIG.HEIGHT;

        // Tiled paper floor
        for (let x = 0; x < W; x += 512)
            for (let y = 0; y < H; y += 512)
                this.add.image(x, y, 'background').setOrigin(0, 0);

        // Header decoration
        this.add.rectangle(W / 2, 100, W, 200, 0xa2c4c9, 0.6);
        this.add.rectangle(W / 2, 200, W, 4, 0x1a1a1a, 0.8);

        this.add.image(W / 2 - 170, 54, 'banana').setDisplaySize(32, 32);
        this.add.text(W / 2 + 20, 54, 'BANANA SURVIVORS', {
            fontFamily: "'Fredoka One', sans-serif",
            fontSize: '30px', fill: '#2c3e50',
            stroke: '#ffd700', strokeThickness: 2
        }).setOrigin(0.5);

        this.add.text(W / 2, 92, 'CHOOSE YOUR CLASS', {
            fontFamily: "'Fredoka One', sans-serif",
            fontSize: '16px', fill: '#5d4037'
        }).setOrigin(0.5);

        this.add.text(W / 2, 118, 'Survive. Evolve. Rot.', {
            fontFamily: "'Fredoka One', sans-serif",
            fontSize: '13px', fill: '#888'
        }).setOrigin(0.5);

        // Class cards
        const classes = Object.entries(CLASS_DEFS);
        const rows = classes.length;
        const cardW = W - 50;
        const cardH = 100;
        const startY = 190;

        classes.forEach(([key, def], i) => {
            const row = i;
            const cx = W / 2;
            const cy = startY + row * (cardH + 14);

            // Check unlock
            const stats = this._loadStats();
            let locked = false;
            if (def.unlockCond) {
                const cond = def.unlockCond;
                if (cond.type === 'totalRuns' && stats.totalRuns < cond.value) locked = true;
                if (cond.type === 'maxKills' && stats.maxKills < cond.value) locked = true;
                if (cond.type === 'totalKills' && stats.totalKills < cond.value) locked = true;
                if (cond.type === 'maxLevel' && stats.maxLevel < cond.value) locked = true;
            }

            // Card
            const card = this.add.nineslice(cx, cy, 'round_rect', 0, cardW, cardH, 16, 16, 16, 16)
                .setTint(locked ? 0xcccccc : 0xfdfae6).setInteractive({ useHandCursor: !locked });
            const cardStroke = this.add.nineslice(cx, cy, 'round_rect_outline', 0, cardW, cardH, 16, 16, 16, 16).setTint(locked ? 0x888888 : 0x1a1a1a);

            if (locked) card.setAlpha(0.7);

            // Class icon (actual picture or padlock)
            const texKey = locked ? 'padlock' : (def.source || def.anim || 'player_' + key);
            const icon = this.add.image(cx - cardW / 2 + 50, cy, texKey)
                .setDisplaySize(locked ? 45 : 60, locked ? 45 : 60);

            const iconOGScaleX = icon.scaleX;
            const iconOGScaleY = icon.scaleY;

            if (locked) icon.setTint(0x444444);

            // Class name
            this.add.text(cx - cardW / 2 + 96, cy - 28, locked ? '???' : def.name, {
                fontFamily: "'Fredoka One', sans-serif",
                fontSize: '18px', fill: locked ? '#888' : '#2c3e50'
            });

            // Desc or Unlock Condition
            const descStr = locked ? `LOCKED: ${def.unlockCond.label}` : (def.desc.length > 70 ? def.desc.slice(0, 68) + '…' : def.desc);
            this.add.text(cx - cardW / 2 + 96, cy - 2, descStr, {
                fontFamily: "'Fredoka One', sans-serif",
                fontSize: locked ? '13px' : '11px', fill: locked ? '#cc4444' : '#666',
                wordWrap: { width: cardW - 120 }
            });

            if (!locked) {
                // Core abilities
                const coreAbils = def.abilities.slice(0, 3).join(' · ').replace(/_/g, ' ');
                this.add.text(cx - cardW / 2 + 96, cy + 30, coreAbils, {
                    fontFamily: "'Fredoka One', sans-serif",
                    fontSize: '10px', fill: '#888'
                });

                // Color stripe
                this.add.rectangle(cx - cardW / 2 + 8, cy, 6, cardH - 16, def.color)
                    .setOrigin(0, 0.5).setX(cx - cardW / 2 + 8);
            }

            if (!locked) {
                card.on('pointerover', () => {
                    card.setTint(0xfff3c0);
                    cardStroke.setTint(0xf39c12);
                    this.tweens.add({ targets: [card, cardStroke], scaleX: 1.02, scaleY: 1.02, duration: 80 });
                    this.tweens.add({ targets: [icon], scaleX: iconOGScaleX * 1.2, scaleY: iconOGScaleY * 1.2, duration: 80 });
                });
                card.on('pointerout', () => {
                    card.setTint(0xfffdf0);
                    cardStroke.setTint(0xe0c000);
                    this.tweens.add({ targets: [card, cardStroke], scaleX: 1, scaleY: 1, duration: 80 });
                    this.tweens.add({ targets: [icon], scaleX: iconOGScaleX, scaleY: iconOGScaleY, duration: 80 });
                });
                card.on('pointerdown', () => this._selectClass(key));
            }
        });

        this.input.keyboard.on('keydown-ESC', () => this.scene.start('MainMenu'));

        // Best score display
        const best = this._loadBest();
        if (best) {
            this.add.rectangle(W / 2, H - 55, W - 20, 70, 0x2c3e50, 0.9)
                .setStrokeStyle(2, 0xffd700);
            // Icons tinted black per default icon color policy
            this.add.image(W / 2 - 45, H - 70, 'trophy').setDisplaySize(16, 16).setTint(0x000000);
            this.add.text(W / 2 + 10, H - 70, 'BEST RUN', {
                fontFamily: "'Fredoka One', sans-serif", fontSize: '12px', fill: '#ffd700'
            }).setOrigin(0.5);
            this.add.text(W / 2, H - 50, `${best.className}  LV${best.level}  ${best.kills} kills  ${best.time}`, {
                fontFamily: "'Fredoka One', sans-serif", fontSize: '12px', fill: '#eee'
            }).setOrigin(0.5);
            this.add.text(W / 2, H - 32, `Survived ${best.survivedTime}`, {
                fontFamily: "'Fredoka One', sans-serif", fontSize: '11px', fill: '#aaa'
            }).setOrigin(0.5);
        }
    }

    _selectClass(key) {
        this.cameras.main.fade(300, 0, 0, 0, false, (cam, progress) => {
            if (progress >= 1) this.scene.start('Game', { classKey: key });
        });
    }

    _loadBest() {
        try { return JSON.parse(localStorage.getItem('banana_best')); }
        catch { return null; }
    }

    _loadStats() {
        try {
            const stats = JSON.parse(localStorage.getItem('banana_stats') || 'null');
            return stats || { totalRuns: 0, maxKills: 0, totalKills: 0, maxLevel: 0 };
        } catch {
            return { totalRuns: 0, maxKills: 0, totalKills: 0, maxLevel: 0 };
        }
    }
}

// ============================================================
//  MainMenuScene
// ============================================================
class MainMenuScene extends Phaser.Scene {
    constructor() { super('MainMenu'); }

    create() {
        const W = CONFIG.WIDTH, H = CONFIG.HEIGHT;

        // Tiled paper floor
        for (let x = 0; x < W; x += 512)
            for (let y = 0; y < H; y += 512)
                this.add.image(x, y, 'background').setOrigin(0, 0);

        // Logo / Title
        const logoY = H * 0.28;
        this.add.image(W / 2, logoY - 110, 'banana').setDisplaySize(80, 80).setAngle(0);
        this.add.text(W / 2, logoY, 'BANANA\nSURVIVORS', {
            fontFamily: "'Fredoka One', sans-serif", fontSize: '48px', fill: '#2c3e50',
            stroke: '#ffd700', strokeThickness: 4, align: 'center'
        }).setOrigin(0.5);

        // Player Name Label (Transparent BG, clickable)
        const playerName = localStorage.getItem('player_name');
        const nameLabel = this.add.text(W / 2, logoY + 90, `YOU ARE: ${playerName || '???'}`.toUpperCase(), {
            fontFamily: "'Fredoka One', sans-serif", fontSize: '18px', fill: '#2c3e50',
            backgroundColor: 'transparent',
            padding: { x: 10, y: 5 }
        }).setOrigin(0.5).setInteractive({ useHandCursor: true });

        nameLabel.on('pointerover', () => nameLabel.setTint(0xf39c12));
        nameLabel.on('pointerout', () => nameLabel.clearTint());
        nameLabel.on('pointerdown', () => this._promptNameUpdate(nameLabel));

        // Auto-prompt if no name
        if (!playerName) {
            this.time.delayedCall(1000, () => this._promptNameUpdate(nameLabel));
        }

        // Process pending score from crash if it exists
        this._processPendingScore();

        // Buttons
        const startY = H * 0.55;
        const spacing = 70;

        UIManager.createMenuButton(this, W / 2, startY, 240, 56, 'Play', () => {
            this.scene.start('ClassSelect');
        });

        UIManager.createMenuButton(this, W / 2, startY + spacing, 240, 56, 'Leaderboard', () => {
            this.scene.start('Leaderboard');
        });

        UIManager.createMenuButton(this, W / 2, startY + spacing * 2, 240, 56, 'Stats', () => {
            this.scene.start('Stats');
        });

        // Global Navigation
        this.input.keyboard.on('keydown-ESC', () => {
            // Main menu ESC could exit or do nothing
        });

        // Best score display (bottom)
        const best = this._loadBest();
        if (best) {
            const footer = this.add.container(W / 2, H - 70);
            const bg = this.add.rectangle(0, 0, W - 40, 80, 0x2c3e50, 0.85).setStrokeStyle(2, 0xffd700);
            const trophy = this.add.image(-W / 2 + 60, -15, 'trophy').setDisplaySize(20, 20).setTint(0xffd700);
            const title = this.add.text(0, -22, 'LIFETIME BEST', {
                fontFamily: "'Fredoka One', sans-serif", fontSize: '13px', fill: '#ffd700'
            }).setOrigin(0.5);
            const data = this.add.text(0, 5, `${best.className} • LV${best.level} • ${best.kills} KILLS • ${best.survivedTime}`, {
                fontFamily: "'Fredoka One', sans-serif", fontSize: '14px', fill: '#eee'
            }).setOrigin(0.5);
            footer.add([bg, trophy, title, data]);
        }
    }

    _promptNameUpdate(label) {
        UIManager.showNameInput(this, localStorage.getItem('player_name'), (newName) => {
            localStorage.setItem('player_name', newName);
            label.setText(`YOU ARE: ${newName}`.toUpperCase());
            window.lootLocker.setPlayerName(newName);
        });
    }

    _loadBest() {
        try { return JSON.parse(localStorage.getItem('banana_best')); }
        catch { return null; }
    }

    async _processPendingScore() {
        let pending = localStorage.getItem('banana_pending_score');
        if (!pending) return;
        try {
            let pendingList = JSON.parse(pending);
            if (!Array.isArray(pendingList)) pendingList = [{ runId: 'legacy', data: pendingList }];
            if (pendingList.length === 0) return;

            let playerName = localStorage.getItem('player_name') || 'Anonymous';
            await window.lootLocker.setPlayerName(playerName);

            const remaining = [];
            for (const p of pendingList) {
                try {
                    const run = p.data;
                    const metadata = { class: run.className, time: run.survivedTime, lvl: run.level };
                    console.log("Found crashed pending score, submitting...");
                    await window.lootLocker.submitScore(run.kills, metadata);
                } catch (e) {
                    console.error("Failed to process one pending score", e);
                    remaining.push(p);
                }
            }

            if (remaining.length > 0) {
                localStorage.setItem('banana_pending_score', JSON.stringify(remaining));
            } else {
                localStorage.removeItem('banana_pending_score');
            }
        } catch (e) {
            console.error("Failed to parse pending score array", e);
        }
    }

}

// ============================================================
//  LeaderboardScene
// ============================================================
class LeaderboardScene extends Phaser.Scene {
    constructor() { super('Leaderboard'); }

    async create() {
        const W = CONFIG.WIDTH, H = CONFIG.HEIGHT;
        for (let x = 0; x < W; x += 512)
            for (let y = 0; y < H; y += 512)
                this.add.image(x, y, 'background').setOrigin(0, 0);

        this.panel = UIManager.createMenuPanel(this, W / 2, H / 2, W - 40, H - 100, 'Leaderboard');
        this.listItems = [];
        this._fetchScores();

        UIManager.createMenuButton(this, W / 2, H - 85, 160, 44, 'Back', () => {
            this.scene.start('MainMenu');
        });

        this.input.keyboard.on('keydown-ESC', () => this.scene.start('MainMenu'));
    }

    async _processPendingScore() {
        let pending = localStorage.getItem('banana_pending_score');
        if (!pending) return;
        try {
            let pendingList = JSON.parse(pending);
            if (!Array.isArray(pendingList)) pendingList = [{ runId: 'legacy', data: pendingList }];
            if (pendingList.length === 0) return;

            let playerName = localStorage.getItem('player_name') || 'Anonymous';
            await window.lootLocker.setPlayerName(playerName);

            const remaining = [];
            for (const p of pendingList) {
                try {
                    const run = p.data;
                    const metadata = { class: run.className, time: run.survivedTime, lvl: run.level };
                    console.log("Found crashed pending score, submitting...");
                    await window.lootLocker.submitScore(run.kills, metadata);
                } catch (e) {
                    console.error("Failed to process one pending score", e);
                    remaining.push(p);
                }
            }

            if (remaining.length > 0) {
                localStorage.setItem('banana_pending_score', JSON.stringify(remaining));
            } else {
                localStorage.removeItem('banana_pending_score');
            }
        } catch (e) {
            console.error("Failed to parse pending score array", e);
        }
    }

    async _fetchScores() {
        const W = CONFIG.WIDTH, H = CONFIG.HEIGHT;

        // Clean up old items
        this.listItems.forEach(i => i.destroy());
        this.listItems = [];
        if (this.reloadBtn) { this.reloadBtn.destroy(); this.reloadBtn = null; }

        const loading = this.add.text(W / 2, H / 2, 'FETCHING SCORES...', {
            fontFamily: "'Fredoka One', sans-serif", fontSize: '18px', fill: '#888'
        }).setOrigin(0.5);
        this.listItems.push(loading);

        try {
            const response = { items: await window.lootLocker.getTopScores(15) };
            loading.destroy();

            if (!response.items || response.items.length === 0) {
                const noScores = this.add.text(W / 2, H / 2, !response.items && 'You are offline...' || 'NO SCORES YET', {
                    fontFamily: "'Fredoka One', sans-serif", fontSize: '20px', fill: '#666'
                }).setOrigin(0.5);
                this.listItems.push(noScores);
            } else {
                response.items.forEach((item, i) => {
                    const py = 160 + i * 42;
                    const r = this.add.text(60, py, `#${item.rank}`, {
                        fontFamily: "'Fredoka One', sans-serif", fontSize: '16px', fill: '#2c3e50'
                    }).setOrigin(0, 0.5);

                    const n = this.add.text(100, py, item.player.name || `Player ${item.player.id}`, {
                        fontFamily: "'Fredoka One', sans-serif", fontSize: '16px', fill: '#2c3e50', fontWeight: 'bold'
                    }).setOrigin(0, 0.5);

                    const s = this.add.text(W - 60, py, item.score.toString(), {
                        fontFamily: "'Fredoka One', sans-serif", fontSize: '16px', fill: '#e67e22'
                    }).setOrigin(1, 0.5);

                    this.listItems.push(r, n, s);

                    if (item.metadata) {
                        try {
                            const meta = JSON.parse(item.metadata);
                            const m = this.add.text(100, py + 12, `${meta.class} • ${meta.time}`, {
                                fontFamily: "'Fredoka One', sans-serif", fontSize: '10px', fill: '#888'
                            }).setOrigin(0, 0.5);
                            this.listItems.push(m);
                        } catch (e) { }
                    }
                });
            }
        } catch (e) {
            loading.setText('OFFLINE');
            this.reloadBtn = UIManager.createMenuButton(this, W / 2, H / 2 + 50, 140, 40, 'Reload', () => {
                this._fetchScores();
            });
        }
    }
}

// ============================================================
//  StatsScene
// ============================================================
class StatsScene extends Phaser.Scene {
    constructor() { super('Stats'); }

    create() {
        const W = CONFIG.WIDTH, H = CONFIG.HEIGHT;
        for (let x = 0; x < W; x += 512)
            for (let y = 0; y < H; y += 512)
                this.add.image(x, y, 'background').setOrigin(0, 0);

        const panel = UIManager.createMenuPanel(this, W / 2, H / 2, W - 40, H - 100, 'Your Stats');

        const stats = this._loadStats();
        const statLines = [
            { label: 'Total Runs', value: stats.totalRuns },
            { label: 'Total Kills', value: stats.totalKills },
            { label: 'Max Kills (One Run)', value: stats.maxKills },
            { label: 'Highest Level', value: stats.maxLevel },
            { label: 'Time Survived', value: this._formatTime(stats.totalTime || 0) },
            { label: 'Pulp Collected', value: Math.floor(stats.totalPulp || 0) }
        ];

        statLines.forEach((s, i) => {
            const py = 180 + i * 50;
            this.add.text(60, py, s.label.toUpperCase(), {
                fontFamily: "'Fredoka One', sans-serif", fontSize: '14px', fill: '#666'
            }).setOrigin(0, 0.5);

            this.add.text(W - 60, py, s.value.toString(), {
                fontFamily: "'Fredoka One', sans-serif", fontSize: '20px', fill: '#2c3e50', fontWeight: 'bold'
            }).setOrigin(1, 0.5);

            this.add.line(W / 2, py + 25, 0, 0, W - 100, 0, 0x000000, 0.1);
        });

        UIManager.createMenuButton(this, W / 2, H - 85, 160, 44, 'Back', () => {
            this.scene.start('MainMenu');
        });

        this.input.keyboard.on('keydown-ESC', () => this.scene.start('MainMenu'));
    }

    _loadStats() {
        try {
            return JSON.parse(localStorage.getItem('banana_stats')) || { totalRuns: 0, totalKills: 0, maxKills: 0, maxLevel: 0, totalTime: 0, totalPulp: 0 };
        } catch { return { totalRuns: 0, totalKills: 0, maxKills: 0, maxLevel: 0, totalTime: 0, totalPulp: 0 }; }
    }

    _formatTime(sec) {
        const h = Math.floor(sec / 3600);
        const m = Math.floor((sec % 3600) / 60);
        const s = Math.floor(sec % 60);
        if (h > 0) return `${h}h ${m}m ${s}s`;
        if (m > 0) return `${m}m ${s}s`;
        return `${s}s`;
    }
}

// ============================================================
//  GameScene — main gameplay
//  Where the main game happens and all creatures and entities are spawned.
// ============================================================
class GameScene extends Phaser.Scene {
    constructor() { super('Game'); }

    init(data) {
        this.classKey = data.classKey || 'alchemist';
    }

    create() {
        // World size (larger than viewport)
        this.worldW = CONFIG.WIDTH * 3;
        this.worldH = CONFIG.HEIGHT * 3;

        // Background tiled
        for (let x = 0; x < this.worldW; x += 256)
            for (let y = 0; y < this.worldH; y += 256)
                this.add.image(x + 128, y + 128, 'background').setDisplaySize(256, 256).setAlpha(0.85);

        // World bounds
        const border = this.add.graphics();
        border.lineStyle(6, 0xffd700, 0.6);
        border.strokeRect(2, 2, this.worldW - 4, this.worldH - 4);

        // Camera
        this.cameras.main.setBounds(0, 0, this.worldW, this.worldH);
        this.cameras.main.setZoom(1.45);

        // Game state
        this.enemies = [];
        this.pulpGems = [];
        this.paused = false;
        this.survivedSec = 0;
        this.totalKills = 0;
        this.totalPulpCollected = 0;

        // Music Loop
        this.currentMusic = null;
        this._playRandomMusic();

        // XP / Level
        this.xp = 0;
        this.level = 1;
        this.xpNeeded = CONFIG.PULP_PER_LEVEL[1] || 10;
        this.levelUpPending = false;

        // Progressive stat tracking
        this._lastSyncedKills = 0;
        this._lastSyncedTime = 0;
        this._lastSyncedPulp = 0;
        this._lastStatSyncTime = 0;
        this._lastScoreSyncTime = 0;
        this.runId = Date.now().toString();

        // Increment totalRuns at start of game
        try {
            const stats = JSON.parse(localStorage.getItem('banana_stats') || '{"totalRuns":0,"totalKills":0,"maxKills":0,"maxLevel":0,"totalTime":0,"totalPulp":0}');
            stats.totalRuns++;
            localStorage.setItem('banana_stats', JSON.stringify(stats));
        } catch (e) { }

        // Player
        this.player = new Player(this, this.worldW / 2, this.worldH / 2, this.classKey);

        // Camera follow
        this.cameras.main.startFollow(this.player.sprite, true, 0.1, 0.1);

        // Systems
        this.spawner = new WaveSpawner(this);
        this.ui = {
            updateHp: () => { }, updateLevel: () => { }, updateAbilities: () => { }, updateXp: () => { },
            updateTimer: () => { }, updateKills: () => { }, showUpgrades: () => { },
            joyActive: false, joyInput: { x: 0, y: 0 }
        };
        this.scene.launch('UI');
        this.upgradeManager = new UpgradeManager(this);

        // Keyboard
        this.cursors = this.input.keyboard.createCursorKeys();
        this.wasd = this.input.keyboard.addKeys({ up: 'W', down: 'S', left: 'A', right: 'D' });
        this.input.keyboard.on('keydown-ESC', () => this._togglePause());

        // Mobile Back Button / PWA Intercept
        history.pushState(null, null, location.href);
        this._popstateHandler = (e) => {
            if (this.scene.isActive('Game')) {
                this._togglePause();
                history.pushState(null, null, location.href); // Push again to keep intercepting
            }
        };
        window.addEventListener('popstate', this._popstateHandler);

        // Events
        this.events.on('player_hp_changed', (hp, max) => this.ui.updateHp(hp, max));
        this.events.on('player_dead', () => this._onPlayerDead());
        this.events.on('pulp_collected', (v) => this._onPulpCollected(v));
        this.events.on('enemy_killed', (e) => this._onEnemyKilled(e));
        this.events.on('upgrade_closed', () => { console.log("unpaused"); this.paused = false; });
        this.events.on('difficulty_up', (lv) => {
            GameUtils.floatText(this, this.player.x, this.player.y - 80,
                '⚠ DIFFICULTY ' + lv, '#ff6622', 16);
        });

        this.events.on('request_pause', () => this._togglePause());
        this.events.on('shutdown', () => {
            window.removeEventListener('popstate', this._popstateHandler);
        });
        // ── SFX: Boss spawn warhorn ─────────────────────────────────
        this.events.on('boss_spawn', () => {
            if (this.sound.get('sfx_boss_spawn')) this.sound.play('sfx_boss_spawn', { volume: 0.7 });
        });

        // Fermented One (10% chance from previous run)
        // Fermented One (10% chance from previous run)
        this._trySpawnFermented();

        // Fade in
        this.cameras.main.fadeIn(400);

        // In create():
        this.fx = new SceneFX(this, { depth: 190 });
        this.fx.enable('vignette', { intensity: 0.5 });
        this.fx.enable('scanlines', { alpha: 0.07 });
        this.fx.enable('chromatic', { offset: 1.5, animated: true });
        this.fx.enable('grain', { alpha: 0.04 });
        this.fx.enable('overlay', { color: 0xff0000, alpha: 0 }); // red for low HP

        // Low-HP pulse (call from player_hp_changed handler):
        this.events.on('player_hp_changed', (hp, max) => {
            const t = 1 - (hp / max);
            this.fx.setOverlayAlpha(t * 0.25); // fades in as HP drops
        });

        // Tutorial Popup (One-time)
        if (!localStorage.getItem('tutorialPopUpOpened')) {
            this.paused = true;
            this.time.delayedCall(1200, () => {
                if (this.ui && this.ui.scene) {
                    UIManager.showTutorial(this.ui.scene, () => {
                        this.paused = false;
                        localStorage.setItem('tutorialPopUpOpened', 'true');
                    });
                } else {
                    this.paused = false;
                }
            });
        }
    }

    _showPauseOverlay() {
        if (!this.ui || !this.ui.scene) return;
        const uiScene = this.ui.scene;
        const W = CONFIG.WIDTH, H = CONFIG.HEIGHT;
        this.pauseOverlay = uiScene.add.container(0, 0).setDepth(4000);

        const bg = uiScene.add.rectangle(W / 2, H / 2, W, H, 0x000000, 0.6).setInteractive();
        this.pauseOverlay.add(bg);

        const panel = UIManager.createMenuPanel(uiScene, W / 2, H / 2, 300, 250, 'PAUSED');
        panel.bg.setDepth(4001); panel.stroke.setDepth(4002); panel.title.setDepth(4003);
        this.pauseOverlay.add([panel.bg, panel.stroke, panel.title]);

        const resumeBtn = UIManager.createMenuButton(uiScene, W / 2, H / 2, 200, 50, 'CONTINUE', () => {
            this._togglePause(); // Use unified toggle
        });
        resumeBtn.btn.setDepth(4004); resumeBtn.stroke.setDepth(4005); resumeBtn.txt.setDepth(4006);

        const quitBtn = UIManager.createMenuButton(uiScene, W / 2, H / 2 + 70, 200, 50, 'QUIT', () => {
            this._hidePauseOverlay();
            window.removeEventListener('popstate', this._popstateHandler);
            this.scene.stop('UI');
            this.scene.start('MainMenu');
        });
        quitBtn.btn.setDepth(4004); quitBtn.stroke.setDepth(4005); quitBtn.txt.setDepth(4006);

        this.pauseOverlay.add([resumeBtn.btn, resumeBtn.stroke, resumeBtn.txt, quitBtn.btn, quitBtn.stroke, quitBtn.txt]);
        this._pauseUIElements = [resumeBtn, quitBtn, panel, bg];
    }

    _togglePause() {
        this.paused = !this.paused;
        if (this.paused) {
            this._showPauseOverlay();
        } else {
            this._hidePauseOverlay();
        }
    }

    _hidePauseOverlay() {
        if (this.pauseOverlay) {
            if (this._pauseUIElements) this._pauseUIElements.forEach(e => e.destroy());
            this.pauseOverlay.destroy();
            this.pauseOverlay = null;
        }
    }

    _playRandomMusic() {
        if (!CONFIG.MUSIC || CONFIG.MUSIC.length === 0) return;

        // ── Music Transition Fix ────────────────────────────────────
        // Stop all sounds before starting a new music track to ensure 
        // no overlaps, then restart any essential ambient loops if needed.
        this.sound.stopAll();
        this.currentMusic = null;

        const idx = Phaser.Math.Between(0, CONFIG.MUSIC.length - 1);
        this.currentMusic = this.sound.add('music_' + idx, { volume: 0.35, loop: false });
        this.currentMusic.play();
        this.currentMusic.once('complete', () => {
            if (this.scene.isActive('Game')) this._playRandomMusic();
        });
    }

    _trySpawnFermented() {
        if (Math.random() > CONFIG.FERMENTED_SPAWN_CHANCE) return;
        try {
            const saved = JSON.parse(localStorage.getItem('banana_last_run'));
            if (!saved) return;
            const ex = Phaser.Math.Between(200, this.worldW - 200);
            const ey = Phaser.Math.Between(200, this.worldH - 200);
            // Spawn as a tough enemy using bruiser color
            const fermented = new Enemy(this, ex, ey, 'fungal_horror', 2.5);
            fermented.def.color = 0x800080;
            fermented.sprite.setFillStyle(0x800080);
            this.enemies.push(fermented);
            // Ghost icon tinted black (default icon color policy)
            this.add.image(this.player.x - 130, this.player.y - 80, 'ghost').setDisplaySize(20, 20).setDepth(50).setTint(0x000000);
            GameUtils.floatText(this, this.player.x + 10, this.player.y - 80,
                'THE FERMENTED ONE AWAKENS', '#aa00ff', 18);
        } catch { }
    }

    update(time, delta) {
        if (this.paused || this.player.dead) return;

        this.survivedSec += delta / 1000;
        this.ui.updateTimer(this.survivedSec);

        // Periodic syncing
        if (time - this._lastStatSyncTime > 2000) {
            this._syncProgressiveStats();
            this._lastStatSyncTime = time;
        }
        if (time - this._lastScoreSyncTime > 10000) {
            this._syncPendingScore();
            this._lastScoreSyncTime = time;
        }

        // In update():
        this.fx.update(time, delta);

        // Input
        this._handleInput();

        // Player update
        this.player.update(delta, this._allEntities());

        // Enemies
        const allEntities = this._allEntities();
        for (let i = this.enemies.length - 1; i >= 0; i--) {
            const e = this.enemies[i];
            if (e.dead) { this.enemies.splice(i, 1); continue; }
            e.update(delta, allEntities);
            // Thorns passive
            this._checkThornsAndCharge(e);
        }

        // Enemy-enemy collision separation (CONFIG.ENEMIES_COLLIDE toggle)
        // Prevents enemies from stacking on top of each other into a single hitbox pile.
        if (CONFIG.ENEMIES_COLLIDE) {
            resolveEnemyCollisions(this.enemies);
        }

        // Pulp gems
        const mr = this.player.magnetRadius;
        for (let i = this.pulpGems.length - 1; i >= 0; i--) {
            const g = this.pulpGems[i];
            if (g.dead) { this.pulpGems.splice(i, 1); continue; }
            g.update(delta, this.player.x, this.player.y, mr);
        }

        // Enemy-player collision (deal damage)
        this._checkPlayerHit();

        // Spawner
        this.spawner.update(delta);

        // Abilities bar refresh
        if (time % 3000 < delta) this.ui.updateAbilities(this.player.abilities);
    }

    _handleInput() {
        let vx = 0, vy = 0;

        // Keyboard
        if (this.cursors.left.isDown || this.wasd.left.isDown) vx -= 1;
        if (this.cursors.right.isDown || this.wasd.right.isDown) vx += 1;
        if (this.cursors.up.isDown || this.wasd.up.isDown) vy -= 1;
        if (this.cursors.down.isDown || this.wasd.down.isDown) vy += 1;

        // Joystick
        if (this.ui.joyActive) {
            vx += this.ui.joyInput.x;
            vy += this.ui.joyInput.y;
        }

        // Normalize
        const len = Math.sqrt(vx * vx + vy * vy);
        if (len > 0) { vx /= len; vy /= len; }

        this.player.setVelocity(vx, vy);
    }

    _allEntities() {
        return [this.player, ...this.enemies];
    }

    _checkThornsAndCharge(e) {
        const dist = Phaser.Math.Distance.Between(this.player.x, this.player.y, e.x, e.y);
        const touchRange = e.width / 2 + this.player.width / 2;
        if (dist < touchRange) {
            // Thorns
            for (const abl of this.player.abilities) {
                if (abl instanceof Thorns) abl.onEnemyTouch(e);
            }
            // Unstoppable charge
            for (const abl of this.player.abilities) {
                if (abl instanceof UnstoppableCharge && abl._charging) {
                    const dmg = 50 * this.player.damageMult;
                    e.takeDamage(dmg, this.player.x, this.player.y);
                }
            }
        }
    }

    _checkPlayerHit() {
        for (const e of this.enemies) {
            if (e.dead) continue;
            const dist = Phaser.Math.Distance.Between(this.player.x, this.player.y, e.x, e.y);
            if (dist < e.width / 2 + this.player.width / 2 - 8) {
                if (!e.attackCooldown) e.attackCooldown = 0;
                e.attackCooldown -= 16;
                if (e.attackCooldown <= 0) {
                    e.attackCooldown = 1000;
                    let dmg = e.def.damage || 5;
                    // Iron Rind DR
                    for (const abl of this.player.abilities) {
                        if (abl instanceof IronRind) dmg = Math.max(1, dmg - abl.getDR());
                    }
                    this.player.takeDamage(dmg);
                }
            }
        }
    }

    spawnPulp(x, y, value, refined = false) {
        const gem = new PulpGem(this, x, y, value, refined);
        this.pulpGems.push(gem);
    }

    _onPulpCollected(value) {
        // Give XP
        this.xp += Math.round(value * this.player.xpMult);
        this.totalPulpCollected += value;
        if (this.sound.get('sfx_collect')) this.sound.play('sfx_collect', { volume: 0.4, rate: 0.8 + Math.random() * 0.4 });

        const needed = CONFIG.PULP_PER_LEVEL[Math.min(this.level, CONFIG.PULP_PER_LEVEL.length - 1)] || (this.level * 80);
        this.xpNeeded = needed;
        this.ui.updateXp(this.xp, needed);
        if (this.xp >= needed && !this.levelUpPending) {
            this.xp -= needed;
            this._levelUp();
        }
    }

    _levelUp() {
        // In _levelUp():
        this.fx.levelUp(this.player.x, this.player.y);
        this.fx.flashScreen(0xffd700, 0.4, 400);


        this.levelUpPending = true;
        this.level++;
        this.xpNeeded = Math.floor(this.xpNeeded * 1.25 + 10);
        this.ui.updateLevel(this.level);
        this.paused = true;

        // ── SFX: Level-up chime ─────────────────────────────────────
        if (this.sound.get('sfx_levelup')) this.sound.play('sfx_levelup', { volume: 0.6 });
        else if (this.sound.get('sfx_powerup')) this.sound.play('sfx_powerup', { volume: 0.6 });;

        // Screen flash
        const flash = this.add.rectangle(CONFIG.WIDTH / 2, CONFIG.HEIGHT / 2, CONFIG.WIDTH, CONFIG.HEIGHT, 0xffd700, 0.5)
            .setScrollFactor(0).setDepth(198);
        this.tweens.add({ targets: flash, alpha: 0, duration: 400, onComplete: () => flash.destroy() });

        // Show upgrades
        const options = this.upgradeManager.getOptions(this.classKey);
        this.ui.showUpgrades(options, (upg) => {
            this.player.applyUpgrade(upg);
            this.ui.updateAbilities(this.player.abilities);
            this.levelUpPending = false;
        });
    }

    _onEnemyKilled(e) {

        // In _onEnemyKilled():
        this.fx.explosion(e.x, e.y, { color: e.def.color ?? 0xff4400 });
        this.fx.screenShake(4, 150);


        this.totalKills++;
        this.ui.updateKills(this.totalKills);
        // Notify passive abilities
        for (const abl of this.player.abilities) {
            abl.onEnemyKilled?.(e);
        }
        // ── SFX: Enemy death sound (elite/boss use alternate) ───────
        if (e.isElite || e.isBoss) {
            if (this.sound.get('sfx_death_enemy2')) this.sound.play('sfx_death_enemy2', { volume: 0.5, rate: 0.8 });
        } else {
            if (this.sound.get('sfx_death_enemy')) this.sound.play('sfx_death_enemy', { volume: 0.4, rate: 0.9 + Math.random() * 0.3 });
        }
    }

    _onPlayerDead() {

        // In _onPlayerDead():
        this.fx.flashScreen(0xff0000, 0.7, 800);
        this.fx.slowMotion(0.2, 1000);

        this.paused = true;

        // ── PLAYER DEATH SAVE ───────────────────────────────────────────────────
        // This block is what persists across runs and powers the "Fermented One"
        // enemy (see _trySpawnFermented). Only upgrades unrelated to pulp/XP
        // collection are saved, so the reborn enemy isn't unfairly handicapped
        // by magnet-range or XP-multiplier bonuses that don't apply to it.
        //
        // Specifically excluded from save:
        //   - 'magnet'       (pulp magnet radius, meaningless for an enemy)
        //   - 'magnet_up'    (same)
        //   - 'molecular_rebuild' (XP gem doubler, enemy-irrelevant)
        //   - 'soul_siphon'  (pulls pulp gems to the player)
        //   - any upgrade whose id contains 'pulp' or 'xp'
        //
        // Everything else (damage, speed, hp, atk speed, aoe, crit, regen) IS
        // saved and can be used when the enemy spawns in the next run.

        // IDs of abilities that are pulp/XP-related and should NOT be saved
        const PULP_ABILITY_KEYS = new Set(['molecular_rebuild', 'soul_siphon']);
        // IDs of stat upgrades that are pulp/XP-related and should NOT be saved
        const PULP_UPGRADE_IDS = new Set(['magnet', 'magnet_up']);

        const savedAbilities = this.player.abilities
            .map(a => a.key)
            .filter(k => !PULP_ABILITY_KEYS.has(k));           // strip pulp abilities

        const runData = {
            classKey: this.classKey,
            className: CLASS_DEFS[this.classKey]?.name,
            level: this.level,
            kills: this.totalKills,
            survivedSec: this.survivedSec,
            survivedTime: Math.floor(this.survivedSec / 60) + ':' + String(Math.floor(this.survivedSec % 60)).padStart(2, '0'),
            // Only save non-pulp abilities so the Fermented One carries over
            // combat power without inheriting XP-collection bonuses.
            abilities: savedAbilities,
            time: new Date().toLocaleDateString(),
        };

        // Update persistent stats final time
        this._syncProgressiveStats();

        // Handle Best Run
        this._checkBestRun(runData);

        console.log("dead player")
        // Leaderboard Submission
        this._handleScoreSubmission(runData);

        // Clear only this run's pending score from the array
        try {
            let pendingList = JSON.parse(localStorage.getItem('banana_pending_score') || '[]');
            if (Array.isArray(pendingList)) {
                pendingList = pendingList.filter(p => p.runId !== this.runId);
                if (pendingList.length > 0) {
                    localStorage.setItem('banana_pending_score', JSON.stringify(pendingList));
                } else {
                    localStorage.removeItem('banana_pending_score');
                }
            }
        } catch (e) { }

        // Transition to GameOver after a short delay
        this.time.delayedCall(1500, () => {
            this.scene.stop('UI');
            this.scene.start('GameOver', runData);
        });
    }

    _syncProgressiveStats() {
        try {
            const stats = JSON.parse(localStorage.getItem('banana_stats') || '{"totalRuns":0,"totalKills":0,"maxKills":0,"maxLevel":0,"totalTime":0,"totalPulp":0}');

            const newKills = this.totalKills - this._lastSyncedKills;
            const newTime = this.survivedSec - this._lastSyncedTime;
            const newPulp = this.totalPulpCollected - this._lastSyncedPulp;

            stats.totalKills += newKills;
            stats.totalTime = (stats.totalTime || 0) + newTime;
            stats.totalPulp = (stats.totalPulp || 0) + newPulp;
            if (this.totalKills > stats.maxKills) stats.maxKills = this.totalKills;
            if (this.level > stats.maxLevel) stats.maxLevel = this.level;

            localStorage.setItem('banana_stats', JSON.stringify(stats));

            this._lastSyncedKills = this.totalKills;
            this._lastSyncedTime = this.survivedSec;
            this._lastSyncedPulp = this.totalPulpCollected;
        } catch (e) { }
    }

    _syncPendingScore() {
        try {
            const runData = {
                classKey: this.classKey,
                className: CLASS_DEFS[this.classKey]?.name,
                level: this.level,
                kills: this.totalKills,
                survivedSec: this.survivedSec,
                survivedTime: Math.floor(this.survivedSec / 60) + ':' + String(Math.floor(this.survivedSec % 60)).padStart(2, '0'),
                time: new Date().toLocaleDateString(),
            };

            let pendingList = JSON.parse(localStorage.getItem('banana_pending_score') || '[]');
            if (!Array.isArray(pendingList)) pendingList = [];

            const idx = pendingList.findIndex(p => p.runId === this.runId);
            if (idx >= 0) pendingList[idx].data = runData;
            else pendingList.push({ runId: this.runId, data: runData });

            localStorage.setItem('banana_pending_score', JSON.stringify(pendingList));
        } catch (e) { }
    }

    _checkBestRun(run) {
        try {
            const best = JSON.parse(localStorage.getItem('banana_best') || 'null');
            if (!best || run.kills > best.kills || (run.kills === best.kills && run.survivedSec > best.survivedSec)) {
                localStorage.setItem('banana_best', JSON.stringify(run));
            }
        } catch (e) { }
    }

    async _handleScoreSubmission(run) {
        console.log("trying to submit a score")
        let playerName = localStorage.getItem('player_name');
        if (!playerName) {
            playerName = window.prompt("NEW HERO! ENTER YOUR NAME:", "Banana Warrior");
            if (!playerName) playerName = "Anonymous";
            localStorage.setItem('player_name', playerName);
        }
        // Always sync name before submission for safety
        await window.lootLocker.setPlayerName(playerName);

        const metadata = {
            class: run.className,
            time: run.survivedTime,
            lvl: run.level
        };

        console.log("awaaiting score submission", metadata)
        const scoreData = await window.lootLocker.submitScore(run.kills, metadata);
        console.log("score submitted", scoreData)
    }
}


// ============================================================
//  UpgradeManager
// ============================================================
class UpgradeManager {
    constructor(scene) {
        this.scene = scene;
        this.pickedIds = new Set();
    }

    getOptions(classKey) {
        const classDef = CLASS_DEFS[classKey];
        const abilityKeys = classDef?.abilities || [];
        const player = this.scene.player;

        // Build pool: stat upgrades + unlockable abilities the player doesn't have yet
        let pool = [...UPGRADE_POOL];
        const iconMap = {
            'zapping_stem': 'lightning', 'static_peel': 'magnet', 'acid_rain': 'skull', 'solar_flare': 'explosion',
            'heavy_slap': 'banana_icon', 'spin_kick': 'banana', 'shockwave': 'explosion', 'fruit_bat_swarm': 'bat'
        };

        for (const [key, AbilityClass] of Object.entries(ABILITY_CLASSES)) {
            // Only suggest abilities available for this class
            if (!CLASS_DEFS[classKey].abilities.includes(key)) continue;

            if (player.abilities.find(a => a.key === key)) {
                // If they already have it, we can still show it for "stacking"
            }

            // Instantiate a dummy version to extract its description
            let ab;
            try {
                ab = new AbilityClass(null, { atkSpdMult: 1, aoeMult: 1, damageMult: 1 });
            } catch (e) {
                console.log(e);
                ab = new Ability(null, null, key, 'New Ability!');
            }
            pool.push({
                id: key,
                isAbility: true,
                label: key.replace(/_/g, ' ').toUpperCase(),
                desc: ab.description || 'New Ability!',
                icon: iconMap[key] || 'star',
                abilityKey: key,
                effect: { stat: 'dummy', value: 0, mode: 'add' }, // Prevent crash in applyUpgrade
            });
        }

        // Remove recently picked (avoid repeats)
        pool = pool.filter(u => !this.pickedIds.has(u.id));
        if (pool.length < 3) { this.pickedIds.clear(); pool = [...UPGRADE_POOL]; }

        console.log(pool)
        // Shuffle and pick 3
        Phaser.Utils.Array.Shuffle(pool);
        const picked = pool.slice(0, 3);
        for (const p of picked) this.pickedIds.add(p.id);
        return picked;
    }
}

// ============================================================
//  GameOverScene
// ============================================================
class GameOverScene extends Phaser.Scene {
    constructor() { super('GameOver'); }

    init(data) { this.runData = data; }

    create() {
        const W = CONFIG.WIDTH, H = CONFIG.HEIGHT;
        const d = this.runData || {};

        // Background
        this.add.rectangle(W / 2, H / 2, W, H, 0x1a1010);
        for (let x = 0; x < W; x += 64)
            for (let y = 0; y < H; y += 64)
                this.add.image(x + 32, y + 32, 'background').setAlpha(0.2).setDisplaySize(64, 64);

        // Top gold banner
        this.add.rectangle(W / 2, 120, W, 240, 0xffd700);
        this.add.rectangle(W / 2, 126, W, 240, 0x2c3e50, 0.2);

        // Icons tinted black per default icon color policy
        this.add.image(W / 2 - 80, 52, 'skull').setDisplaySize(40, 40).setTint(0x000000);
        this.add.text(W / 2, 52, 'ROTTEN', {
            fontFamily: "'Fredoka One', sans-serif",
            fontSize: '36px', fill: '#2c3e50',
        }).setOrigin(0.5);
        this.add.image(W / 2 + 80, 52, 'skull').setDisplaySize(40, 40).setTint(0x000000);

        this.add.text(W / 2, 94, 'The wasteland claims another banana.', {
            fontFamily: "'Fredoka One', sans-serif",
            fontSize: '13px', fill: '#5d4037'
        }).setOrigin(0.5);

        // Stats panel
        const panelY = H / 2 - 20;
        this.add.rectangle(W / 2, panelY, W - 30, 280, 0xfffdf0)
            .setStrokeStyle(3, 0xe0c000);

        const stats = [
            ['Class', d.className || '?'],
            ['Level', 'LV ' + (d.level || 1)],
            ['Kills', (d.kills || 0) + ' enemies'],
            ['Survived', d.survivedTime || '0:00'],
        ];

        stats.forEach(([label, value], i) => {
            const rowY = panelY - 90 + i * 60;
            this.add.text(60, rowY, label, {
                fontFamily: "'Fredoka One', sans-serif", fontSize: '16px', fill: '#888'
            }).setOrigin(0, 0.5);
            this.add.text(W - 60, rowY, value, {
                fontFamily: "'Fredoka One', sans-serif", fontSize: '18px', fill: '#2c3e50'
            }).setOrigin(1, 0.5);
            if (i < stats.length - 1) {
                this.add.rectangle(W / 2, rowY + 28, W - 60, 1, 0xe0c000, 0.4);
            }
        });

        // Abilities used
        if (d.abilities?.length) {
            const ablY = panelY + 110;
            this.add.text(W / 2, ablY, 'Abilities used:', {
                fontFamily: "'Fredoka One', sans-serif", fontSize: '12px', fill: '#888'
            }).setOrigin(0.5);
            const ablStr = d.abilities.map(k => k.replace(/_/g, ' ')).join(' · ');
            this.add.text(W / 2, ablY + 20, ablStr, {
                fontFamily: "'Fredoka One', sans-serif", fontSize: '11px', fill: '#555',
                wordWrap: { width: W - 60 }, align: 'center'
            }).setOrigin(0.5);
        }

        // Icons tinted black per default icon color policy
        const playBtn = this._makeBtn(W / 2, H - 120, '   PLAY AGAIN', 0xffd700, 0x2c3e50);
        this.add.image(W / 2 - 68, H - 120, 'play').setDisplaySize(20, 20).setTint(0x000000);
        playBtn.on('pointerdown', () => this.scene.start('ClassSelect'));

        const menuBtn = this._makeBtn(W / 2, H - 60, '   MAIN MENU', 0x2c3e50, 0xffd700);
        this.add.image(W / 2 - 64, H - 60, 'home').setDisplaySize(20, 20).setTint(0x000000);
        menuBtn.on('pointerdown', () => this.scene.start('MainMenu'));

        this.cameras.main.fadeIn(500);
    }

    _makeBtn(x, y, label, bgColor, textColor) {
        const bg = this.add.nineslice(x, y, 'round_rect', 0, CONFIG.WIDTH - 50, 48, 16, 16, 16, 16)
            .setTint(bgColor).setInteractive({ useHandCursor: true });
        const stroke = this.add.nineslice(x, y, 'round_rect_outline', 0, CONFIG.WIDTH - 50, 48, 16, 16, 16, 16)
            .setTint(0xffd700);

        const txt = this.add.text(x, y, label, {
            fontFamily: "'Fredoka One', sans-serif", fontSize: '18px', fill: '#' + textColor.toString(16).padStart(6, '0')
        }).setOrigin(0.5);
        bg.on('pointerover', () => this.tweens.add({ targets: [bg, stroke, txt], scaleX: 1.04, scaleY: 1.04, duration: 80 }));
        bg.on('pointerout', () => this.tweens.add({ targets: [bg, stroke, txt], scaleX: 1, scaleY: 1, duration: 80 }));
        return bg;
    }
}