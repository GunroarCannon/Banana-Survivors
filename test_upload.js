/**
 * Test script to emulate a score upload to LootLocker.
 * Paste this into the browser console (F12 -> Console) while the game is running.
 */
async function testLootLockerUpload() {
    if (!window.lootLocker) {
        console.error("LootLocker service not found on window object! Make sure the game is running and lootlocker.js is loaded.");
        return;
    }

    console.log("Starting test upload...");
    console.log("Current Online Status:", window.lootLocker.isOnline);
    
    // Ensure session is started
    if (!window.lootLocker.sessionToken) {
        console.log("No active session. Starting session first...");
        try {
            const session = await window.lootLocker.startSession();
            if (!session) {
                console.error("Failed to start session. Check console for network errors. This often happens if the API key or Domain Key in lootlocker.js is incorrect.");
                return;
            }
            console.log("Session started successfully!", session);
        } catch (e) {
            console.error("Failed to start session:", e);
            return;
        }
    }

    // Set a test name if none exists
    let playerName = localStorage.getItem('player_name');
    if (!playerName) {
        playerName = "TestBot_" + Math.floor(Math.random() * 1000);
        console.log("No player name found, using: " + playerName);
        localStorage.setItem('player_name', playerName);
        await window.lootLocker.setPlayerName(playerName);
    }

    const testScore = Math.floor(Math.random() * 500) + 50;
    const testMetadata = {
        class: "Test Runner",
        time: "0:42",
        lvl: 5,
        is_test: true
    };

    console.log(`Submitting score: ${testScore} for player: ${playerName} with metadata:`, testMetadata);
    
        try {
            const result = await window.lootLocker.submitScore(testScore, testMetadata);
            if (result && result.queued) {
                console.warn("⚠️ Score queued (offline mode). The service thinks it's offline.");
                console.log("Service Online State:", window.lootLocker.isOnline);
            } else if (result) {
            console.log("✅ Score uploaded successfully!", result);
        } else {
            console.error("❌ Submission returned no result.");
        }
    } catch (e) {
        console.error("❌ Submission threw error:", e);
    }
}

// Auto-run if pasted
testLootLockerUpload();
