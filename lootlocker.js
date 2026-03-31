class LootLockerService {
    constructor() {
        this.apiKey = window.LOOTLOCKER_API_KEY || "dev_c5adaa99b89344599c92f2f0e535f96a";
        this.domainKey = "jgzdbwyc";
        this.baseUrl = "https://jgzdbwyc.api.lootlocker.io/game";
        this.lootUrl = "https://api.lootlocker.io"
        this.sessionToken = null;//ocalStorage.getItem('ll_session_token') || null;
        this.playerIdentifier = localStorage.getItem('ll_player_identifier') || crypto.randomUUID();
        localStorage.setItem('ll_player_identifier', this.playerIdentifier);
        this.leaderboardKey = "33850"; // Updated to the actual key in LootLocker dashboard
        this.isOnline = false;
    }

    async startSession() {
        if (this.sessionToken) {
            console.log("Reusing cached session token");
            this.isOnline = true;
            this.processOfflineQueue();
            return { session_token: this.sessionToken };
        }

        try {
            const response = await fetch(`${this.baseUrl}/v2/session/guest`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'x-domain-key': this.domainKey   // required for domain URL
                },
                body: JSON.stringify({
                    game_key: this.apiKey,
                    game_version: "0.1.0.0",
                    player_identifier: this.playerIdentifier,
                })
            });

            const data = await response.json();
            if (!data.session_token) throw new Error("No session token: " + JSON.stringify(data));

            this.sessionToken = data.session_token;
            localStorage.setItem('ll_session_token', this.sessionToken);
            this.isOnline = true;
            console.log("LootLocker session started", data);

            // Sync player name if available
            const name = localStorage.getItem('player_name');
            if (name) this.setPlayerName(name);

            this.processOfflineQueue();
            return data;
        } catch (e) {
            this.isOnline = false;
            console.warn("LootLocker offline / session failed", e);
        }
    }

    async ensureSession() {
        if (!this.sessionToken) await this.startSession();
    }

    async setPlayerName(name) {
        await this.ensureSession();
        if (!this.sessionToken) return;
        try {
            const response = await fetch(`https://api.lootlocker.io/game/player/name`, {
                method: 'PATCH',
                headers: {
                    'x-session-token': this.sessionToken,
                    'LL-Version': '2021-03-01',
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ name: name })
            });
            const data = await response.json();
            this.isOnline = true;
            return data;
        } catch (e) {
            this.isOnline = false;
            console.error("Failed to set player name", e);
        }
    }

    async submitScore(score, metadata = {}) {
        console.log("starting submit lootlocker")
        await this.ensureSession();
        console.log("session ensured ", this.sessionToken)
        const name = localStorage.getItem('player_name') || 'Anonymous';

        const payload = {
            member_id: name,
            score: score,
            metadata: JSON.stringify(metadata)
        };

        console.log("trying to submit score, ", payload)

        if (!this.sessionToken || !this.isOnline) {
            this.queueScore(payload);
            console.log("lootlocker score queued")
            return { queued: true };
        }

        try {
            console.log("lootlocker score submitted")
            const response = await fetch(`https://api.lootlocker.io/game/leaderboards/${this.leaderboardKey}/submit`, {
                method: 'POST',
                headers: {
                    'x-session-token': this.sessionToken,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(payload)
            });

            if (!response.ok) {
                // Session may have expired — clear and retry once
                if (response.status === 401) {
                    localStorage.removeItem('ll_session_token');
                    this.sessionToken = null;
                    await this.startSession();
                    return this.submitScore(score, metadata);
                }
                throw new Error(`Submit failed: ${response.status}`);
            }

            console.log("lootlocker score submitted babaaayy", payload, response)
            this.isOnline = true;
            return await response.json();
        } catch (e) {
            this.isOnline = false;
            console.warn("Submit failed, queuing", e);
            this.queueScore(payload);
            return { queued: true };
        }
    }

    async getTopScores(count = 100) {
        await this.ensureSession();
        try {
            const response = await fetch(`https://api.lootlocker.io/game/leaderboards/${this.leaderboardKey}/list?count=${count}`, {
                method: 'GET',
                headers: {
                    'x-session-token': this.sessionToken,
                    'Content-Type': 'application/json'
                }
            });
            const data = await response.json();
            console.log("lootlocker scores are, ", data)
            this.isOnline = true;
            if (!data.items && data.rank) return [data];
            if (data[0] && !data.items) return data;
            return data.items || [];
        } catch (e) {
            this.isOnline = false;
            console.error("Failed to get scores", e);
            return [];
        }
    }

    queueScore(payload) {
        try {
            const queue = JSON.parse(localStorage.getItem('ls_pending_scores') || '[]');
            queue.push(payload);
            localStorage.setItem('ls_pending_scores', JSON.stringify(queue));
        } catch (e) {
            console.error("Failed to queue score", e);
        }
    }

    async processOfflineQueue() {
        if (!this.sessionToken || !this.isOnline) return;
        const queue = JSON.parse(localStorage.getItem('ls_pending_scores') || '[]');
        if (!queue.length) return;
        console.log(`Processing ${queue.length} queued scores...`);
        const remaining = [];
        for (const item of queue) {
            try {
                console.log(item);
                const r = await fetch(`https://api.lootlocker.io/game/leaderboards/${this.leaderboardKey}/submit`, {
                    method: 'POST',
                    headers: {
                        'x-session-token': this.sessionToken,
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(item)
                });
                if (!r.ok) throw new Error();
            } catch {
                remaining.push(item);
            }
        }
        localStorage.setItem('ls_pending_scores', JSON.stringify(remaining));
    }

    clearSession() {
        localStorage.removeItem('ll_session_token');
        this.sessionToken = null;
        this.isOnline = false;
    }
}

window.lootLocker = new LootLockerService();