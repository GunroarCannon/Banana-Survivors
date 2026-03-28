// ============================================================
//  UIScene & UIManager — all HUD elements
// ============================================================
class UIScene extends Phaser.Scene {
    constructor() { super('UI'); }

    create() {
        const game = this.scene.get('Game');
        game.ui = new UIManager(this);
        this.game = game;

        if (game.player) {
            game.ui.updateHp(game.player.hp, game.player.maxHp);
            game.ui.updateLevel(game.level);
            game.ui.updateAbilities(game.player.abilities);
            game.ui.updateXp(game.xp, game.xpNeeded);
            game.ui.updateKills(game.totalKills);
        }
    }
}

class UIManager {
    constructor(scene) {
        this.scene = scene;
        this.upgradePanel = null;
        this._build();
    }

    _build() {
        const s = this.scene;
        const W = CONFIG.WIDTH, H = CONFIG.HEIGHT;

        // ── Top bar background ──────────────────────────────────
        this.topBar = s.add.nineslice(W / 2, 44, 'round_rect', 0, W, 88, 16, 16, 16, 16).setTint(0xffd700)
            .setScrollFactor(0).setDepth(100).setAlpha(0.95);
        // Rounded look via shadow
        this.topBarShadow = s.add.nineslice(W / 2, 50, 'round_rect', 0, W, 88, 16, 16, 16, 16).setTint(0x000000)
            .setScrollFactor(0).setDepth(99).setAlpha(0.12);

        // ── HP bar ──────────────────────────────────────────────
        // Icon tinted black so it reads clearly on the light paper background
        this.hpLabel = s.add.image(24, 24, 'heart').setDisplaySize(24, 24).setScrollFactor(0).setDepth(102).setTint(0x000000);

        this.hpBg = s.add.nineslice(W / 2, 30, 'round_rect', 0, W - 100, 18, 8, 8, 8, 8).setTint(0x333333)
            .setScrollFactor(0).setDepth(101).setAlpha(0.4);
        this.hpFg = s.add.nineslice(W / 2 - (W - 100) / 2, 30, 'round_rect', 0, W - 100, 18, 8, 8, 8, 8).setTint(0xe74c3c)
            .setScrollFactor(0).setDepth(102).setOrigin(0, 0.5);

        // ── XP bar ──────────────────────────────────────────────
        this.xpBg = s.add.nineslice(W / 2, 52, 'round_rect', 0, W - 100, 10, 4, 4, 4, 4).setTint(0x333333)
            .setScrollFactor(0).setDepth(101).setAlpha(0.35);
        this.xpFg = s.add.nineslice(W / 2 - (W - 100) / 2, 52, 'round_rect', 0, W - 100, 10, 5, 5, 5, 5).setTint(0xf39c12)
            .setScrollFactor(0).setDepth(102).setOrigin(0, 0.5);

        // ── Level pill ──────────────────────────────────────────
        this.lvlBg = s.add.nineslice(W - 44, 36, 'round_rect', 0, 62, 36, 12, 12, 12, 12).setTint(0x2c3e50)
            .setScrollFactor(0).setDepth(101);
        this.lvlText = s.add.text(W - 44, 36, 'LV 1', {
            fontFamily: "'Fredoka One', sans-serif", fontSize: '16px', fill: '#f1c40f'
        }).setScrollFactor(0).setDepth(102).setOrigin(0.5);

        // ── Timer ───────────────────────────────────────────────
        this.timerText = s.add.text(W / 2, 68, '00:00', {
            fontFamily: "'Fredoka One', sans-serif", fontSize: '17px', fill: '#2c3e50',
            stroke: '#ffd700', strokeThickness: 1
        }).setScrollFactor(0).setDepth(102).setOrigin(0.5);

        // ── Kill counter ─────────────────────────────────────────
        // Icon tinted black so it reads clearly on the light paper background
        this.killIcon = s.add.image(20, 74, 'skull').setDisplaySize(18, 18).setScrollFactor(0).setDepth(102).setTint(0x000000);
        this.killText = s.add.text(34, 66, '0', {
            fontFamily: "'Fredoka One', sans-serif", fontSize: '14px', fill: '#2c3e50'
        }).setScrollFactor(0).setDepth(102);

        // ── Abilities bar (bottom) ───────────────────────────────
        this.abilityBar = s.add.nineslice(W / 2, H - 140, 'round_rect', 0, W - 20, 60, 16, 16, 16, 16).setTint(0xffd700)
            .setScrollFactor(0).setDepth(100).setAlpha(0.88);
        this.abilityIcons = [];

        // ── Joystick ────────────────────────────────────────────
        this._buildJoystick(s);
    }

    _buildJoystick(s) {
        this.joyActive = false;
        this.joyOrigin = { x: 0, y: 0 };
        this.joyInput = { x: 0, y: 0 };

        // Global touch events anywhere on the screen
        s.input.on('pointerdown', (p) => this._joyDown(p));
        s.input.on('pointermove', (p) => this._joyMove(p));
        s.input.on('pointerup', (p) => this._joyUp(p));
    }

    _joyDown(p) {
        this.joyActive = true;
        this.joyOrigin = { x: p.x, y: p.y };
        this._joyMove(p);
    }
    
    _joyMove(p) {
        if (!this.joyActive) return;
        const dx = p.x - this.joyOrigin.x;
        const dy = p.y - this.joyOrigin.y;
        const d = Math.sqrt(dx * dx + dy * dy);
        const R = CONFIG.UI_JOYSTICK_RADIUS || 50;
        
        let nx = 0, ny = 0;
        if (d > 0) {
            nx = dx; ny = dy;
            if (d > R) {
                nx = (dx / d) * R;
                ny = (dy / d) * R;
            }
        }
        this.joyInput.x = nx / R;
        this.joyInput.y = ny / R;
    }
    _joyUp(p) {
        this.joyActive = false;
        this.joyInput.x = 0; this.joyInput.y = 0;
    }

    updateHp(hp, maxHp) {
        const ratio = Math.max(0, hp / maxHp);
        this.hpFg.setDisplaySize((CONFIG.WIDTH - 100) * ratio, 18);
        const col = ratio > 0.5 ? 0x2ecc71 : ratio > 0.25 ? 0xf39c12 : 0xe74c3c;
        //this.hpFg.setFillStyle(col);
    }

    updateXp(xp, needed) {
        const ratio = Math.min(1, xp / needed);
        this.xpFg.setDisplaySize((CONFIG.WIDTH - 100) * ratio, 10);
    }

    updateLevel(lv) {
        this.lvlText.setText('LV ' + lv);
    }

    updateTimer(sec) {
        const m = String(Math.floor(sec / 60)).padStart(2, '0');
        const s = String(Math.floor(sec % 60)).padStart(2, '0');
        this.timerText.setText(m + ':' + s);
    }

    updateKills(k) {
        this.killText.setText(k);
    }

    updateAbilities(abilities) {
        for (const icon of this.abilityIcons) icon.destroy();
        this.abilityIcons = [];
        const count = abilities.length;
        const W = CONFIG.WIDTH, H = CONFIG.HEIGHT;
        const startX = (W - count * 54) / 2 + 27;
        for (let i = 0; i < count; i++) {
            const abl = abilities[i];
            const bg = this.scene.add.nineslice(startX + i * 54, H - 140, 'round_rect', 0, 46, 46, 12, 12, 12, 12).setTint(0xfff8dc)
                .setScrollFactor(0).setDepth(102);
            const str = this.scene.add.nineslice(startX + i * 54, H - 140, 'round_rect_outline', 0, 46, 46, 12, 12, 12, 12).setTint(0xf39c12)
                .setScrollFactor(0).setDepth(103);
            const lbl = this.scene.add.text(startX + i * 54, H - 140, abl.key.slice(0, 2).toUpperCase(), {
                fontFamily: "'Fredoka One', sans-serif", fontSize: '13px', fill: '#2c3e50'
            }).setScrollFactor(0).setDepth(104).setOrigin(0.5);
            this.abilityIcons.push(bg, str, lbl);
        }
    }

    // ── Upgrade screen ──────────────────────────────────────
    showUpgrades(options, onPick) {
        const s = this.scene;
        const W = CONFIG.WIDTH, H = CONFIG.HEIGHT;

        // Darken overlay
        this.upgradeOverlay = s.add.rectangle(W / 2, H / 2, W, H, 0x000000, 0.45)
            .setScrollFactor(0).setDepth(200);

        // Panel
        this.upgradePanel = s.add.nineslice(W / 2, H / 2, 'round_rect_outline', 0, W - 30, 440, 16, 16, 16, 16).setTint(0x1a1a1a)
            .setScrollFactor(0).setDepth(201);

        const p = s.add.nineslice(W / 2, H / 2, 'round_rect', 0, W - 30, 440, 16, 16, 16, 16).setTint(0xfdfae6)
            .setScrollFactor(0).setDepth(200.5);

        const titleIconLeft = s.add.image(W / 2 - 100, H / 2 - 190, 'banana').setDisplaySize(28, 28).setScrollFactor(0).setDepth(202);
        const title = s.add.text(W / 2, H / 2 - 190, 'LEVEL UP!', {
            fontFamily: "'Fredoka One', sans-serif", fontSize: '26px', fill: '#2c3e50',
            stroke: '#ffd700', strokeThickness: 2
        }).setScrollFactor(0).setDepth(202).setOrigin(0.5);
        const titleIconRight = s.add.image(W / 2 + 100, H / 2 - 190, 'banana').setDisplaySize(28, 28).setScrollFactor(0).setDepth(202);

        const subtitle = s.add.text(W / 2, H / 2 - 160, 'Choose an upgrade', {
            fontFamily: "'Fredoka One', sans-serif", fontSize: '15px', fill: '#555'
        }).setScrollFactor(0).setDepth(202).setOrigin(0.5);

        this._upgradeElements = [p, this.upgradeOverlay, this.upgradePanel, title, subtitle, titleIconLeft, titleIconRight];

        // 3 card options
        for (let i = 0; i < options.length; i++) {
            const upg = options[i];
            const cy = H / 2 - 90 + i * 120;

            // Card bg
            const card = s.add.nineslice(W / 2, cy, 'round_rect', 0, W - 60, 100, 16, 16, 16, 16).setTint(0xfffdf0)
                .setScrollFactor(0).setDepth(202)
                .setInteractive({ useHandCursor: true });
            const cardStroke = s.add.nineslice(W / 2, cy, 'round_rect_outline', 0, W - 60, 100, 16, 16, 16, 16).setTint(0xe0c000)
                .setScrollFactor(0).setDepth(202);

            // Hover effect
            card.on('pointerover', () => {
                card.setTint(0xfdfae6);
                cardStroke.setTint(0x1a1a1a);
                s.tweens.add({ targets: [card, cardStroke], scaleX: 1.03, scaleY: 1.03, duration: 80 });
            });
            card.on('pointerout', () => {
                card.setTint(0xfdfae6);
                cardStroke.setTint(0xa2c4c9);
                s.tweens.add({ targets: [card, cardStroke], scaleX: 1, scaleY: 1, duration: 80 });
            });
            card.on('pointerdown', () => {
                // SFX: crisp click on card select, then powerup fanfare
                const gs = this.scene.scene.get('Game');
                if (gs?.sound?.get('sfx_click')) gs.sound.play('sfx_click', { volume: 0.7 });
                if (gs?.sound?.get('sfx_powerup')) gs.sound.play('sfx_powerup', { volume: 0.5, delay: 0.08 });
                this._closeUpgrades();
                onPick(upg);
            });

            if (upg.icon) {
                // All upgrade card icons default to black; individual tints can be added in UPGRADE_POOL if needed
                const icon = s.add.image(W / 2 - 60, cy - 22, upg.icon).setDisplaySize(24, 24).setScrollFactor(0).setDepth(203).setOrigin(1, 0.5).setTint(0x000000);
                const nameText = s.add.text(W / 2 - 50, cy - 22, upg.label, {
                    fontFamily: "'Fredoka One', sans-serif", fontSize: '18px', fill: '#2c3e50'
                }).setScrollFactor(0).setDepth(203).setOrigin(0, 0.5);
                this._upgradeElements.push(icon, nameText);
            } else {
                const nameText = s.add.text(W / 2, cy - 22, upg.label, {
                    fontFamily: "'Fredoka One', sans-serif", fontSize: '18px', fill: '#2c3e50'
                }).setScrollFactor(0).setDepth(203).setOrigin(0.5);
                this._upgradeElements.push(nameText);
            }

            const descText = s.add.text(W / 2, cy + 12, upg.desc, {
                fontFamily: "'Fredoka One', sans-serif", fontSize: '13px', fill: '#666'
            }).setScrollFactor(0).setDepth(203).setOrigin(0.5);

            this._upgradeElements.push(card, cardStroke, descText);
        }
    }

    _closeUpgrades() {
        for (const el of this._upgradeElements || []) {
            console.log(el, "destroy")
            el?.destroy();
        }
        this._upgradeElements = [];


        this.upgradePanel = null;
        this.upgradeOverlay = null;
        this.scene.scene.get('Game').events.emit('upgrade_closed');

        console.log("closed")
    }

    destroy() {
        this._closeUpgrades();
    }
}