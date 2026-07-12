# XMB UI prototype

## What this first prototype is

This is an original, text-and-shape XMB-inspired library screen. It uses the
same live category table and selected game as RetroFlow, but draws them as a
horizontal category axis with a vertical game axis.

It is intentionally a presentation prototype, not a launcher rewrite.

## What stays the same

- The prototype is disabled by default through `xmbPrototypeEnabled` in
  `src/index.lua`.
- When disabled, the legacy RetroFlow UI draws exactly as before.
- When enabled in a reviewed test build, the existing code still owns input,
  category changes, search, favourites, recents, collections, scans, cache,
  settings, and launches.
- It adds no files, installs nothing, and does not enable AutoBoot.

## Design choices

- **Left/right axis:** shown as the top row of PSP-style media categories.
- **Up/down axis:** shown as a short vertical list around the selected game.
- **Focus:** the selected existing game record is the bright central item.
- **Assets:** only text and rectangles are used. No Sony-derived visual or
  audio asset is added.
- **Fallback:** the legacy renderer remains in place underneath the prototype.
  Turning the flag off immediately restores the old presentation.

The top labels now match the planned PSP-style category names. They are still
English visual markers for the first layout pass, not final user-facing
translations or icons.

## Important limitation

The prototype now has its first navigation state: D-pad Left/Right moves the
highlight across the six top-level categories and wraps at either end. Games
continues to use existing RetroFlow controls and actions. The other five
columns are deliberately non-interactive placeholders, so they cannot launch a
game, alter settings, or access a guessed Vita app. Up/Down folder navigation
and working category actions are a later, separately tested step.

## Future hardware test

Do not enable the flag or install a test package yet. Once packaging Gate 1 is
complete and a reviewed VPK exists, a test build may explicitly set the flag to
`true`. The hardware tester should verify only that the library screen opens,
existing navigation still works, and turning the flag off returns to the legacy
screen.
