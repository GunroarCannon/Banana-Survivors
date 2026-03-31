// ============================================================
//  Enemy
// current song still does not stop when new song starts. Outline pulps in black. Add more enemies atleast 3 more. wo 10x size of player that do special abilities like charge. Replace enemieies withicons and make sure they are not tinted white. The thing that is a ghost/phantom is not moving at all
// ============================================================
class Enemy extends BaseObject {
    constructor(scene, x, y, defKey, statMult = 1) {
        const rawDef = ENEMY_DEFS[defKey];
        const def = {
            ...rawDef,
            hp: Math.round(rawDef.hp * statMult),

            //randomize the speed for more varied enemies
            speed: rawDef.speed * Phaser.Math.Between(0.5, 1.0),

            damage: Math.round(rawDef.damage * statMult),
            faction: CONFIG.FACTIONS.ENEMY,
        };
        super(scene, x, y, def);
        this.rotateToDirection = rawDef.rotateToDirection || false;
        this.xp = rawDef.xp || 2;
        this.defKey = defKey;
        this.aiState = 'seek';
        this.stunTimer = 0;
        this.attackCd = 0;
        this._ghostTarget = null;
        this._ghostTimer = 0;
        this._inDecayAura = false;
        this.isElite = rawDef.isElite || false;
        this.isBoss = rawDef.isBoss || false;

        // Timer for special-attack AI (lightning, freeze, magma)
        this._specialCd = 0;

        if (this.isElite || this.isBoss) {
            this.sprite.setAlpha(1);
            // Glow effect
            scene.time.addEvent({
                delay: 500, loop: true, callback: () => {
                    if (this.dead) return;
                    scene.tweens.add({ targets: this.sprite, alpha: 0.7, duration: 250, yoyo: true });
                }
            });
        }
    }

    makeSpecial() {
        if (this.isElite || this.isBoss) return; // don't double-scale bosses
        this.isSpecial = true;

        const types = [
            { id: 'swift', color: 0xffa500, scale: [1.25, 1.5], speedMult: 2.0, hpMult: 1.0, dmgMult: 1.0, label: 'Swift' },
            { id: 'strong', color: 0xff0000, scale: [1.5, 2.0], speedMult: 1.0, hpMult: 1.5, dmgMult: 2.5, label: 'Strong' },
            { id: 'tank', color: 0x8b4513, scale: [2.2, 3.5], speedMult: 0.5, hpMult: 6.0, dmgMult: 1.2, label: 'Tank' },
            { id: 'radioactive', color: 0x00ff00, scale: [1.3, 1.6], speedMult: 1.6, hpMult: 1.6, dmgMult: 1.6, label: 'Radioactive' },
            { id: 'ethereal', color: 0xaa00ff, scale: [0.8, 1.1], speedMult: 1.8, hpMult: 0.8, dmgMult: 1.3, label: 'Ethereal' },
            { id: 'frosted', color: 0x0088ff, scale: [1.4, 1.8], speedMult: 0.8, hpMult: 2.5, dmgMult: 1.4, label: 'Frosted' }
        ];

        const cfg = Phaser.Math.RND.pick(types);
        this.specialType = cfg.id;

        const scale = this.sprite.scale * Phaser.Math.FloatBetween(cfg.scale[0], cfg.scale[1]);
        this.sprite.setScale(scale);
        this.baseScaleX = this.sprite.scaleX;
        this.baseScaleY = this.sprite.scaleY;

        try {
            this.sprite.setTintFill(cfg.color);
        } catch (e) {
            console.log("setTintFill failed", e);
        }
        if (this.sprite.postFX) {
            this.sprite.postFX.addGlow(cfg.color, 4, 0, false, 0.1, 10);
        }

        // Buff stats
        this.hp *= cfg.hpMult;
        this.maxHp = this.hp;
        this.speed *= cfg.speedMult;
        this.damage *= cfg.dmgMult;
        this.xp *= 3; // All specials give 3x XP

        console.log(`Made ${cfg.label} special with scale ${scale.toFixed(2)}`);

        // Visual emphasis: scale pulse
        this.scene.tweens.add({
            targets: this.sprite,
            scaleX: this.sprite.scaleX * 1.1,
            scaleY: this.sprite.scaleY * 1.1,
            duration: 500,
            yoyo: true,
            repeat: -1
        });
    }

    update(delta, entities) {
        if (this.dead) return;

        // Stun
        if (this.stunTimer > 0) {
            this.vx = 0; this.vy = 0;
            this.stunTimer -= delta;
            if (this.sprite.setTint)
                this.sprite.setTint(0x8888ff);
            this._applyWalkAnimation(delta);
            return;
        }

        if (this.sprite.clearTint)
            this.sprite.clearTint();

        // Ghost-target distraction
        if (this._ghostTimer > 0) {
            this._ghostTimer -= delta;
            if (this._ghostTarget && this._ghostTarget.active) {
                this._moveToward(this._ghostTarget.x, this._ghostTarget.y, delta);
                return;
            }
        }

        // Faction: find nearest valid target (could be another enemy!)
        let target = this._findTarget(entities);
        if (!target) return;

        const dist = Phaser.Math.Distance.Between(this.x, this.y, target.x, target.y);
        const atkRange = (target.width || 32) / 2 + this.def.width / 2 + 4;

        // ── Special AI dispatch ──────────────────────────────
        const ai = this.def.ai;
        if (ai === 'lightning_chain') {
            this._moveToward(target.x, target.y, delta);
            this._tickLightningChain(delta, entities);
        } else if (ai === 'freeze_burst') {
            this._moveToward(target.x, target.y, delta);
            this._tickFreezeBurst(delta, entities);
        } else if (ai === 'magma_slam') {
            this._moveToward(target.x, target.y, delta);
            this._tickMagmaSlam(delta, entities);
        } else if (ai === 'charge') {
            this._tickCharge(delta, target);
        } else {
            // Diverse movement patterns
            const moveType = this.def.moveType || 'seek';
            if (dist <= atkRange && moveType === 'seek') {
                this.vx = 0; this.vy = 0;
                this._attack(target, delta);
            } else {
                if (moveType === 'zigzag') {
                    this._moveZigZag(target.x, target.y, delta);
                } else if (moveType === 'circle') {
                    this._moveCircle(target.x, target.y, delta);
                } else {
                    this._moveToward(target.x, target.y, delta);
                }
            }
        }

        this._applyWalkAnimation(delta);
    }

    // ── Lightning Chain ─────────────────────────────────────────
    // Telegrahs with a yellow flash, then chains lightning to up to 4 targets.
    _tickLightningChain(delta, entities) {
        this._specialCd -= delta;
        if (this._specialCd > 0) return;
        this._specialCd = 3000; // fires every 3 seconds

        const targets = [...entities]
            .filter(e => !e.dead && e !== this && e.faction !== this.faction)
            .sort((a, b) =>
                Phaser.Math.Distance.Between(this.x, this.y, a.x, a.y) -
                Phaser.Math.Distance.Between(this.x, this.y, b.x, b.y)
            )
            .slice(0, 4);

        if (!targets.length) return;

        // Telegraph: blue flash on the titan
        const flash = this.scene.add.circle(this.x, this.y, this.def.width * 0.7, 0x44ccff, 0.3).setDepth(20);
        this.scene.tweens.add({ targets: flash, alpha: 0, scaleX: 1.5, scaleY: 1.5, duration: 700, onComplete: () => flash.destroy() });

        // Delayed strike
        this.scene.time.delayedCall(700, () => {
            if (this.dead) return;
            // SFX: lightning crack on every strike
            if (this.scene.sound.get('sfx_lightning')) this.scene.sound.play('sfx_lightning', { volume: 0.6 });
            if (this.scene.sound.get('sfx_zap')) this.scene.sound.play('sfx_zap', { volume: 0.4, delay: 0.05 });
            let prev = { x: this.x, y: this.y };
            for (const t of targets) {
                if (t.dead) continue;
                // Draw jagged lightning bolt
                const g = this.scene.add.graphics().setDepth(22);
                g.lineStyle(3, 0x44ccff, 1);
                g.beginPath();
                g.moveTo(prev.x, prev.y);
                const steps = 6;
                const dx = (t.x - prev.x) / steps, dy = (t.y - prev.y) / steps;
                for (let i = 1; i <= steps; i++) {
                    g.lineTo(prev.x + dx * i + Phaser.Math.Between(-14, 14),
                        prev.y + dy * i + Phaser.Math.Between(-14, 14));
                }
                g.lineTo(t.x, t.y);
                g.strokePath();
                this.scene.time.delayedCall(250, () => g.destroy());

                const dmg = this.def.damage * 0.7;
                t.takeDamage(dmg, prev.x, prev.y);
                GameUtils.floatText(this.scene, t.x, t.y - 20, '⚡' + Math.round(dmg), '#44ccff');
                prev = { x: t.x, y: t.y };
            }
        });
    }

    // ── Freeze Burst ────────────────────────────────────────────
    // Telegraphs a wide icy shockwave, then slows + damages all in range.
    _tickFreezeBurst(delta, entities) {
        this._specialCd -= delta;
        if (this._specialCd > 0) return;
        this._specialCd = 5000;

        const radius = 220;
        // Telegraph: ice circle expands outward
        const warn = this.scene.add.circle(this.x, this.y, 10, 0xaaeeff, 0.4).setDepth(20);
        this.scene.tweens.add({
            targets: warn, scaleX: radius / 10, scaleY: radius / 10, alpha: 0.15,
            duration: 1000, ease: 'Cubic.Out',
            onComplete: () => warn.destroy()
        });

        this.scene.time.delayedCall(1000, () => {
            if (this.dead) return;
            // SFX: ice shatter on freeze burst
            if (this.scene.sound.get('sfx_freeze')) this.scene.sound.play('sfx_freeze', { volume: 0.55 });
            // Shockwave visual
            const ring = this.scene.add.circle(this.x, this.y, radius, 0xaaeeff, 0.35).setDepth(21);
            this.scene.tweens.add({ targets: ring, alpha: 0, scaleX: 1.3, scaleY: 1.3, duration: 400, onComplete: () => ring.destroy() });

            for (const e of entities) {
                if (e.dead || e === this || e.faction === this.faction) continue;
                const d = Phaser.Math.Distance.Between(this.x, this.y, e.x, e.y);
                if (d < radius) {
                    // Freeze (stun for 2 seconds)
                    if (e.stunTimer !== undefined) e.stunTimer = Math.max(e.stunTimer, 2000);
                    const dmg = this.def.damage * 0.5;
                    e.takeDamage(dmg, this.x, this.y);
                    GameUtils.floatText(this.scene, e.x, e.y - 20, '❄' + Math.round(dmg), '#aaeeff');
                }
            }
        });
    }

    // ── Magma Slam ──────────────────────────────────────────────
    // Leaps, telegraphs a red circle, then crashes down leaving a burning pool.
    _tickMagmaSlam(delta, entities) {
        this._specialCd -= delta;
        if (this._specialCd > 0) return;
        this._specialCd = 4000;

        const target = this._findTarget(entities);
        if (!target) return;

        const tx = target.x + Phaser.Math.Between(-30, 30);
        const ty = target.y + Phaser.Math.Between(-30, 30);
        const radius = 100;

        // Telegraph: red danger circle at landing zone
        const warn = this.scene.add.circle(tx, ty, radius, 0xff4400, 0.25).setDepth(19);
        const warnEdge = this.scene.add.arc(tx, ty, radius, 0, 360, false, 0xff4400, 0.9).setDepth(20).setStrokeStyle(3, 0xff4400);
        GameUtils.floatText(this.scene, tx, ty - radius - 10, '☄ SLAM', '#ff6600', 16);

        this.scene.time.delayedCall(1100, () => {
            warn.destroy(); warnEdge.destroy();
            if (this.dead) return;

            // Impact burst
            const burst = this.scene.add.circle(tx, ty, radius * 1.4, 0xff6600, 0.5).setDepth(22);
            this.scene.tweens.add({ targets: burst, alpha: 0, scaleX: 1.4, scaleY: 1.4, duration: 400, onComplete: () => burst.destroy() });
            GameUtils.screenShake(this.scene, { intensity: 10, duration: 200 });
            // SFX: explosion + slam on landing
            if (this.scene.sound.get('sfx_explosion')) this.scene.sound.play('sfx_explosion', { volume: 0.7 });
            if (this.scene.sound.get('sfx_slam')) this.scene.sound.play('sfx_slam', { volume: 0.6, delay: 0.06 });

            // Damage on impact
            for (const e of entities) {
                if (e.dead || e === this || e.faction === this.faction) continue;
                if (Phaser.Math.Distance.Between(tx, ty, e.x, e.y) < radius) {
                    const dmg = this.def.damage * 0.8;
                    e.takeDamage(dmg, tx, ty);
                    GameUtils.floatText(this.scene, e.x, e.y - 20, '🔥' + Math.round(dmg), '#ff6600');
                }
            }

            // Burning ground pool (DOT)
            const pool = this.scene.add.circle(tx, ty, radius * 0.7, 0xdd3300, 0.3).setDepth(16);
            let ticks = 0;
            const iv = this.scene.time.addEvent({
                delay: 600, repeat: 6, callback: () => {
                    for (const e of entities) {
                        if (e.dead || e.faction === this.faction) continue;
                        if (Phaser.Math.Distance.Between(tx, ty, e.x, e.y) < radius * 0.7) {
                            e.takeDamage(this.def.damage * 0.15, tx, ty);
                        }
                    }
                    ticks++;
                    if (ticks >= 7) pool.destroy();
                }
            });
        });
    }

    // ── Charge AI ──────────────────────────────────────────────
    // Seeks, telegraphs, then dashes at the target.
    _tickCharge(delta, target) {
        if (!target) return;
        if (!this._chargeState) this._chargeState = 'seek';
        this._specialCd -= delta;

        if (this._chargeState === 'seek') {
            this._moveToward(target.x, target.y, delta);
            const d = Phaser.Math.Distance.Between(this.x, this.y, target.x, target.y);
            // Trigger telegraph if close enough or if it's been a while
            if (d < 350 && this._specialCd <= 0) {
                this._chargeState = 'telegraph';
                this._specialCd = 1000; // 1 second telegraph
                this.vx = 0; this.vy = 0;
                // Telegraph visual: flash red
                this.scene.tweens.add({ targets: this.sprite, tint: 0xff0000, duration: 200, yoyo: true, repeat: 2 });
            }
        } else if (this._chargeState === 'telegraph') {
            if (this._specialCd <= 0) {
                this._chargeState = 'dash';
                this._specialCd = 800; // dash duration
                this._chargeAngle = Math.atan2(target.y - this.y, target.x - this.x);
                // SFX: charge swoosh
                if (this.scene.sound.get('sfx_charge')) this.scene.sound.play('sfx_charge', { volume: 0.7 });
            }
        } else if (this._chargeState === 'dash') {
            const dashSpd = this.def.speed * 6;
            const spd = dashSpd * (delta / 1000);
            const nx = this.x + Math.cos(this._chargeAngle) * spd;
            const ny = this.y + Math.sin(this._chargeAngle) * spd;
            this.setPosition(
                GameUtils.clamp(nx, 0, this.scene.worldW),
                GameUtils.clamp(ny, 0, this.scene.worldH)
            );

            // Hit check
            const distToPlayer = Phaser.Math.Distance.Between(this.x, this.y, target.x, target.y);
            if (distToPlayer < (this.def.width / 2 + target.width / 2)) {
                if (target.takeDamage) {
                    target.takeDamage(this.def.damage * 1.5, this.x, this.y);
                    // SFX: impact
                    if (this.scene.sound.get('sfx_charge_impact')) this.scene.sound.play('sfx_charge_impact', { volume: 0.8 });
                    this._chargeState = 'cooldown';
                    this._specialCd = 1500;
                }
            }

            if (this._specialCd <= 0) {
                this._chargeState = 'cooldown';
                this._specialCd = 1500;
            }
        } else if (this._chargeState === 'cooldown') {
            if (this._specialCd <= 0) {
                this._chargeState = 'seek';
                this._specialCd = 4000; // internal CD between charges
            }
        }
    }

    _findTarget(entities) {
        // Faction system: attack nearest entity of different faction
        let best = null, bestD = Infinity;
        for (const e of entities) {
            if (e === this || e.dead) continue;
            if (e.faction === this.faction) continue;
            const d = Phaser.Math.Distance.Between(this.x, this.y, e.x, e.y);
            if (d < bestD) { bestD = d; best = e; }
        }
        return best;
    }

    _moveToward(tx, ty, delta) {
        const ang = Math.atan2(ty - this.y, tx - this.x);
        this.vx = Math.cos(ang);
        this.vy = Math.sin(ang);
        const spd = (this.speed || this.def.speed) * (delta / 1000);
        const nx = this.x + this.vx * spd;
        const ny = this.y + this.vy * spd;
        this.setPosition(
            GameUtils.clamp(nx, 0, this.scene.worldW),
            GameUtils.clamp(ny, 0, this.scene.worldH)
        );
    }

    _moveZigZag(tx, ty, delta) {
        const ang = Math.atan2(ty - this.y, tx - this.x);
        const spd = (this.speed || this.def.speed) * (delta / 1000);

        // Zig-zag offset
        this._zigzagTimer = (this._zigzagTimer || 0) + delta;
        const freq = 0.008;
        const amp = 0.8 + .4;
        const offsetAng = Math.sin(this._zigzagTimer * freq) * amp;

        const finalAng = ang + offsetAng;
        this.vx = Math.cos(finalAng);
        this.vy = Math.sin(finalAng);

        const nx = this.x + this.vx * spd;
        const ny = this.y + this.vy * spd;
        this.setPosition(
            GameUtils.clamp(nx, 0, this.scene.worldW),
            GameUtils.clamp(ny, 0, this.scene.worldH)
        );
    }

    _moveCircle(tx, ty, delta) {
        const dist = Phaser.Math.Distance.Between(this.x, this.y, tx, ty);
        const ang = Math.atan2(this.y - ty, this.x - tx);
        const spd = (this.speed || this.def.speed) * (delta / 1000);

        // If too far, seek. If close, circle.
        if (dist > 250) {
            this._moveToward(tx, ty, delta);
        } else {
            const orbitSpd = 0.002 * delta;
            const newAng = ang + orbitSpd;
            // Slightly pull towards target while orbiting
            const pull = 0.1;
            const targetR = 150;
            const currentR = dist;
            const rDelta = (targetR - currentR) * pull;

            const nx = tx + Math.cos(newAng) * (currentR + rDelta);
            const ny = ty + Math.sin(newAng) * (currentR + rDelta);

            this.vx = (nx - this.x) / spd;
            this.vy = (ny - this.y) / spd;

            this.setPosition(
                GameUtils.clamp(nx, 0, this.scene.worldW),
                GameUtils.clamp(ny, 0, this.scene.worldH)
            );
        }
    }

    _attack(target, delta) {
        this.attackCd -= delta;
        if (this.attackCd > 0) return;
        this.attackCd = 1200;
        if (target.takeDamage) {
            target.takeDamage(this.def.damage || 5);
        }
    }

    _die() {
        this.dead = true;
        GameUtils.burst(this.scene, this.x, this.y, this.def.color || 0xff4422, 14);
        this.scene.events.emit('enemy_killed', this);
        // Drop pulp
        const xpCount = Math.ceil(this.xp / 3);
        for (let i = 0; i < xpCount; i++) {
            const ox = Phaser.Math.Between(-18, 18), oy = Phaser.Math.Between(-18, 18);
            this.scene.spawnPulp(this.x + ox, this.y + oy, Math.ceil(this.xp / xpCount));
        }
        this.destroy();
    }
}

// ============================================================
//  Enemy-Enemy Collision Resolution
//  Called from GameScene.update() when CONFIG.ENEMIES_COLLIDE is true.
//  Simple circle-vs-circle separation: enemies push each other apart
//  so they don't stack on top of the player.
// ============================================================
function resolveEnemyCollisions(enemies) {
    for (let i = 0; i < enemies.length; i++) {
        const a = enemies[i];
        if (a.dead) continue;
        const ra = (a.def.width || 32) / 2;

        for (let j = i + 1; j < enemies.length; j++) {
            const b = enemies[j];
            if (b.dead) continue;
            const rb = (b.def.width || 32) / 2;

            const dx = b.x - a.x;
            const dy = b.y - a.y;
            const dist = Math.sqrt(dx * dx + dy * dy) || 0.01;
            const minDist = ra + rb;

            if (dist < minDist) {
                // Overlap amount
                const overlap = (minDist - dist) * 0.5;
                const nx = dx / dist;
                const ny = dy / dist;
                // Push apart proportionally to the overlap
                a.setPosition(a.x - nx * overlap, a.y - ny * overlap);
                b.setPosition(b.x + nx * overlap, b.y + ny * overlap);
            }
        }
    }
}

// ============================================================
//  WaveSpawner
// ============================================================
class WaveSpawner {
    constructor(scene) {
        this.scene = scene;
        this.timer = 0;
        this.eliteTimer = 0;
        this.diffTick = 0;
        this.diffTimer = 0;
        this.diffLevel = 0;      // intensity level
        this.statMult = 1;
        this.bossQueue = [...CONFIG.BOSS_MILESTONES_SEC];
        this.survivedSec = 0;
        this.spawnCount = CONFIG.SPAWN_BASE_COUNT;
    }

    update(delta) {
        this.survivedSec += delta / 1000;

        // Difficulty scaling
        this.diffTimer += delta;
        if (this.diffTimer >= CONFIG.SCALE_INTERVAL_SEC * 1000) {
            this.diffTimer = 0;
            this.diffLevel++;
            this.statMult *= (1 + CONFIG.ENEMY_STAT_MULT);
            this.spawnCount = Math.min(this.spawnCount + 1, 14);
            this.scene.events.emit('difficulty_up', this.diffLevel);
        }

        // Elite spawn
        this.eliteTimer += delta;
        if (this.eliteTimer >= CONFIG.ELITE_INTERVAL_SEC * 1000) {
            this.eliteTimer = 0;
            this._spawnElite();
        }

        // Boss milestones
        if (this.bossQueue.length && this.survivedSec >= this.bossQueue[0]) {
            this.bossQueue.shift();
            this._spawnBoss();
        }

        // Regular waves
        this.timer += delta;
        if (this.timer >= CONFIG.SPAWN_INTERVAL_MS) {
            this.timer = 0;
            this._spawnWave();
        }
    }

    _spawnWave() {
        const keys = GameUtils.spawnAvailableEnemyKeys(this.diffLevel);
        if (!keys.length) return;
        const count = this.spawnCount;
        // Pick spawn pattern
        const pattern = Phaser.Math.RND.pick(['circle', 'directional', 'burst']);
        for (let i = 0; i < count; i++) {
            const pos = this._spawnPos(pattern, i, count);
            const key = Phaser.Math.RND.pick(keys);
            const e = new Enemy(this.scene, pos.x, pos.y, key, this.statMult);

            // Special monster chance: 2% + 5% * diffLevel
            const specialChance = .01 + (0.05 * this.diffLevel);
            if (Math.random() < specialChance) {
                e.makeSpecial();
            }

            this.scene.enemies.push(e);
        }
    }

    _spawnElite() {
        const keys = GameUtils.eliteKeys(this.diffLevel);
        if (!keys.length) return;
        const pos = this._randomEdgePos();
        const key = Phaser.Math.RND.pick(keys);
        const e = new Enemy(this.scene, pos.x, pos.y, key, this.statMult * 1.5);

        // Elites also have a chance to be "Extra Special"
        const specialChance = 0.05 + (0.05 * this.diffLevel);
        if (Math.random() < specialChance) {
            e.makeSpecial();
        }

        this.scene.enemies.push(e);
        GameUtils.screenShake(this.scene, { intensity: 5, duration: 200 });
        GameUtils.floatText(this.scene, this.scene.player.x, this.scene.player.y - 60, '⚠ ELITE ⚠', '#ff4400', 20);
    }

    _spawnBoss() {
        const keys = GameUtils.bossKeys(this.diffLevel);
        if (!keys.length) return;
        const pos = this._randomEdgePos();
        const key = Phaser.Math.RND.pick(keys);
        const e = new Enemy(this.scene, pos.x, pos.y, key, this.statMult * 2);
        this.scene.enemies.push(e);
        GameUtils.screenShake(this.scene, CONFIG.SCREENSHAKE_BOSS);
        GameUtils.floatText(this.scene, this.scene.player.x, this.scene.player.y - 70, 'BOSS', '#ff0000', 26);
        GameUtils.floatIcon(this.scene, this.scene.player.x - 45, this.scene.player.y - 70, 'skull', 26);
        GameUtils.floatIcon(this.scene, this.scene.player.x + 45, this.scene.player.y - 70, 'skull', 26);
        this.scene.events.emit('boss_spawn');
    }

    _spawnPos(pattern, i, count) {
        const cam = this.scene.cameras.main;
        const pad = CONFIG.SPAWN_VIEWPORT_PAD;
        const cx = cam.scrollX + CONFIG.WIDTH / 2;
        const cy = cam.scrollY + CONFIG.HEIGHT / 2;
        const hw = CONFIG.WIDTH / 2 + pad;
        const hh = CONFIG.HEIGHT / 2 + pad;

        if (pattern === 'circle') {
            const ang = (i / count) * Math.PI * 2 + Math.random() * 0.4;
            const r = Math.max(hw, hh);
            return { x: cx + Math.cos(ang) * r, y: cy + Math.sin(ang) * r };
        } else if (pattern === 'directional') {
            const side = Phaser.Math.Between(0, 3);
            if (side === 0) return { x: Phaser.Math.Between(cx - hw, cx + hw), y: cy - hh };
            if (side === 1) return { x: Phaser.Math.Between(cx - hw, cx + hw), y: cy + hh };
            if (side === 2) return { x: cx - hw, y: Phaser.Math.Between(cy - hh, cy + hh) };
            return { x: cx + hw, y: Phaser.Math.Between(cy - hh, cy + hh) };
        } else {
            return this._randomEdgePos();
        }
    }

    _randomEdgePos() {
        const cam = this.scene.cameras.main;
        const pad = CONFIG.SPAWN_VIEWPORT_PAD;
        const sides = [
            { x: Phaser.Math.Between(cam.scrollX - pad, cam.scrollX + CONFIG.WIDTH + pad), y: cam.scrollY - pad },
            { x: Phaser.Math.Between(cam.scrollX - pad, cam.scrollX + CONFIG.WIDTH + pad), y: cam.scrollY + CONFIG.HEIGHT + pad },
            { x: cam.scrollX - pad, y: Phaser.Math.Between(cam.scrollY - pad, cam.scrollY + CONFIG.HEIGHT + pad) },
            { x: cam.scrollX + CONFIG.WIDTH + pad, y: Phaser.Math.Between(cam.scrollY - pad, cam.scrollY + CONFIG.HEIGHT + pad) },
        ];
        return Phaser.Math.RND.pick(sides);
    }
}

// ============================================================
//  Pulp (XP) gem
// ============================================================
class PulpGem {
    constructor(scene, x, y, value, refined = false) {
        this.scene = scene;
        this.x = x;
        this.y = y;
        this.value = value;
        this.refined = refined;
        this.dead = false;
        this.siphon = false;
        this.sprite = scene.add.circle(x, y, refined ? 9 : 6, refined ? 0xffffff : 0xffee33, 1).setDepth(6);
        this.sprite.setStrokeStyle(2, 0x000000);
        if (refined) {
            scene.tweens.add({ targets: this.sprite, scaleX: 1.4, scaleY: 1.4, duration: 400, yoyo: true, repeat: -1 });
        }
    }

    update(delta, px, py, magnetRadius) {
        if (this.dead) return;
        const d = Phaser.Math.Distance.Between(this.x, this.y, px, py);
        if (this.siphon || d < magnetRadius) {
            // Attract to player
            const ang = Math.atan2(py - this.y, px - this.x);
            const spd = CONFIG.PULP_MAGNET_SPEED * (delta / 1000);
            this.x += Math.cos(ang) * spd;
            this.y += Math.sin(ang) * spd;
            this.sprite.setPosition(this.x, this.y);
            if (Phaser.Math.Distance.Between(this.x, this.y, px, py) < 12) {
                this._collect();
            }
        }
    }

    _collect() {
        this.dead = true;
        this.scene.events.emit('pulp_collected', this.value);
        this.sprite.destroy();
    }

    destroy() { this.sprite?.destroy(); this.dead = true; }
}