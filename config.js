// ============================================================
//  BANANA SURVIVORS — Global Config
//  All tunable values live here. Change freely.
// ============================================================
const nn = 1.2;
const CONFIG = {
    // ── Display ──────────────────────────────────────────────
    WIDTH: 360 * nn,
    HEIGHT: 640 * nn,

    MAX_ENEMIES: 70,
    MAX_SIMULTANEOUS_SFX: 8,

    DEBUG: false,

    // ── Player ───────────────────────────────────────────────
    BASE_SPEED: 180,

    // Audio definitions (modular for easy changes later)
    MUSIC: [
        'assets/music/adventuring_song.mp3',
        'assets/music/Battle Theme 5.mp3',
        'assets/music/carnival_of_strangeness_0.mp3',
        'assets/music/gem_popper.mp3',
        'assets/music/ghosts_and_heroes.mp3',
        'assets/music/pd_game.ogg',
        'assets/music/the_battle_of_atheria.ogg'
    ],
    // ── SFX Registry ─────────────────────────────────────────────
    // All sfx keys reference files under assets/sfx/. Load order in BootScene.
    SFX: {
        // ── Gameplay hits ──────────────────────────────────────────
        hit: 'assets/sfx/Juhani_Junkala/sfx_wpn_punch1.wav',       // generic melee hit
        hit2: 'assets/sfx/Juhani_Junkala/sfx_wpn_punch2.wav',       // alternate hit
        hit3: 'assets/sfx/fleshy_fight_sounds/squash.mp3',          // fleshy hit variant
        hit_heavy: 'assets/sfx/hits/3.ogg',                              // heavy enemy hit
        shoot: 'assets/sfx/battle_sound_effects/swish_2.wav',        // projectile fire
        shoot2: 'assets/sfx/battle_sound_effects/bow.wav',            // alt projectile
        // ── Deaths ────────────────────────────────────────────────
        death_enemy: 'assets/sfx/creatures/deathb.wav',                   // regular enemy death
        death_enemy2: 'assets/sfx/creatures/deathe.wav',                   // elite/boss death
        death_player: 'assets/sfx/fesliyan_studios/sad_trombone_1.mp3',    // player death fanfare
        // ── Collect / XP ──────────────────────────────────────────
        collect: 'assets/sfx/JBM_sfxr_pack_1/collect01.ogg',          // pulp gem collect
        powerup: 'assets/sfx/JBM_sfxr_pack_1/powerup01.ogg',          // upgrade picked
        levelup: 'assets/sfx/sfx_other/win_sound.ogg',                // level up chime
        // ── UI / Menus ────────────────────────────────────────────
        click: 'assets/sfx/pd/snd_click.mp3',                       // button / card click
        // ── Special enemy attacks ─────────────────────────────────
        lightning: 'assets/sfx/pd/snd_lightning.ogg',                   // Storm Titan lightning
        freeze: 'assets/sfx/sfx_other/freeze.ogg',                   // Glacial Behemoth freeze
        explosion: 'assets/sfx/GameBurp_FREE_Game_Sound_FX_Pack_OGG/EXPLOSION Bang 04.ogg', // Magma slam
        zap: 'assets/sfx/GameBurp_FREE_Game_Sound_FX_Pack_OGG/ELECTRIC Shock Zap Short 03.ogg',
        charge: 'assets/sfx/battle_sound_effects/swish_2.wav',
        //'assets/sfx/GameBurp_FREE_Game_Sound_FX_Pack_OGG/SWOOSH_Whoosh_Light_01.ogg',
        charge_impact: 'assets/sfx/hits/3.ogg',
        // ── Boss / elite ──────────────────────────────────────────
        boss_spawn: 'assets/sfx/sfx_other/warhorn.ogg',                  // boss warning
        slam: 'assets/sfx/sfx_other/slam.ogg',                     // ground slam land
    },
    PLAYER_BASE_HP: 100,
    PLAYER_IFRAMES_MS: 400,   // invincibility after being hit

    // ── Pulp (XP) ────────────────────────────────────────────
    PULP_MAGNET_RADIUS: 80,    // auto-collect within this px
    PULP_MAGNET_SPEED: 320,
    // [0, 10, 35, 90, 220, 500, 1100, 2400, 5000, 10000, 18000, 30000]
    PULP_PER_LEVEL: [8, 15, 30, 50, 80, 120, 160, 220, 300, 390,
        490, 610, 750, 900, 1060, 1240, 1440, 1650, 1870, 2110,
        2370, 2640, 2920, 3220, 3540, 3870, 4210, 4570, 4950, 5340],
    //  [0, 10, 35, 90, 220, 500, 1100, 2400, 5000, 10000, 18000, 30000], // XP thresholds

    // ── Difficulty Scaling ───────────────────────────────────
    SCALE_INTERVAL_SEC: 15,    // difficulty tick every N seconds
    ENEMY_STAT_MULT: 0.12,  // +12% per tick (multiplicative)
    ELITE_INTERVAL_SEC: 30,
    BOSS_MILESTONES_SEC: [30, 90, 150, 180], // 30 sec / 1.5 / 2.5 / 3 min

    // ── Wave Spawner ─────────────────────────────────────────
    SPAWN_INTERVAL_MS: 1500,
    SPAWN_BASE_COUNT: 3,
    SPAWN_VIEWPORT_PAD: 60,    // px outside camera edge

    // ── Faction System ───────────────────────────────────────
    FACTIONS: { PLAYER: 0, ENEMY: 1, NEUTRAL: 2 },

    // ── Abilities ────────────────────────────────────────────
    ABILITY_TICK_MS: 100,   // how often ability update() runs

    // ── Game Feel ────────────────────────────────────────────
    SCREENSHAKE_HIT: { intensity: 4, duration: 80 },
    SCREENSHAKE_BOSS: { intensity: 12, duration: 250 },
    HITSTOP_MS: 55,
    FLASH_DURATION_MS: 80,

    // ── Fermented One ────────────────────────────────────────
    FERMENTED_SPAWN_CHANCE: 0.10,   // 10 %

    // ── UI ───────────────────────────────────────────────────
    UI_JOYSTICK_RADIUS: 55,
    UI_JOYSTICK_THUMB: 30,

    // ── Enemy Collisions ──────────────────────────────────────
    // When true, enemies push each other apart (prevents stacking)
    ENEMIES_COLLIDE: true,
};

// Enemy definitions — add new entries freely; the spawner picks automatically
// intensity: minimum difficulty level before this enemy can appear
const ENEMY_DEFS = {
    maggot: {
        key: 'maggot',
        source: 'maggot',
        label: 'Maggot',
        width: 50, height: 50,
        rotateToDirection: false,
        hp: 18,
        speed: 25,
        damage: 6,
        xp: 2,
        color: 0xd4e86e,
        intensity: 0,
        ai: 'seek',
        animType: 'wiggle'
    },
    mold_fly: {
        key: 'mold_fly',
        label: 'Mold Fly',
        source: "spore_moth",
        icson: 'ei_dragonfly',         // lorc/dragonfly — insect silhouette
        width: 50, height: 50,
        hp: 10,
        speed: 140,
        damage: 4,
        xp: 3,
        color: 0x6ec4e8,
        intensity: 0,
        ai: 'seek',
        moveType: 'zigzag',
        animType: 'bounce'
    },
    rot_slug: {
        key: 'rot_slug',
        label: 'Rot Slug',
        source: "zombie_banana",            // lorc/snail — slow-moving trail
        width: 40, height: 40,
        hp: 55,
        speed: 45,
        damage: 12,
        xp: 6,
        color: 0xe87d3e,
        intensity: 1,
        ai: 'seek',
        animType: 'wiggle'
    },
    spore_moth: {
        key: 'spore_moth',
        source: "zombie_banana",
        label: 'Spore Moth',
        icson: 'ei_butterfly',         // lorc/butterfly — moth-like wings
        width: 32, height: 32,
        hp: 30,
        speed: 110,
        damage: 8,
        xp: 5,
        color: 0xa06ee8,
        intensity: 2,
        ai: 'seek',
        moveType: 'circle',
        animType: 'bounce'
    },
    fungal_horror: {
        key: 'fungal_horror',
        source: "fungal_horror",
        label: 'Fungal Horror',
        icosn: 'ei_mushroom',          // lorc/mushroom — fungal theme
        width: 54, height: 54,
        hp: 180,
        speed: 38,
        damage: 22,
        xp: 20,
        color: 0xe84040,
        intensity: 2,
        ai: 'seek',
        isElite: false,
        animType: 'bounce'
    },
    eldritch_peel: {
        key: 'eldritch_peel',
        label: 'Eldritch Peel',
        source: 'ei_tentacles_skull',   // lorc/tentacles-skull — eldritch horror
        width: 70, height: 70,
        hp: 800,
        speed: 30,
        damage: 35,
        xp: 80,
        color: 0xff2200,
        intensity: 5,
        ai: 'seek',
        isBoss: true,
    },

    // ── Giant Special-Attack Enemies (3-5× player size) ──────────────────
    // Player is 42×42. These are 126px to 210px wide.

    storm_titan: {
        key: 'storm_titan',
        label: 'Storm Titan',
        moveType: 'charge',
        source: 'rot_god',   // lorc/lightning-storm — sparks and bolts
        // ~4× player (42×42 → 168×168)
        width: 168 * 2, height: 168 * 2,
        hp: 1200,
        speed: 28,
        damage: 20,
        xp: 120,
        color: 0x44ccff,
        intensity: 4,
        // 'lightning_chain' AI fires a multi-target lightning bolt at intervals
        ai: 'magma_slam',//'lightning_chain',
        isElite: true,
        animType: 'bounce',
    },

    glacial_behemoth: {
        key: 'glacial_behemoth',
        label: 'Glacial Behemoth',
        source: 'rot_god',
        idcon: 'ei_frozen_orb',        // lorc/frozen-orb — icy orb
        // ~5× player (42×42 → 210×210)
        width: 210, height: 210,
        hp: 1600,
        speed: 18,
        damage: 50,
        xp: 160,
        color: 0xaaeeff,
        intensity: 5,
        // 'freeze_burst' AI slows and damages in a huge AoE shockwave
        ai: 'freeze_burst',
        isBoss: true,
        animType: 'bounce',
    },

    magma_lord: {
        key: 'magma_lord',
        label: 'Magma Lord',
        source: 'fungal_horror',           // lorc/volcano — eruption imagery
        // ~3.5× player (42×42 → 147×147)
        width: 147, height: 147,
        hp: 1000,
        speed: 35,
        damage: 25,
        xp: 140,
        color: 0xff6600,
        intensity: 4,
        // 'magma_slam' AI leaves burning ground pools on slam
        ai: 'magma_slam',
        isElite: true,
        animType: 'bounce',
    },
    wasp: {
        key: 'wasp',
        label: 'Vicious Wasp',
        source: 'ei_bee',
        width: 26, height: 26,
        hp: 25,
        speed: 160,
        damage: 10,
        xp: 4,
        color: 0xffd700,
        intensity: 1,
        ai: 'seek',
        moveType: 'zigzag',
        animType: 'bounce'
    },
    beetle: {
        key: 'beetle',
        label: 'Armored Beetle',
        source: 'zombie_banana',
        width: 38, height: 38,
        hp: 120,
        speed: 50,
        damage: 15,
        xp: 12,
        color: 0x556b2f,
        intensity: 2,
        ai: 'seek',
        animType: 'bounce'
    },
    centipede: {
        key: 'centipede',
        label: 'Giant Centipede',
        icon: 'maggot',
        width: 105, height: 45,
        hp: 250,
        speed: 90,
        damage: 18,
        xp: 25,
        color: 0x8b4513,
        intensity: 3,
        ai: 'seek',
        moveType: 'zigzag',
        animType: 'wiggle'
    },
    behemoth_charger: {
        key: 'behemoth_charger',
        label: 'Behemoth Charger',
        icosn: 'ei_bull-horns',
        source: "iron_husk",
        width: 420, height: 420,
        hp: 5000,
        speed: 40,
        damage: 60,
        xp: 500,
        color: 0x555555,
        intensity: 6,
        ai: 'charge',
        isBoss: true,
        animType: 'rock'
    },
    charger_scout: {
        key: 'charger_scout',
        label: 'Charger Scout',
        source: 'fungal_horror-horns',
        width: 84, height: 84,
        hp: 400,
        speed: 100,
        damage: 25,
        xp: 40,
        color: 0x777777,
        intensity: 3,
        ai: 'charge',
        isElite: true,
        animType: 'rock'
    }
};

// Upgrade pool (shared across classes for now; class-specific filtered at runtime)
const UPGRADE_POOL = [
    { id: 'dmg_up', icon: 'banana_icon', label: 'Potassium Surge', desc: '+15% damage', effect: { stat: 'damageMult', value: 0.15, mode: 'add' } },
    { id: 'spd_up', icon: 'lightning', label: 'Ripe Rush', desc: '+12% movement speed', effect: { stat: 'speedMult', value: 0.12, mode: 'add' } },
    { id: 'hp_up', icon: 'heart_organ', label: 'Pulpy Constitution', desc: '+25 max HP', effect: { stat: 'maxHp', value: 25, mode: 'add' } },
    { id: 'atkspd_up', icon: 'stopwatch', label: 'Overripe Frenzy', desc: '+15% attack speed', effect: { stat: 'atkSpdMult', value: 0.15, mode: 'add' } },
    { id: 'magnet', icon: 'magnet', label: 'Pulp Magnet', desc: '+40 magnet radius', effect: { stat: 'magnetRadius', value: 40, mode: 'add' } },
    { id: 'regen', icon: 'leaf', label: 'Ferment Heal', desc: '+1 HP/sec regen', effect: { stat: 'hpRegen', value: 1, mode: 'add' } },
    { id: 'proj_up', icon: 'gun', label: 'Split Seed', desc: '+1 projectile count', effect: { stat: 'projCount', value: 1, mode: 'add' } },
    { id: 'aoe_up', icon: 'explosion', label: 'Pulp Splash', desc: '+20% area size', effect: { stat: 'aoeMult', value: 0.20, mode: 'add' } },
    { id: 'crit_up', icon: 'blood', label: 'Rotten Core', desc: '+8% crit chance', effect: { stat: 'critChance', value: 0.08, mode: 'add' } },
];