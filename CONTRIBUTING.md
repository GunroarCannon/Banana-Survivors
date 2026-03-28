# Contributing to Banana Survivors

We welcome contributions from everyone! Whether you are a coder, an artist, or just have a great idea for a new banana class, here is how you can help.

## Getting Started

1.  **Fork the repository** and create a new branch for your feature or fix.
2.  **Run the project locally** using a static file server (like `npx serve .`).
3.  **Make your changes** following the guidelines below.
4.  **Submit a Pull Request** with a clear description of your changes.

## Content Guidelines

### Adding a New Enemy
1.  Open `config.js` and find the `ENEMY_DEFS` section.
2.  Add a new entry with the stats you want (`hp`, `speed`, `damage`, `color`).
3.  Choose a movement pattern (set `moveType` to `zigzag` or `circle`).
4.  The `WaveSpawner` will automatically incorporate your new enemy based on the `intensity` level.

### Adding a New Class
1.  Go to `player.js` and look at the `CLASS_DEFS` object.
2.  Create a new entry with a name, description, and list of abilities.
3.  If you want it to be locked initially, add an `unlockCond` object with a type (like `totalKills`) and a value.

### Creating New Abilities
1.  Open `abilities.js`.
2.  Create a new class that extends the `Ability` base class.
3.  Define the `update` method logic (e.g., shooting projectiles or creating auras).
4.  Add your new class to the `ABILITY_CLASSES` registry at the bottom of the file.

### Improving the Visuals
-   **Shaders and Post-Processing**: Modify `scene.fx.js` for full-screen effects.
-   **Particle Systems**: Use `GameUtils.burst` for simple effects or create custom emitters in `scene.fx.js`.
-   **UI Enhancement**: Check `ui.js` for interface components.

## Code Style

-   Use clear, descriptive variable and function names.
-   Comment complex logic, especially in AI or physics-heavy sections.
-   Follow the existing class-based architecture to maintain consistency.
