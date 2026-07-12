# PSP-inspired XMB structure

## Design direction

XMBFlow will follow the PSP XMB's basic structure: a fixed horizontal row of
media categories, each with a vertical list of items. The categories are part
of the interface, not a list of every game system.

This direction takes high-level inspiration from the folder-oriented layout of
[HiroTex/OSD-XMB](https://github.com/HiroTex/OSD-XMB), but does not copy its
GPL-3.0 code, assets, PS2 launch rules, file manager, or AutoBoot behaviour.

## Version-one horizontal categories

| Category | Purpose in XMBFlow |
| --- | --- |
| Settings | XMBFlow settings and safe shortcuts to existing settings features. |
| Photo | A future, verified shortcut to the Vita photo application; later, XMBFlow artwork/background settings. |
| Music | A future, verified shortcut to the Vita music application; later, XMBFlow music settings. |
| Video | A future, verified shortcut to the Vita video application. |
| Games | The main launcher library, organised into vertical folders. |
| Apps | Installed Vita/homebrew applications and app folders. |

The PSP's **Network** and **PlayStation Network** categories are intentionally
omitted from version one. XMBFlow will not add PSN sign-in, PlayStation Store
access, account management, or network configuration. Existing optional
artwork downloads can remain inside XMBFlow's safe artwork/settings flow,
separate from the main XMB structure.

## Vertical items

### Settings

- XMBFlow settings — the existing launcher settings menus.
- Library and scan settings — existing directory/scan controls only.
- Theme and appearance — existing theme choices, followed later by original
  XMBFlow themes.
- Audio and artwork — existing safe settings areas.
- About and help.
- System Settings — a future shortcut only after its Vita title ID and launch
  behaviour are verified on hardware. It must be hidden when unavailable.

Recovery remains the separate existing LiveArea recovery path. It is not
duplicated as a normal destructive menu item.

### Photo, Music, and Video

The first release should keep these small and honest:

- one native-app shortcut when a verified target is available;
- no custom file browser, media indexing, deletion, or content management;
- XMBFlow-specific background/artwork/music preferences remain in the existing
  launcher settings rather than creating duplicate media libraries.

If a native Vita app cannot be safely identified or launched, its XMBFlow item
is hidden rather than guessed.

### Games

Games is the primary column. Its vertical list should contain folders such as:

1. All Games
2. PS Vita
3. PSP
4. PlayStation / PS1
5. PlayStation Mobile
6. Homebrew games
7. Retro systems
8. Favourites
9. Recently Played
10. Collections

**Retro systems** opens a further folder list (for example SNES, Mega Drive,
arcade, ScummVM, and other already-supported systems). Choosing any folder
uses the existing RetroFlow category table; it does not scan again, copy data,
or create a second library.

Favourites, recents, and collections stay available inside Games because they
are ways to organise or revisit games, not separate kinds of console content.
Later, users may choose the visible order of these folders through a safe,
non-destructive XMBFlow preference.

### Apps

Apps is for installed Vita applications and homebrew utilities rather than game
libraries. Its vertical items can include:

- All Apps
- Utilities
- Emulators
- Appearance and theme tools
- Custom app folders

VitaShell, VitaDeploy, VitaGrafix Configurator, Custom Themes Manager, and
emulators are examples of applications that may appear when the existing scan
finds them. XMBFlow must not assume they are installed, hard-code them as
required, or add any new file-management capability. Custom folders should
build on existing collection/filter data rather than make another database.

## Controls

| Control | XMBFlow behaviour |
| --- | --- |
| Left / Right | Move between the six horizontal categories. |
| Up / Down | Move through items in the current vertical list. |
| Cross | Open a folder, select a safe settings item, or launch a selected game/app through the existing adapter. |
| Circle | Go back one level; never delete, reset, or change system settings. |
| Triangle | Open existing game/app details or options. |
| Square | Open the existing safe context/category menu. |
| Start | Open XMBFlow settings. |
| Select | Open existing search. |
| L / R triggers | Retain quick movement inside long game lists where appropriate. |

Cross/Circle must respect RetroFlow's existing button-swap setting. The initial
prototype remains visual-only; these controls are the target for a later,
separately reviewed opt-in navigation layer.

## Safety and implementation rules

- The legacy RetroFlow UI remains the default until the XMB UI is packaged and
  hardware-tested.
- Folder items are read-only views over existing tables. They must not rename,
  rewrite, or duplicate game/app records.
- Native Vita shortcuts use existing launch preflight checks and are shown only
  when their target is verified as available.
- No AutoBoot, PSN, Store, account, network-configuration, file-management,
  deletion, helper-installation, or reboot feature is added.
- All new icons, sounds, fonts, and themes must be original or properly
  licensed. The current text placeholders are intentional.

## Implementation order

1. Change the disabled prototype's top-row labels to these six categories.
2. Add a read-only XMB navigation state and folder stack behind the same opt-in
   flag.
3. Map the Games and Apps folders to existing RetroFlow tables and handlers.
4. Add native media/settings shortcuts only after their Vita targets have been
   verified on hardware.
5. Add original, licensed icon and theme assets after package asset provenance
   is understood.
6. Test only in a reviewed package and only with explicit hardware approval.
