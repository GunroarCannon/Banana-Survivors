class LootLockerService {
    constructor() {
        this.apiKey = "dev_c5adaa99b89344599c92f2f0e535f96a";
        this.domainKey = "jgzdbwyc";
        this.baseUrl = "https://jgzdbwyc.api.lootlocker.io/game";
        this.sessionToken = null;
        this.playerId = null;
        this.isOnline = true;
    }

    async startSession() {
        try {
            const response = await fetch(`${this.baseUrl}/v1/session/guest`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    game_key: this.apiKey,
                    game_version: "0.1.0"
                })
            });
            const data = await response.json();
            this.sessionToken = data.session_token;
            this.playerId = data.player_id;
            this.isOnline = true;
            console.log("LootLocker Session Started", data);
            
            // Try to process any pending scores
            this.processOfflineQueue();
            
            return data;
        } catch (e) {
            this.isOnline = false;
            console.warn("LootLocker Offline", e);
        }
    }

    async setPlayerName(name) {
        if (!this.sessionToken) return;
        try {
            const response = await fetch(`${this.baseUrl}/v1/player/name`, {
                method: 'PATCH',
                headers: {
                    'x-session-token': this.sessionToken,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ name: name })
            });
            return await response.json();
        } catch (e) {
            console.error("Failed to set player name", e);
        }
    }

    async submitScore(score, metadata = "") {
        const payload = {
            score: score,
            metadata: typeof metadata === 'string' ? metadata : JSON.stringify(metadata)
        };

        if (!this.sessionToken || !this.isOnline) {
            this.queueScore(payload);
            return { queued: true };
        }

        try {
            const response = await fetch(`${this.baseUrl}/v1/leaderboards/bananas/submit`, {
                method: 'POST',
                headers: {
                    'x-session-token': this.sessionToken,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(payload)
            });
            
            if (!response.ok) throw new Error("Upload failed");
            
            const data = await response.json();
            this.isOnline = true;
            return data;
        } catch (e) {
            this.isOnline = false;
            console.warn("Submit failed, queuing score", e);
            this.queueScore(payload);
            return { queued: true };
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
        if (queue.length === 0) return;
        
        console.log("Processing offline queue...", queue.length);
        const remaining = [];
        
        for (const item of queue) {
            try {
                await fetch(`${this.baseUrl}/v1/leaderboards/bananas/submit`, {
                    method: 'POST',
                    headers: {
                        'x-session-token': this.sessionToken,
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(item)
                });
            } catch (e) {
                remaining.push(item);
            }
        }
        
        localStorage.setItem('ls_pending_scores', JSON.stringify(remaining));
    }

    async getTopScores(count = 10) {
        if (!this.sessionToken) return { items: [] };
        try {
            const response = await fetch(`${this.baseUrl}/v1/leaderboards/bananas/list?count=${count}`, {
                method: 'GET',
                headers: { 'x-session-token': this.sessionToken }
            });
            const data = await response.json();
            this.isOnline = true;
            return data;
        } catch (e) {
            this.isOnline = false;
            console.error("Failed to get scores", e);
            throw e;
        }
    }
}

window.lootLocker = new LootLockerService();