// Make the enemies more diversese because right now they just rush to the enemy. Make enmies face the way they are going. Make the hver over classes increase the source icon by just a little, and reduce it back if the mouse no longer hovers there. Make only first two classes unlocked. Then make the rest hae a padlock ("C:\Users\hmmm\banana_survivors\assets\icons\delapouite\plain-padlock.png") as source, and the condition to unlock them written necxt to them, Implement these conditions (Play 10 times, get 400 kills in one run,  get 4000 total kills, reach level 11)
// ============================================================
//  BaseObject — foundational class for all in-game entities
// ============================================================
class BaseObject {
    constructor(scene, x, y, def = {}) {
        this.scene = scene;
        this.x = x;
        this.y = y;
        this.def = def;

        // Stats
        this.maxHp = def.hp || 10;
        this.hp = this.maxHp;
        this.speed = def.speed || 60;
        this.damage = def.damage || 5;
        this.faction = def.faction ?? CONFIG.FACTIONS.NEUTRAL;
        this.dead = false;
        this.width = def.width || 32;
        this.height = def.height || 32;

        // Build sprite (or colored rectangle placeholder)
        this._buildSprite();
        this._buildHpBar();
    }

    _buildSprite() {
        const s = this.scene;
        const key = this.def.source || this.def.icon || this.def.anim || this.def.key;
        const col = this.def.color || null

        // Try texture; fall back to coloured rect
        if (key && s.textures.exists(key)) {
            const scaleMult = this.def.scale || 1;
            this.sprite = s.add.image(this.x, this.y, key)
                .setDisplaySize(this.width * scaleMult, this.height * scaleMult)
                .setDepth(10);
            this.baseScaleX = this.sprite.scaleX;
            this.baseScaleY = this.sprite.scaleY;
        } else {
            // Primitive rectangle fallback if image texture is missing
            this._useRect = true;
            this.sprite = s.add.rectangle(this.x, this.y, this.width, this.height, this.def.color || 0xff00ff)
                .setDepth(10);
            this.baseScaleX = this.sprite.scaleX;
            this.baseScaleY = this.sprite.scaleY;
            // Draw simple face on top
            this.face = s.add.graphics().setDepth(11);
            this._drawFace();
        }

        if (this.sprite.setTint && col) {
            this.sprite.setTint(col)
        }
    }

    _drawFace() {
        if (!this.face) return;
        this.face.clear();
        this.face.fillStyle(0x000000, 0.85);
        const ex = this.width * 0.15;
        const ey = this.height * 0.1;
        this.face.fillCircle(this.x - ex, this.y - ey, 2.5);
        this.face.fillCircle(this.x + ex, this.y - ey, 2.5);
    }

    _buildHpBar() {
        if (this.faction === CONFIG.FACTIONS.PLAYER) return; // player has own UI
        this.hpBarBg = this.scene.add.rectangle(this.x, this.y - this.height / 2 - 6, this.width, 4, 0x333333).setDepth(12);
        this.hpBarFg = this.scene.add.rectangle(this.x, this.y - this.height / 2 - 6, this.width, 4, 0x44ee44).setDepth(13).setOrigin(0, 0.5);
        this._updateHpBar();
    }

    _updateHpBar() {
        if (!this.hpBarBg) return;
        const ratio = Math.max(0, this.hp / this.maxHp);
        this.hpBarBg.setPosition(this.x, this.y - this.height / 2 - 6);
        this.hpBarFg.setPosition(this.x - this.width / 2, this.y - this.height / 2 - 6);
        this.hpBarFg.setDisplaySize(this.width * ratio, 4);
        const col = ratio > 0.5 ? 0x44ee44 : ratio > 0.25 ? 0xeeaa00 : 0xee2222;
        this.hpBarFg.setFillStyle(col);
    }

    setPosition(x, y) {
        this.x = x; this.y = y;
        this.sprite.setPosition(x, y);
        this._drawFace();
        this._updateHpBar();
    }

    takeDamage(amount, sourceX, sourceY) {
        if (this.dead) return;
        this.hp -= amount;
        this._updateHpBar();
        // Play a random hit sfx variant for variety
        const hitKeys = ['sfx_hit', 'sfx_hit2', 'sfx_hit3'];
        const hk = hitKeys[Math.floor(Math.random() * hitKeys.length)];
        if (this.scene.sound.get(hk)) this.scene.sound.play(hk, { volume: 0.3, rate: 0.9 + Math.random() * 0.2 });
        // Flash white
        this.scene.tweens.add({ targets: this.sprite, alpha: 0.2, duration: CONFIG.FLASH_DURATION_MS, yoyo: true });
        // Knockback
        if (sourceX !== undefined) {
            const ang = Phaser.Math.Angle.Between(sourceX, sourceY, this.x, this.y);
            const kb = 60;
            this.x += Math.cos(ang) * kb;
            this.y += Math.sin(ang) * kb;
        }
        if (this.hp <= 0) this._die();
        return this.hp <= 0;
    }

    _die() {
        this.dead = true;
        // sfx_death_enemy: standard creature death sound (registered as CONFIG.SFX.death_enemy)
        if (this.scene.sound.get('sfx_death_enemy')) this.scene.sound.play('sfx_death_enemy', { volume: 0.4, rate: 0.8 + Math.random() * 0.4 });
        // Juice: burst particles
        GameUtils.burst(this.scene, this.x, this.y, this.def.color || 0xff00ff);
        this.destroy();
    }

    destroy() {
        this.dead = true;
        this.sprite?.destroy();
        this.face?.destroy();
        this.hpBarBg?.destroy();
        this.hpBarFg?.destroy();
    }

    _applyWalkAnimation(delta) {
        if (!this.sprite || !this.sprite.active) return;
        const isMoving = this.vx !== 0 || this.vy !== 0;

        // Face direction
        if (isMoving) {
            // If the entity is an enemy, rotate to face movement direction
            if (this.faction !== CONFIG.FACTIONS.PLAYER) {
                if (this.rotateToDirection) {
                    const moveAng = Math.atan2(this.vy, this.vx);
                    // We add 90 degrees (PI/2) because sprites are vertically oriented (top-down)
                    this.sprite.rotation = moveAng + Math.PI / 2;
                }
                else {
                    // Allow other enemies to use horizontal flipping
                    if (this.vx > 0) {
                        this.sprite.scaleX = Math.abs(this.baseScaleX || this.sprite.scaleX);
                    } else if (this.vx < 0) {
                        this.sprite.scaleX = -Math.abs(this.baseScaleX || this.sprite.scaleX);
                    }
                }
            } else {
                // Player still uses horizontal flipping
                if (this.vx > 0) {
                    this.sprite.scaleX = Math.abs(this.baseScaleX || this.sprite.scaleX);
                } else if (this.vx < 0) {
                    this.sprite.scaleX = -Math.abs(this.baseScaleX || this.sprite.scaleX);
                }
            }
        }

        if (isMoving) {
            this.walkTimer = (this.walkTimer || 0) + delta;
            const t = this.walkTimer;
            const anim = this.def.animType || 'rock';

            // Parameterized animation to easily tweak the feel:
            const amp = this.def.animAmp || 4;     // Amplitude (how much they move/bounce)
            const spd = this.def.animSpeed || 150; // Speed (higher is slower)

            if (anim === 'rock') {
                // Add the rocking angle to the base rotation
                const baseRot = (this.faction !== CONFIG.FACTIONS.PLAYER) ? this.sprite.rotation : 0;
                this.sprite.rotation = baseRot + Phaser.Math.DegToRad(Math.sin(t / spd) * amp * 3);
            } else if (anim === 'bounce') {
                this.sprite.y = this.y - Math.abs(Math.sin(t / spd)) * amp;
            } else if (anim === 'wiggle') {
                const sx = Math.abs(this.baseScaleX || this.sprite.scaleX);
                const sy = Math.abs(this.baseScaleY || this.sprite.scaleY);
                const wAmp = amp * 0.01;
                this.sprite.setScale(Math.sign(this.sprite.scaleX) * (sx + Math.sin(t / spd) * wAmp), sy - Math.sin(t / spd) * wAmp);
            }
        } else {
            // Only reset angle if it's not the player (enemies keep their last orientation)
            if (this.faction === CONFIG.FACTIONS.PLAYER) {
                this.sprite.angle = 0;
            }
            this.sprite.y = this.y;
            this.walkTimer = 0;
            if (this.baseScaleX && this.def.animType === 'wiggle') {
                this.sprite.setScale(Math.sign(this.sprite.scaleX) * Math.abs(this.baseScaleX), Math.abs(this.baseScaleY));
            }
        }
    }

    // Subclasses override
    update(delta, entities) { }
}

// ============================================================
//  GameUtils — shared helpers
// ============================================================
const GameUtils = {
    burst(scene, x, y, color = 0xffcc00, count = 12) {
        for (let i = 0; i < count; i++) {
            const ang = (i / count) * Math.PI * 2;
            const dist = Phaser.Math.Between(18, 50);
            const p = scene.add.circle(x, y, Phaser.Math.Between(3, 7), color, 1).setDepth(20);
            scene.tweens.add({
                targets: p, x: x + Math.cos(ang) * dist, y: y + Math.sin(ang) * dist,
                alpha: 0, scaleX: 0.2, scaleY: 0.2,
                duration: Phaser.Math.Between(200, 450),
                ease: 'Cubic.Out',
                onComplete: () => p.destroy()
            });
        }
    },

    screenShake(scene, cfg = CONFIG.SCREENSHAKE_HIT) {
        scene.cameras.main.shake(cfg.duration, cfg.intensity / 1000);
    },

    hitStop(scene) {
        scene.physics?.world?.pause?.();
        scene.time.delayedCall(CONFIG.HITSTOP_MS, () => scene.physics?.world?.resume?.());
    },

    floatText(scene, x, y, text, color = '#ffdd00', size = 18) {
        const t = scene.add.text(x, y, text, {
            fontFamily: "'Fredoka One', sans-serif",
            fontSize: size + 'px',
            fill: color,
            stroke: '#000',
            strokeThickness: 4
        }).setDepth(50).setOrigin(0.5);
        scene.tweens.add({
            targets: t, y: y - 55, alpha: 0,
            duration: 900, ease: 'Cubic.Out',
            onComplete: () => t.destroy()
        });
    },

    floatIcon(scene, x, y, iconKey, size = 24) {
        // Default tint black so icons are readable on light backgrounds
        const img = scene.add.image(x, y, iconKey).setDisplaySize(size, size).setDepth(50).setTint(0x000000);
        scene.tweens.add({
            targets: img, y: y - 55, alpha: 0,
            duration: 900, ease: 'Cubic.Out',
            onComplete: () => img.destroy()
        });
    },

    clamp(v, mn, mx) { return Math.max(mn, Math.min(mx, v)); },

    spawnAvailableEnemyKeys(difficultyLevel) {
        return Object.keys(ENEMY_DEFS).filter(k => {
            const d = ENEMY_DEFS[k];
            return !d.isBoss && !d.isElite && d.intensity <= difficultyLevel;
        });
    },

    eliteKeys(difficultyLevel) {
        return Object.keys(ENEMY_DEFS).filter(k => {
            const d = ENEMY_DEFS[k];
            return d.isElite && d.intensity <= difficultyLevel;
        });
    },

    bossKeys(difficultyLevel) {
        return Object.keys(ENEMY_DEFS).filter(k => {
            const d = ENEMY_DEFS[k];
            return d.isBoss && d.intensity <= difficultyLevel;
        });
    }
};