/**
 * Perlin Noise Implementation
 * Usage: 
 * const pn = new Perlin(Math.random());
 * let value = pn.noise(x, y, z);
 */
class Perlin {
    constructor(seed) {
        this.p = new Uint8Array(512);
        this.permutation = new Uint8Array(256);

        const rng = new Phaser.Math.RandomDataGenerator([seed.toString()]);
        for (let i = 0; i < 256; i++) {
            this.permutation[i] = i;
        }

        // Shuffle permutations
        for (let i = 255; i > 0; i--) {
            const r = rng.integerInRange(0, i);
            [this.permutation[i], this.permutation[r]] = [this.permutation[r], this.permutation[i]];
        }

        // Duplicate the permutation array
        for (let i = 0; i < 512; i++) {
            this.p[i] = this.permutation[i & 255];
        }
    }

    fade(t) { return t * t * t * (t * (t * 6 - 15) + 10); }
    lerp(t, a, b) { return a + t * (b - a); }
    grad(hash, x, y, z) {
        const h = hash & 15;
        const u = h < 8 ? x : y;
        const v = h < 4 ? y : h === 12 || h === 14 ? x : z;
        return ((h & 1) === 0 ? u : -u) + ((h & 2) === 0 ? v : -v);
    }

    /**
     * Generates a noise value between -1.0 and 1.0 (usually centered around 0)
     */
    noise(x, y = 0, z = 0) {
        const X = Math.floor(x) & 255;
        const Y = Math.floor(y) & 255;
        const Z = Math.floor(z) & 255;

        x -= Math.floor(x);
        y -= Math.floor(y);
        z -= Math.floor(z);

        const u = this.fade(x);
        const v = this.fade(y);
        const w = this.fade(z);

        const A = this.p[X] + Y, AA = this.p[A] + Z, AB = this.p[A + 1] + Z;
        const B = this.p[X + 1] + Y, BA = this.p[B] + Z, BB = this.p[B + 1] + Z;

        return this.lerp(w, this.lerp(v, this.lerp(u, this.grad(this.p[AA], x, y, z),
            this.grad(this.p[BA], x - 1, y, z)),
            this.lerp(u, this.grad(this.p[AB], x, y - 1, z),
                this.grad(this.p[BB], x - 1, y - 1, z))),
            this.lerp(v, this.lerp(u, this.grad(this.p[AA + 1], x, y, z - 1),
                this.grad(this.p[BA + 1], x - 1, y, z - 1)),
                this.lerp(u, this.grad(this.p[AB + 1], x, y - 1, z - 1),
                    this.grad(this.p[BB + 1], x - 1, y - 1, z - 1))));
    }
}

// Export for use in other modules
window.Perlin = Perlin;