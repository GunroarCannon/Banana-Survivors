// ============================================================
//  Player
// ============================================================
class Player extends BaseObject {
    constructor(scene, x, y, classKey = 'alchemist') {
        const def = {
            key: 'player_' + classKey,
            source: CLASS_DEFS[classKey]?.source,
            hp: CONFIG.PLAYER_BASE_HP,
            speed: CONFIG.PLAYER_SPEED,
            damage: 10,
            faction: CONFIG.FACTIONS.PLAYER,
            width: 42, height: 42,
            color: CLASS_DEFS[classKey]?.color || 0xffe066,
        };
        super(scene, x, y, def);

        this.classKey = classKey;
        this.classDef = CLASS_DEFS[classKey];

        // Stat multipliers (modified by upgrades)
        this.damageMult = 1;
        this.speedMult = 1;
        this.atkSpdMult = 1;
        this.aoeMult = 1;
        this.projCount = 1;
        this.critChance = 0.05;
        this.hpRegen = 0;
        this.magnetRadius = CONFIG.PULP_MAGNET_RADIUS;
        this.xpMult = 1;

        // Movement
        this.vx = 0; this.vy = 0;
        this.facing = { x: 0, y: 1 };

        // Invincibility frames
        this.iframeTimer = 0;
        this.invincible = false;

        // Abilities
        this.abilities = [];
        this._initAbilities();

        // Build class badge label
        this._buildLabel();
    }

    _buildLabel() {
        this.label = this.scene.add.text(this.x, this.y - 32,
            this.classDef?.name || 'Banana', {
            fontFamily: "'Fredoka One', sans-serif",
            fontSize: '11px', fill: '#fff',
            stroke: '#000', strokeThickness: 3
        }).setDepth(15).setOrigin(0.5);
    }

    _initAbilities() {
        const defs = this.classDef?.abilities || [];
        for (const ablKey of defs.slice(0, 2)) { // start with first 2 (core)
            const cls = ABILITY_CLASSES[ablKey];
            if (cls) this.abilities.push(new cls(this.scene, this));
        }
    }

    unlockAbility(ablKey) {
        if (this.abilities.find(a => a.key === ablKey)) return;
        const cls = ABILITY_CLASSES[ablKey];
        if (cls) this.abilities.push(new cls(this.scene, this));
    }

    applyUpgrade(upg) {
        const e = upg.effect;
        if (e.mode === 'add') {
            this[e.stat] = (this[e.stat] || 0) + e.value;
        } else {
            this[e.stat] = (this[e.stat] || 1) * e.value;
        }
        // If it references an ability key
        if (upg.abilityKey) this.unlockAbility(upg.abilityKey);
    }

    get effectiveSpeed() { return this.speed * this.speedMult * 2.4; }
    get effectiveDamage() { return this.def.damage * this.damageMult; }

    setVelocity(vx, vy) {
        this.vx = vx; this.vy = vy;
        if (vx !== 0 || vy !== 0) {
            this.facing.x = vx; this.facing.y = vy;
        }
    }

    update(delta, entities) {
        // Regen
        if (this.hpRegen > 0) {
            this.hp = Math.min(this.maxHp, this.hp + this.hpRegen * (delta / 1000));
        }

        // iFrames
        if (this.invincible) {
            this.iframeTimer -= delta;
            if (this.iframeTimer <= 0) {
                this.invincible = false;
                this.sprite.setAlpha(1);
            } else {
                this.sprite.setAlpha(Math.sin(Date.now() / 60) * 0.5 + 0.5);
            }
        }

        // Move
        const spd = this.effectiveSpeed;
        const nx = this.x + this.vx * spd * (delta / 1000);
        const ny = this.y + this.vy * spd * (delta / 1000);
        this.setPosition(
            GameUtils.clamp(nx, 20, this.scene.worldW - 20),
            GameUtils.clamp(ny, 20, this.scene.worldH - 20)
        );

        // Abilities
        for (const abl of this.abilities) abl.update(delta, entities);

        this._applyWalkAnimation(delta);

        this.label.setPosition(this.x, this.y - this.height / 2 - 14);
    }

    takeDamage(amount) {
        if (this.invincible || this.dead) return;
        this.hp -= amount;
        this.invincible = true;
        this.iframeTimer = CONFIG.PLAYER_IFRAMES_MS;
        GameUtils.screenShake(this.scene);
        GameUtils.floatText(this.scene, this.x, this.y - 20, '-' + Math.round(amount), '#ff4444');
        if (this.hp <= 0) {
            this.hp = 0;
            this._die();
        }
        this.scene.events.emit('player_hp_changed', this.hp, this.maxHp);
    }

    heal(amount) {
        this.hp = Math.min(this.maxHp, this.hp + amount);
        GameUtils.floatText(this.scene, this.x, this.y - 20, '+' + Math.round(amount), '#44ff88');
        this.scene.events.emit('player_hp_changed', this.hp, this.maxHp);
    }

    _die() {
        this.dead = true;
        // sfx_death_player: special longer fanfare on player death (sad trombone)
        if (this.scene.sound.get('sfx_death_player')) this.scene.sound.play('sfx_death_player', { volume: 0.6, rate: 0.9 });
        else if (this.scene.sound.get('sfx_death_enemy')) this.scene.sound.play('sfx_death_enemy', { volume: 0.6, rate: 0.6 });
        GameUtils.burst(this.scene, this.x, this.y, 0xffe066, 30);
        GameUtils.screenShake(this.scene, CONFIG.SCREENSHAKE_BOSS);
        this.sprite.destroy();
        this.face?.destroy();
        this.label?.destroy();
        for (const a of this.abilities) a.destroy?.();
        this.scene.events.emit('player_dead');
    }

    setPosition(x, y) {
        super.setPosition(x, y);
        this.label?.setPosition(x, y - this.height / 2 - 14);
    }

    destroy() {
        super.destroy();
        this.label?.destroy();
        for (const a of this.abilities) a.destroy?.();
    }
}

// ============================================================
//  Class definitions
// ============================================================
const CLASS_DEFS = {
    alchemist: {
        name: 'The Alchemist',
        desc: 'Master of volatile concoctions. Excels at elemental chain reactions.',
        color: 0x44ffaa, speed: 200, hp: 100, source: 'alchemist', animType: 'bounce',
        abilities: ['zapping_stem', 'static_peel', 'acid_rain', 'solar_flare', 'molecular_rebuild']
    },
    bruiser: {
        name: 'Bruiser',
        desc: 'Heavy hitter that thrives in close combat. High health, low speed.',
        color: 0xff6644, speed: 160, hp: 160, animType: 'rock', source: 'bruiser',
        abilities: ['heavy_slap', 'spin_kick', 'shockwave', 'thorns', 'berserk_mush']
    },
    overseer: {
        name: 'Overseer',
        desc: 'Summons helpers and manipulates the battlefield from afar.',
        color: 0x44aaff, speed: 180, hp: 90, animType: 'bounce', source: 'overseer',
        abilities: ['seed_spitter', 'spore_cloud', 'vine_grasp', 'fruit_bat_swarm', 'root_shield'],
        unlockCond: { type: 'maxLevel', value: 11, label: 'Reach Level 11' }
    },
    grave_ripener: {
        name: 'Grave Ripener',
        desc: 'Harnesses the decay of fallen enemies to power dark machinations.',
        color: 0xaa44ff, speed: 170, hp: 120, animType: 'rock', source: 'grave_ripener',
        abilities: ['bone_shard', 'decay_aura', 'rise_of_peels', 'soul_siphon', 'rot_blast'],
        unlockCond: { type: 'totalRuns', value: 10, label: 'Play 10 Times' }
    },
    slicer: {
        name: 'Slicer',
        desc: 'Incredibly fast and deadly, but extremely fragile.',
        color: 0xffee33, speed: 230, hp: 70, animType: 'wiggle', source: 'slicer',
        abilities: ['dash_slash', 'thrown_blade', 'blur', 'blade_fan', 'critical_rip'],
        unlockCond: { type: 'maxKills', value: 400, label: '400 Kills in One Run' }
    },
    iron_husk: {
        name: 'Iron Husk',
        desc: 'Unstoppable juggernaut with heavy crowd control skills.',
        color: 0xaaaaaa, speed: 150, hp: 200, animType: 'rock', source: 'iron_husk',
        abilities: ['shield_bash', 'ground_pound', 'unstoppable_charge', 'iron_rind', 'gravity_well'],
        unlockCond: { type: 'totalKills', value: 4000, label: '4000 Total Kills' }
    }
};