# XMBFlow navigation direction

## Design reference and boundary

This design takes high-level inspiration from
[HiroTex/OSD-XMB](https://github.com/HiroTex/OSD-XMB): a calm XMB-style
dashboard with stable top-level categories and content folders beneath them.
It does not copy OSD-XMB code, themes, icons, sounds, artwork, PS2 launch
rules, file explorer, AutoBoot behaviour, or its GPL-3.0 licensed assets.

XMBFlow remains an original PS Vita launcher built around RetroFlow's existing
library and launch features.

## Navigation model

The finished layout should have a small horizontal row of stable columns. Each
column contains a vertical list. This prevents dozens of console types from
turning the top row into an unreadable strip.

| Top-level column | Vertical items | Existing RetroFlow data |
| --- | --- | --- |
| Library | All games, Vita, Homebrew, PSP, PS1, PSM, Retro systems | Existing category tables and `SystemsToScan` |
| Collections | User collections, then collection games | Existing collections |
| Favourites | Favourite games | Existing favourites table |
| Recent | Recently played games | Existing recents table |
| Search | Start a search, then show results | Existing search flow/results table |
| Settings | Existing safe settings menus and About/Recovery entry points | Existing menus only |

Inside **Library**, choosing **Retro systems** opens a second vertical list of
systems such as SNES, Mega Drive, arcade, and ScummVM. Choosing a system then
shows its existing games. This keeps Vita, PSP, PS1, PSM, and ROM support
visible without creating a separate database or removing a supported system.

## Controls

The eventual XMB controller mapping should remain familiar to RetroFlow users:

| Control | In XMBFlow |
| --- | --- |
| Left / Right | Move between top-level columns. |
| Up / Down | Move through the selected column's vertical items. |
| Cross | Enter a folder, select a menu item, or launch the selected game through the existing launch adapter. |
| Circle | Go back one level; never delete or reset anything. |
| Triangle | Open the existing details/options screen for a game. |
| Square | Open a small context/category menu using existing safe actions. |
| Start | Open existing settings. |
| Select | Open existing search. |
| L / R | Keep the current quick game-list movement where it makes sense. |

The Cross/Circle mapping must continue to respect RetroFlow's existing button-
swap setting. The first prototype does not change controls yet; this table is
the separately reviewed target before input code changes.

## Behaviour rules

- Folders are presentation only. They point to existing category tables and
  must not duplicate, rename, or rewrite game records.
- A game launch always goes through RetroFlow's existing availability checks,
  recents update, and launch adapter.
- Search, favourites, recents, collections, artwork, scan settings, and
  recovery remain existing features, merely reached from a new layout.
- The XMB layout stays optional until it has been packaged and tested. The
  legacy renderer remains an immediate fallback.
- Themes use original assets and colour tokens only. No Sony assets are added.
- AutoBoot, file management, content deletion, and helper-package installation
  are outside the XMB navigation scope.

## Visual direction

- Keep the background calm and low contrast so the focused item is clear.
- Use a single bright focus treatment, subtle neighbouring items, and short
  status text.
- Show game art as optional enrichment, never as a requirement for navigation.
- Use a small original icon system later; the current text placeholders in the
  prototype are intentional until those assets have a clear licence.
- Prefer smooth but interruptible motion. Input must respond immediately even
  while an animation settles.

## Implementation order

1. Keep the current text-and-shape renderer disabled by default.
2. Add a read-only navigation-state adapter behind the same opt-in flag.
3. Map XMB folders to existing RetroFlow categories without changing data.
4. Route Cross/Circle/Triangle/Square to existing handlers only.
5. Add original, licensed icons and theme tokens after the package asset
   provenance is understood.
6. Test on hardware only when a reviewed package exists and the user gives
   explicit approval.
