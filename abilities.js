// ============================================================
//  Ability base
// ============================================================
class Ability {
    constructor(scene, player, key, description) {
        this.scene = scene;
        this.player = player;
        this.key = key;
        this.timer = 0;
        this.description = description;
        this.gfx = [];   // graphics/sprites to clean up
    }
    update(delta, entities) { }
    destroy() { for (const g of this.gfx) g?.destroy?.(); }

    // helpers
    nearestEnemy(entities) {
        let best = null, bestD = Infinity;
        for (const e of entities) {
            if (e.dead || e.faction === CONFIG.FACTIONS.PLAYER) continue;
            const d = Phaser.Math.Distance.Between(this.player.x, this.player.y, e.x, e.y);
            if (d < bestD) { bestD = d; best = e; }
        }
        return best;
    }

    fireProjectile(angle, speed, dmg, color, size, piercing = false, lifetime = 900) {
        const s = this.scene;

        if (s.sound.get('sfx_shoot')) s.sound.play('sfx_shoot', { volume: 0.15, rate: 0.8 + Math.random() * 0.4 });
        const p = s.add.circle(this.player.x, this.player.y, size, color, 1).setDepth(18);
        const glow = s.add.circle(this.player.x, this.player.y, size * 1.8, color, 0.3).setDepth(17);
        const vx = Math.cos(angle) * speed;
        const vy = Math.sin(angle) * speed;
        let hit = new Set();
        let age = 0;
        const id = s.time.addEvent({
            delay: 16, repeat: Math.floor(lifetime / 16), callback: () => {
                if (p.destroyed) return;
                const dt = 16 / 1000;
                p.x += vx * dt; p.y += vy * dt;
                glow.x = p.x; glow.y = p.y;
                age += 16;
                // bounds
                if (p.x < -100 || p.x > s.worldW + 100 || p.y < -100 || p.y > s.worldH + 100 || age >= lifetime) {
                    p.destroy(); glow.destroy(); return;
                }
                // collision
                for (const e of s.enemies) {
                    if (e.dead || hit.has(e)) continue;
                    if (Phaser.Math.Distance.Between(p.x, p.y, e.x, e.y) < size + e.width / 2) {
                        const crit = Math.random() < this.player.critChance;
                        const dmgF = dmg * this.player.damageMult * (crit ? 4 : 1);
                        e.takeDamage(dmgF, p.x, p.y);
                        GameUtils.floatText(s, e.x, e.y - 20, Math.round(dmgF) + (crit ? '!!' : ''), crit ? '#ff2222' : '#fff');
                        if (!piercing) { p.destroy(); glow.destroy(); return; }
                        hit.add(e);
                    }
                }
            }
        });
        return { circle: p, glow };
    }

    aoeAttack(x, y, radius, dmg, color, duration = 350) {
        const s = this.scene;
        if (s.sound.get('sfx_shoot')) s.sound.play('sfx_shoot', { volume: 0.25, rate: 0.6 + Math.random() * 0.2 });
        const ring = s.add.circle(x, y, radius, color, 0.25).setDepth(18);
        const edge = s.add.arc(x, y, radius, 0, 360, false, color, 0.9).setDepth(19).setStrokeStyle(3, color);
        s.tweens.add({
            targets: [ring, edge], alpha: 0, scaleX: 1.3, scaleY: 1.3, duration, ease: 'Cubic.Out',
            onComplete: () => { ring.destroy(); edge.destroy(); }
        });
        for (const e of s.enemies) {
            if (e.dead) continue;
            const d = Phaser.Math.Distance.Between(x, y, e.x, e.y);
            if (d < radius * this.player.aoeMult) {
                const crit = Math.random() < this.player.critChance;
                const dmgF = dmg * this.player.damageMult * (crit ? 4 : 1);
                e.takeDamage(dmgF, x, y);
                GameUtils.floatText(s, e.x, e.y - 22, Math.round(dmgF) + (crit ? '!!' : ''), crit ? '#ff2222' : '#ffee44');
            }
        }
        GameUtils.screenShake(s, { intensity: 3, duration: 70 });
    }
}

// ============================================================
//  ALCHEMIST abilities
// ============================================================
class ZappingStem extends Ability {
    constructor(s, p) { super(s, p, 'zapping_stem', 'Lightning attack that chains between enemies'); this.cooldown = 1200 / (p.atkSpdMult || 1); this.chains = 1; }
    update(delta) {
        this.timer += delta;
        const cd = this.cooldown / (this.player.atkSpdMult);
        if (this.timer < cd) return;
        this.timer = 0;
        const target = this.nearestEnemy(this.scene.enemies);
        if (!target) return;
        this._chain(this.player.x, this.player.y, target, new Set(), this.chains + 1);
    }
    _chain(fx, fy, target, visited, remaining) {
        if (!target || visited.has(target) || remaining <= 0) return;
        visited.add(target);
        // Lightning bolt visual
        const g = this.scene.add.graphics().setDepth(22);
        g.lineStyle(2, 0x66ffff, 0.9);
        g.beginPath(); g.moveTo(fx, fy);
        // jagged path
        const steps = 5;
        const dx = (target.x - fx) / steps, dy = (target.y - fy) / steps;
        for (let i = 1; i <= steps; i++) {
            const jx = fx + dx * i + Phaser.Math.Between(-10, 10);
            const jy = fy + dy * i + Phaser.Math.Between(-10, 10);
            g.lineTo(jx, jy);
        }
        g.lineTo(target.x, target.y);
        g.strokePath();
        this.scene.time.delayedCall(180, () => g.destroy());
        const dmg = 14 * this.player.damageMult;
        target.takeDamage(dmg, fx, fy);
        GameUtils.floatText(this.scene, target.x, target.y - 20, Math.round(dmg), '#66ffff');
        // Chain to next
        let nextBest = null, bestD = Infinity;
        for (const e of this.scene.enemies) {
            if (visited.has(e) || e.dead) continue;
            const d = Phaser.Math.Distance.Between(target.x, target.y, e.x, e.y);
            if (d < bestD) { bestD = d; nextBest = e; }
        }
        this._chain(target.x, target.y, nextBest, visited, remaining - 1);
    }
}

class StaticPeel extends Ability {
    constructor(s, p) { super(s, p, 'static_peel', 'Stuns nearby enemies'); this.cooldown = 4000; }
    update(delta) {
        this.timer += delta;
        if (this.timer < this.cooldown / this.player.atkSpdMult) return;
        this.timer = 0;
        this.aoeAttack(this.player.x, this.player.y, 100 * this.player.aoeMult, 8, 0x66ffff);
        // Stun nearby
        for (const e of this.scene.enemies) {
            if (e.dead) continue;
            if (Phaser.Math.Distance.Between(this.player.x, this.player.y, e.x, e.y) < 100 * this.player.aoeMult) {
                e.stunTimer = (e.stunTimer || 0) + 1200;
            }
        }
    }
}

class AcidRain extends Ability {
    constructor(s, p) { super(s, p, 'acid_rain', 'Summons acid rain at a random location'); this.cooldown = 5000; }
    update(delta) {
        this.timer += delta;
        if (this.timer < this.cooldown / this.player.atkSpdMult) return;
        this.timer = 0;
        const tx = Phaser.Math.Between(this.scene.cameras.main.scrollX + 60, this.scene.cameras.main.scrollX + CONFIG.WIDTH - 60);
        const ty = Phaser.Math.Between(this.scene.cameras.main.scrollY + 60, this.scene.cameras.main.scrollY + CONFIG.HEIGHT - 60);
        // Warning circle
        const warn = this.scene.add.circle(tx, ty, 60, 0xffff00, 0.2).setDepth(16);
        const warnE = this.scene.add.arc(tx, ty, 60, 0, 360, false, 0xffff00, 0.8).setDepth(17).setStrokeStyle(2, 0xffff00);
        this.scene.time.delayedCall(900, () => {
            warn.destroy(); warnE.destroy();
            // Drop acid
            this.aoeAttack(tx, ty, 70 * this.player.aoeMult, 22, 0x99ff33, 500);
            // Acid pool (DOT zone)
            const pool = this.scene.add.circle(tx, ty, 55, 0x44aa00, 0.3).setDepth(16);
            let ticks = 0;
            const iv = this.scene.time.addEvent({
                delay: 500, repeat: 5, callback: () => {
                    for (const e of this.scene.enemies) {
                        if (e.dead) continue;
                        if (Phaser.Math.Distance.Between(tx, ty, e.x, e.y) < 55) {
                            e.takeDamage(8 * this.player.damageMult, tx, ty);
                        }
                    }
                    ticks++;
                    if (ticks >= 6) pool.destroy();
                }
            });
        });
    }
}

class SolarFlare extends Ability {
    constructor(s, p) {
        super(s, p, 'solar_flare', 'Shoots a beam of light that damages enemies');
        this.angle = Math.random() * Math.PI * 2;
        this.rotateSpeed = 0.7 + Math.random() * 0.5;
        this.beamLen = 220;
        if (s) {
            this.beamGfx = s.add.graphics().setDepth(20);
        }
        this.hit = new Set();
        this.tickRate = 200;
        this.tickTimer = 0;
        this.gfx.push(this.beamGfx);
    }
    update(delta) {
        this.angle += this.rotateSpeed * (delta / 1000);
        this.tickTimer += delta;
        this.beamGfx.clear();
        const px = this.player.x, py = this.player.y;
        const ex = px + Math.cos(this.angle) * this.beamLen;
        const ey = py + Math.sin(this.angle) * this.beamLen;
        this.beamGfx.lineStyle(6, 0xffdd44, 0.8);
        this.beamGfx.beginPath();
        this.beamGfx.moveTo(px, py);
        this.beamGfx.lineTo(ex, ey);
        this.beamGfx.strokePath();
        // Glow
        this.beamGfx.lineStyle(16, 0xffaa00, 0.18);
        this.beamGfx.beginPath();
        this.beamGfx.moveTo(px, py);
        this.beamGfx.lineTo(ex, ey);
        this.beamGfx.strokePath();

        if (this.tickTimer < this.tickRate) return;
        this.tickTimer = 0;
        // Hit check along beam
        for (const e of this.scene.enemies) {
            if (e.dead) continue;
            const ABx = ex - px, ABy = ey - py, APx = e.x - px, APy = e.y - py;
            const t2 = Math.max(0, Math.min(1, (APx * ABx + APy * ABy) / (ABx * ABx + ABy * ABy + 0.001)));
            const dist = Math.hypot(APx - t2 * ABx, APy - t2 * ABy);
            if (dist < e.width / 2 + 6 && Phaser.Math.Distance.Between(px, py, e.x, e.y) < this.beamLen) {
                e.takeDamage(12 * this.player.damageMult, px, py);
            }
        }
    }
}

class MolecularRebuild extends Ability {
    constructor(s, p) { super(s, p, 'molecular_rebuild', 'Increases chance of spawning refined pulp'); this.killCount = 0; }
    // passive — triggered by enemy death event in GameScene
    onEnemyKilled(e) {
        this.killCount++;
        if (this.killCount % 20 === 0 && Math.random() < 0.5) {
            // Spawn refined pulp (2x value)
            this.scene.spawnPulp(e.x, e.y, (e.def.xp || 2) * 2, true);
        }
    }
}

// ============================================================
//  BRUISER abilities
// ============================================================
class HeavySlap extends Ability {
    constructor(s, p) {
        super(s, p, 'heavy_slap', 'Slaps enemies in a cone in front of the player');
        this.cooldown = 900;
        this.angleOffset = (Math.random() - 0.5) * 0.4; // +/- offset
    }
    update(delta) {
        this.timer += delta;
        if (this.timer < this.cooldown / this.player.atkSpdMult) return;
        this.timer = 0;
        const ang = Math.atan2(this.player.vy || 1, this.player.vx || 0) + this.angleOffset;
        // Fan arc
        for (const e of this.scene.enemies) {
            if (e.dead) continue;
            const eAng = Math.atan2(e.y - this.player.y, e.x - this.player.x);
            const diff = Phaser.Math.Angle.Wrap(eAng - ang);
            const dist = Phaser.Math.Distance.Between(this.player.x, this.player.y, e.x, e.y);
            if (Math.abs(diff) < Math.PI * 0.45 && dist < 90 * this.player.aoeMult) {
                const dmg = 28 * this.player.damageMult;
                e.takeDamage(dmg, this.player.x, this.player.y);
                GameUtils.floatText(this.scene, e.x, e.y - 22, Math.round(dmg), '#ff9944');
            }
        }
        // Visual arc
        const g = this.scene.add.graphics().setDepth(20);
        g.fillStyle(0xff9944, 0.4);
        g.slice(this.player.x, this.player.y, 90 * this.player.aoeMult, ang - Math.PI * 0.45, ang + Math.PI * 0.45, false);
        g.fillPath();
        this.scene.time.delayedCall(200, () => g.destroy());
        GameUtils.screenShake(this.scene, { intensity: 5, duration: 90 });
    }
}

class SpinKick extends Ability {
    constructor(s, p) { super(s, p, 'spin_kick', 'Performs a spin kick that damages enemies around the player'); this.cooldown = 2200; }
    update(delta) {
        this.timer += delta;
        if (this.timer < this.cooldown / this.player.atkSpdMult) return;
        this.timer = 0;
        this.aoeAttack(this.player.x, this.player.y, 70 * this.player.aoeMult, 20, 0xff6622);
        // Spin visual
        const g = this.scene.add.graphics().setDepth(22);
        let rot = 0;
        const iv = this.scene.time.addEvent({
            delay: 16, repeat: 20, callback: () => {
                g.clear();
                rot += 0.4;
                g.lineStyle(5, 0xff6622, 0.8);
                g.arc(this.player.x, this.player.y, 50, rot, rot + Math.PI * 1.5, false);
                g.strokePath();
            }
        });
        this.scene.time.delayedCall(360, () => g.destroy());
    }
}

class Shockwave extends Ability {
    constructor(s, p) {
        super(s, p, 'shockwave', 'Sends out shockwaves in four directions');
        this.cooldown = 6000;
        this.angleOffset = Math.random() * Math.PI * 0.5;
    }
    update(delta) {
        this.timer += delta;
        if (this.timer < this.cooldown / this.player.atkSpdMult) return;
        this.timer = 0;
        const dirs = [0, Math.PI / 2, Math.PI, Math.PI * 1.5];
        for (const base of dirs) {
            this.fireProjectile(base + this.angleOffset, 380, 30, 0xff4422, 12, true, 1200);
        }
        GameUtils.screenShake(this.scene, { intensity: 6, duration: 120 });
    }
}

class Thorns extends Ability {
    constructor(s, p) {
        super(s, p, 'thorns', 'Deals damage to enemies that touch the player');
        this.angle = Math.random() * Math.PI * 2;
        this.rotDir = Math.random() > 0.5 ? 1 : -1;
        this.rotSpeed = 0.03 + Math.random() * 0.04;
        this.orbitRadius = 28 + Math.random() * 12;
        if (s) {
            this.g = s.add.graphics().setDepth(15);
            this.gfx.push(this.g);
        }
    }
    update(delta) {
        if (!this.g) return;
        this.angle += this.rotDir * this.rotSpeed * (delta / 16); 
        this.g.clear();
        const px = this.player.x, py = this.player.y;
        
        for (let i = 0; i < 3; i++) {
            const a = this.angle + (i * Math.PI * 2 / 3);
            const dist = this.orbitRadius;
            const sx = px + Math.cos(a) * dist;
            const sy = py + Math.sin(a) * dist;
            
            // Draw a small triangle/spike
            this.g.fillStyle(0x44ff66, 0.6);
            this.g.beginPath();
            this.g.moveTo(sx + Math.cos(a) * 8, sy + Math.sin(a) * 8);
            this.g.lineTo(sx + Math.cos(a + 2) * 5, sy + Math.sin(a + 2) * 5);
            this.g.lineTo(sx + Math.cos(a - 2) * 5, sy + Math.sin(a - 2) * 5);
            this.g.fillPath();
        }
    }
    onEnemyTouch(e) {
        const dmg = 15 * this.player.damageMult;
        e.takeDamage(dmg, this.player.x, this.player.y);
        GameUtils.floatText(this.scene, e.x, e.y - 20, Math.round(dmg), '#ff4466');
        
        // Visual 'stab' effect at hit point
        const g = this.scene.add.graphics().setDepth(25);
        g.lineStyle(2, 0x44ff66, 1.0);
        g.strokeCircle(e.x, e.y, 10);
        this.scene.tweens.add({
            targets: g,
            alpha: 0,
            scale: 2.0,
            duration: 150,
            onComplete: () => g.destroy()
        });
    }
}

class BerserkMush extends Ability {
    constructor(s, p) { super(s, p, 'berserk_mush', 'Increases attack speed when health is low'); }
    update(delta) {
        if (this.player.hp / this.player.maxHp < 0.2) {
            this.player.atkSpdMult = Math.max(this.player.atkSpdMult, 1.5);
        }
    }
}

// ============================================================
//  OVERSEER abilities
// ============================================================
class SeedSpitter extends Ability {
    constructor(s, p) {
        super(s, p, 'seed_spitter', 'Summons mobile turrets that chase and shoot enemies');
        this.cooldown = 10000;
        this.turrets = [];
    }

    update(delta) {
        this.timer += delta;
        const cd = this.cooldown / (this.player.atkSpdMult || 1);

        // Spawn a new turret on cooldown
        if (this.timer >= cd) {
            this.timer = 0;
            const t = {
                x: this.player.x + Phaser.Math.Between(-30, 30),
                y: this.player.y + Phaser.Math.Between(-30, 30),
                life: 6000, fireTimer: 0, dead: false,
                // Turret moves at 60 px/s toward the nearest enemy (summoner AI)
                speed: 60,
                sprite: this.scene.add.rectangle(0, 0, 20, 20, 0x44ff88).setDepth(12),
            };
            t.sprite.setPosition(t.x, t.y);
            this.turrets.push(t);
            this.scene.time.delayedCall(6000, () => { t.dead = true; t.sprite?.destroy(); });
        }

        // Update each living turret: move toward nearest enemy, then fire
        for (const t of this.turrets.filter(x => !x.dead)) {
            // ── Summoner AI Movement ──────────────────────────────
            // The turret seeks the nearest enemy, moves toward it, and shoots
            // when within 140 px. This gives the Overseer's summons real presence
            // on the battlefield instead of sitting still.
            const target = this.nearestEnemy(this.scene.enemies);

            if (target) {
                const dist = Phaser.Math.Distance.Between(t.x, t.y, target.x, target.y);
                const SHOOT_RANGE = 140;

                if (dist > SHOOT_RANGE) {
                    // Move toward the enemy
                    const ang = Math.atan2(target.y - t.y, target.x - t.x);
                    t.x += Math.cos(ang) * t.speed * (delta / 1000);
                    t.y += Math.sin(ang) * t.speed * (delta / 1000);
                    t.sprite.setPosition(t.x, t.y);
                }

                // Fire when close enough
                t.fireTimer += delta;
                const fireCd = 800 / (this.player.atkSpdMult || 1);
                if (t.fireTimer >= fireCd) {
                    t.fireTimer = 0;
                    const ang = Math.atan2(target.y - t.y, target.x - t.x);
                    this.fireProjectile(ang, 280, 12, 0x44ff88, 5);
                }
            }
        }

        // Clean up expired turrets
        this.turrets = this.turrets.filter(x => !x.dead);
    }
}


class SporeCloud extends Ability {
    constructor(s, p) { super(s, p, 'spore_cloud', 'Releases a cloud of spores that damages enemies'); this.trailTimer = 0; }
    update(delta) {
        this.trailTimer += delta;
        if (this.trailTimer < 400) return;
        this.trailTimer = 0;
        const cloud = this.scene.add.circle(this.player.x, this.player.y, 25 * this.player.aoeMult, 0x66ff44, 0.35).setDepth(8);
        let age = 0;
        const iv = this.scene.time.addEvent({
            delay: 500, repeat: 6, callback: () => {
                for (const e of this.scene.enemies) {
                    if (e.dead) continue;
                    if (Phaser.Math.Distance.Between(cloud.x, cloud.y, e.x, e.y) < 25 * this.player.aoeMult) {
                        e.takeDamage(5 * this.player.damageMult);
                        e.speed = (e.def.speed || 60) * 0.6; // slow
                    }
                }
                age++;
                if (age >= 6) cloud.destroy();
            }
        });
    }
}

class VineGrasp extends Ability {
    constructor(s, p) { super(s, p, 'vine_grasp', 'Stuns enemies that touch the player'); this.cooldown = 7000; }
    update(delta) {
        this.timer += delta;
        if (this.timer < this.cooldown / this.player.atkSpdMult) return;
        this.timer = 0;
        let count = 0;
        const shuffled = [...this.scene.enemies].filter(e => !e.dead).sort(() => Math.random() - 0.5);
        for (const e of shuffled) {
            if (count >= 3) break;
            e.stunTimer = (e.stunTimer || 0) + 2000;
            const g = this.scene.add.rectangle(e.x, e.y, e.width + 8, e.height + 8).setStrokeStyle(3, 0x44aa00).setDepth(19);
            this.scene.time.delayedCall(2000, () => g.destroy());
            GameUtils.floatIcon(this.scene, e.x, e.y - 25, 'leaf', 22);
            count++;
        }
    }
}

class FruitBatSwarm extends Ability {
    constructor(s, p) {
        super(s, p, 'fruit_bat_swarm', 'Summons fruit bats to attack enemies');
        this.bats = [];
        this.batCount = 4;
        if (s)
            this._spawnBats();
        this.attackTimer = 0;
    }
    _spawnBats() {
        for (let i = 0; i < this.batCount; i++) {
            const b = {
                angle: (i / this.batCount) * Math.PI * 2,
                sprite: this.scene.add.image(0, 0, 'bat').setDepth(14).setDisplaySize(20, 20),
            };
            this.bats.push(b);
            this.gfx.push(b.sprite);
        }
    }
    update(delta) {
        for (const b of this.bats) {
            b.angle += 2.5 * (delta / 1000);
            b.sprite.setPosition(
                this.player.x + Math.cos(b.angle) * 55,
                this.player.y + Math.sin(b.angle) * 55
            );
        }
        this.attackTimer += delta;
        if (this.attackTimer < 600 / this.player.atkSpdMult) return;
        this.attackTimer = 0;
        for (const e of this.scene.enemies) {
            if (e.dead) continue;
            const d = Phaser.Math.Distance.Between(this.player.x, this.player.y, e.x, e.y);
            if (d < 120) {
                e.takeDamage(8 * this.player.damageMult, this.player.x, this.player.y);
                break;
            }
        }
    }
}

class RootShield extends Ability {
    constructor(s, p) {
        super(s, p, 'root_shield', 'Creates a shield of roots around the player');
        this.segments = 5; this.shieldAngle = 0;
        this.shieldGfx = [];
        if (p && s)
            for (let i = 0; i < this.segments; i++) {
                const seg = p.scene.add.rectangle(0, 0, 14, 22, 0x886633).setDepth(15);
                this.shieldGfx.push(seg);
                this.gfx.push(seg);
            }
        this.alive = true;
    }
    update(delta) {
        if (!this.alive) return;
        this.shieldAngle += 1.2 * (delta / 1000);
        for (let i = 0; i < this.shieldGfx.length; i++) {
            const ang = this.shieldAngle + (i / this.segments) * Math.PI * 2;
            this.shieldGfx[i].setPosition(
                this.player.x + Math.cos(ang) * 55,
                this.player.y + Math.sin(ang) * 55
            ).setRotation(ang);
        }
    }
    onHit() {
        if (!this.alive) return;
        this.alive = false;
        for (const s of this.shieldGfx) s.destroy();
        // Splinter burst
        const dirs = 8;
        for (let i = 0; i < dirs; i++) {
            this.fireProjectile((i / dirs) * Math.PI * 2, 300, 18, 0x886633, 8, false, 600);
        }
        // Regen shield after 8 seconds
        this.scene.time.delayedCall(8000, () => {
            this.alive = true;
            for (let i = 0; i < this.segments; i++) {
                const seg = this.scene.add.rectangle(0, 0, 14, 22, 0x886633).setDepth(15);
                this.shieldGfx[i] = seg;
            }
        });
    }
}

// ============================================================
//  GRAVE-RIPENER abilities
// ============================================================
class BoneShard extends Ability {
    constructor(s, p) { super(s, p, 'bone_shard', 'Shoots bone shards at enemies'); this.cooldown = 800; }
    update(delta) {
        this.timer += delta;
        if (this.timer < this.cooldown / this.player.atkSpdMult) return;
        this.timer = 0;
        // Target lowest HP enemy
        let target = null, lowestHp = Infinity;
        for (const e of this.scene.enemies) {
            if (!e.dead && e.hp < lowestHp) { lowestHp = e.hp; target = e; }
        }
        if (!target) return;
        const ang = Math.atan2(target.y - this.player.y, target.x - this.player.x);
        this.fireProjectile(ang, 380, 18, 0xdddddd, 8, true, 1400);
    }
}

class DecayAura extends Ability {
    constructor(s, p) {
        super(s, p, 'decay_aura', 'Creates an aura that damages enemies');
        this.radius = 110;

        if (!s) {
            return;
        }

        this.auraGfx = p.scene.add.circle(p.x, p.y, this.radius, 0xaa44ff, 0.12).setDepth(7);
        this.auraEdge = p.scene.add.arc(p.x, p.y, this.radius, 0, 360, false, 0xaa44ff, 0.5)
            .setDepth(8).setStrokeStyle(2, 0xaa44ff);
        this.gfx.push(this.auraGfx, this.auraEdge);
    }
    update(delta) {
        this.auraGfx.setPosition(this.player.x, this.player.y);
        this.auraEdge.setPosition(this.player.x, this.player.y);
        const r = this.radius * this.player.aoeMult;
        for (const e of this.scene.enemies) {
            if (e.dead) continue;
            const d = Phaser.Math.Distance.Between(this.player.x, this.player.y, e.x, e.y);
            if (d < r) {
                e.speed = (e.def.speed || 60) * 0.45;
                e._inDecayAura = true;
            } else {
                e.speed = e.def.speed || 60;
                e._inDecayAura = false;
            }
        }
    }
}

class RiseOfPeels extends Ability {
    constructor(s, p) { super(s, p, 'rise_of_peels', 'Summons banana peels to damage enemies'); this.peels = []; }
    onEnemyKilled(e) {
        if (Math.random() > 0.4) return;
        const peel = {
            x: e.x, y: e.y,
            sprite: this.scene.add.rectangle(e.x, e.y, 24, 10, 0xffee33, 0.9).setDepth(9).setRotation(Math.random() * Math.PI),
            triggered: false,
        };
        this.peels.push(peel);
        this.gfx.push(peel.sprite);
    }
    update(delta) {
        for (const peel of this.peels.filter(p => !p.triggered)) {
            for (const e of this.scene.enemies) {
                if (e.dead) continue;
                if (Phaser.Math.Distance.Between(peel.x, peel.y, e.x, e.y) < 20) {
                    peel.triggered = true;
                    peel.sprite.destroy();
                    const dmg = 80 * this.player.damageMult;
                    e.takeDamage(dmg, peel.x, peel.y);
                    e.stunTimer = (e.stunTimer || 0) + 1500;
                    GameUtils.burst(this.scene, peel.x, peel.y, 0xffff00, 16);
                    GameUtils.floatIcon(this.scene, peel.x - 12, peel.y - 30, 'banana', 24);
                    GameUtils.floatIcon(this.scene, peel.x + 12, peel.y - 30, 'explosion', 24);
                    break;
                }
            }
        }
        this.peels = this.peels.filter(p => !p.triggered);
    }
}

class SoulSiphon extends Ability {
    constructor(s, p) { super(s, p, 'soul_siphon', 'Pulls all pulp gems to the player'); this.cooldown = 15000; }
    update(delta) {
        this.timer += delta;
        if (this.timer < this.cooldown) return;
        this.timer = 0;
        // Pull all pulp gems to player
        for (const pulp of this.scene.pulpGems) {
            pulp.siphon = true;
        }
        // Visual pulse
        const ring = this.scene.add.circle(this.player.x, this.player.y, 30, 0xaa44ff, 0.5).setDepth(18);
        this.scene.tweens.add({
            targets: ring, scaleX: 8, scaleY: 8, alpha: 0, duration: 600,
            onComplete: () => ring.destroy()
        });
    }
}

class RotBlast extends Ability {
    constructor(s, p) { super(s, p, 'rot_blast', 'Explodes when an enemy dies near the player'); }
    onEnemyKilled(e) {
        if (!e._inDecayAura) return;
        if (Math.random() > 0.5) return;
        this.aoeAttack(e.x, e.y, 70 * this.player.aoeMult, e.maxHp * 0.2, 0xaa44ff, 400);
    }
}

// ============================================================
//  SLICER abilities
// ============================================================
class DashSlash extends Ability {
    constructor(s, p) { super(s, p, 'dash_slash', 'Dashes to the nearest enemy and attacks'); this.cooldown = 3000; }
    update(delta) {
        this.timer += delta;
        if (this.timer < this.cooldown / this.player.atkSpdMult) return;
        this.timer = 0;
        const target = this.nearestEnemy(this.scene.enemies);
        if (!target) return;
        // Flash to target
        const ox = this.player.x, oy = this.player.y;
        this.player.invincible = true;
        this.player.iframeTimer = 300;
        const ang = Math.atan2(target.y - oy, target.x - ox);
        const dmg = 25 * this.player.damageMult;
        target.takeDamage(dmg, ox, oy);
        GameUtils.floatText(this.scene, target.x, target.y - 22, Math.round(dmg), '#ffee33');
        // Slash line visual
        const g = this.scene.add.graphics().setDepth(22);
        g.lineStyle(4, 0xffee33, 1);
        g.lineBetween(ox, oy, target.x, target.y);
        this.scene.time.delayedCall(150, () => g.destroy());
    }
}

class ThrownBlade extends Ability {
    constructor(s, p) { super(s, p, 'thrown_blade', 'Throws a blade at the nearest enemy'); this.cooldown = 2500; }
    update(delta) {
        this.timer += delta;
        if (this.timer < this.cooldown / this.player.atkSpdMult) return;
        this.timer = 0;
        const target = this.nearestEnemy(this.scene.enemies);
        if (!target) return;
        const ang = Math.atan2(target.y - this.player.y, target.x - this.player.x);
        // Goes out and returns (simulated by 2 projectiles)
        this.fireProjectile(ang, 320, 20, 0xffee33, 7, true, 700);
        this.scene.time.delayedCall(700, () => {
            this.fireProjectile(ang + Math.PI, 320, 15, 0xffee33, 7, true, 700);
        });
    }
}

class Blur extends Ability {
    constructor(s, p) { super(s, p, 'blur', 'Creates a ghost that distracts enemies'); this.cooldown = 5000; this.ghost = null; }
    update(delta) {
        this.timer += delta;
        if (this.timer >= this.cooldown) {
            this.timer = 0;
            if (this.ghost) this.ghost.destroy();

            // Create a "phantom" ghost icon that moves
            this.ghost = this.scene.add.image(this.player.x, this.player.y, 'ghost')
                .setDepth(9).setDisplaySize(this.player.width, this.player.height).setAlpha(0.5).setTint(0xffee33);

            // Give it some movement direction
            const vx = (this.player.vx || 0) * 1.5;
            const vy = (this.player.vy || 1) * 1.5;
            this.ghost.vx = vx || (Math.random() - 0.5);
            this.ghost.vy = vy || (Math.random() - 0.5);

            // Enemies target ghost for 2 seconds
            for (const e of this.scene.enemies) {
                e._ghostTarget = this.ghost;
                e._ghostTimer = 2000;
            }

            this.scene.time.delayedCall(2000, () => {
                if (this.ghost) {
                    this.scene.tweens.add({
                        targets: this.ghost,
                        alpha: 0,
                        duration: 300,
                        onComplete: () => {
                            if (this.ghost) this.ghost.destroy();
                            this.ghost = null;
                        }
                    });
                }
            });
        }

        if (this.ghost && this.ghost.active) {
            const spd = 120 * (delta / 1000);
            this.ghost.x += this.ghost.vx * spd;
            this.ghost.y += this.ghost.vy * spd;
        }
    }
}

class BladeFan extends Ability {
    constructor(s, p) { super(s, p, 'blade_fan', 'Throws multiple blades in a fan pattern'); this.cooldown = 4000; }
    update(delta) {
        this.timer += delta;
        if (this.timer < this.cooldown / this.player.atkSpdMult) return;
        this.timer = 0;
        const count = 8;
        for (let i = 0; i < count; i++) {
            this.fireProjectile((i / count) * Math.PI * 2, 280, 14, 0xffee33, 6, false, 700);
        }
    }
}

class CriticalRip extends Ability {
    constructor(s, p) { super(s, p, 'critical_rip', 'Increases critical hit chance'); }
    // Passive — integrated into damage calc via player.critChance (+10%)
    update() { this.player.critChance = Math.max(this.player.critChance, 0.10); }
}

// ============================================================
//  IRON HUSK abilities
// ============================================================
class ShieldBash extends Ability {
    constructor(s, p) { super(s, p, 'shield_bash', 'Bashes the closest enemy'); this.cooldown = 1500; }
    update(delta) {
        this.timer += delta;
        if (this.timer < this.cooldown / this.player.atkSpdMult) return;
        this.timer = 0;
        // Closest enemy in front
        const target = this.nearestEnemy(this.scene.enemies);
        if (!target) return;
        const dmg = 35 * this.player.damageMult;
        target.takeDamage(dmg, this.player.x, this.player.y);
        GameUtils.floatText(this.scene, target.x, target.y - 22, Math.round(dmg), '#aaaaff');
        // Big knockback
        const ang = Math.atan2(target.y - this.player.y, target.x - this.player.x);
        target.x += Math.cos(ang) * 100;
        target.y += Math.sin(ang) * 100;
        GameUtils.screenShake(this.scene, { intensity: 5, duration: 80 });
    }
}

class GroundPound extends Ability {
    constructor(s, p) { super(s, p, 'ground_pound', 'Pounds the ground, stunning nearby enemies'); this.cooldown = 6000; }
    update(delta) {
        this.timer += delta;
        if (this.timer < this.cooldown / this.player.atkSpdMult) return;
        this.timer = 0;
        // Jump anim
        this.scene.tweens.add({
            targets: this.player.sprite, scaleY: 0.5, duration: 150, yoyo: true,
            onComplete: () => {
                this.aoeAttack(this.player.x, this.player.y, 120 * this.player.aoeMult, 40, 0xaaaaaa, 500);
                // Slow
                for (const e of this.scene.enemies) {
                    if (e.dead) continue;
                    if (Phaser.Math.Distance.Between(this.player.x, this.player.y, e.x, e.y) < 120 * this.player.aoeMult) {
                        e.stunTimer = (e.stunTimer || 0) + 2000;
                    }
                }
                GameUtils.screenShake(this.scene, { intensity: 8, duration: 150 });
            }
        });
    }
}

class UnstoppableCharge extends Ability {
    constructor(s, p) { super(s, p, 'unstoppable_charge', 'Charges in a direction, damaging enemies'); this.cooldown = 8000; }
    update(delta) {
        this.timer += delta;
        if (this.timer < this.cooldown / this.player.atkSpdMult) return;
        this.timer = 0;
        this.player.speedMult += 2;
        this.player.invincible = true;
        this.player.iframeTimer = 2000;
        //invalid: this.player.sprite.setFillStyle(0xffffff);
        this.scene.time.delayedCall(2000, () => {
            this.player.speedMult -= 2;
            //not a function
            //this.player.sprite.setFillStyle(this.player.def.color);
        });
        // Damage enemies we pass through — checked in GameScene enemy collision
        this._charging = true;
        this.scene.time.delayedCall(2000, () => this._charging = false);
    }
}

class IronRind extends Ability {
    constructor(s, p) { super(s, p, 'iron_rind', 'Reduces damage taken based on pulp collected'); this._basePulp = 0; }
    // Passive: flat damage reduction — modified in player's takeDamage  
    getDR() { return Math.floor(this.scene.totalPulpCollected / 80); }
}

class GravityWell extends Ability {
    constructor(s, p) { super(s, p, 'gravity_well', 'Pulls enemies toward a point'); this.cooldown = 12000; }
    update(delta) {
        this.timer += delta;
        if (this.timer < this.cooldown / this.player.atkSpdMult) return;
        this.timer = 0;
        const tx = this.player.x + Phaser.Math.Between(-180, 180);
        const ty = this.player.y + Phaser.Math.Between(-180, 180);
        const g = this.scene.add.circle(tx, ty, 10, 0x000022, 1).setDepth(22);
        this.scene.tweens.add({ targets: g, scaleX: 5, scaleY: 5, duration: 600 });
        // Pull enemies in
        const iv = this.scene.time.addEvent({
            delay: 80, repeat: 8, callback: () => {
                for (const e of this.scene.enemies) {
                    if (e.dead) continue;
                    const ang = Math.atan2(ty - e.y, tx - e.x);
                    const d = Phaser.Math.Distance.Between(tx, ty, e.x, e.y);
                    if (d < 200) {
                        e.x += Math.cos(ang) * 18;
                        e.y += Math.sin(ang) * 18;
                    }
                }
            }
        });
        this.scene.time.delayedCall(700, () => {
            this.aoeAttack(tx, ty, 90 * this.player.aoeMult, 55, 0x4444ff, 500);
            this.scene.tweens.add({
                targets: g, scaleX: 0, scaleY: 0, alpha: 0, duration: 300,
                onComplete: () => g.destroy()
            });
        });
    }
}

// ============================================================
//  Ability registry
// ============================================================
const ABILITY_CLASSES = {
    zapping_stem: ZappingStem,
    static_peel: StaticPeel,
    acid_rain: AcidRain,
    solar_flare: SolarFlare,
    molecular_rebuild: MolecularRebuild,
    heavy_slap: HeavySlap,
    spin_kick: SpinKick,
    shockwave: Shockwave,
    thorns: Thorns,
    berserk_mush: BerserkMush,
    seed_spitter: SeedSpitter,
    spore_cloud: SporeCloud,
    vine_grasp: VineGrasp,
    fruit_bat_swarm: FruitBatSwarm,
    root_shield: RootShield,
    bone_shard: BoneShard,
    decay_aura: DecayAura,
    rise_of_peels: RiseOfPeels,
    soul_siphon: SoulSiphon,
    rot_blast: RotBlast,
    dash_slash: DashSlash,
    thrown_blade: ThrownBlade,
    blur: Blur,
    blade_fan: BladeFan,
    critical_rip: CriticalRip,
    shield_bash: ShieldBash,
    ground_pound: GroundPound,
    unstoppable_charge: UnstoppableCharge,
    iron_rind: IronRind,
    gravity_well: GravityWell,
};