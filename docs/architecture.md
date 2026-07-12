# Architecture map

## The short version

This is RetroFlow source, renamed as the starting point for XMBFlow. It is a
Lua application for PS Vita. The source is interpreted on the Vita by a custom
Lua Player Plus runtime; this checkout contains no Windows build script,
packaging project, or runtime source.

## Where things live

| Area | Location | What it does |
| --- | --- | --- |
| Application entry point | `src/index.lua` | Starts the app, loads helpers, creates folders, loads settings and caches, scans titles, draws screens, handles input, and launches games. |
| Recovery entry point | `src/addons/recovery.lua` | Runs when startup fails and presents cache/configuration recovery choices. |
| Background task helper | `src/addons/threads.lua` | A small task queue used to spread work over frames. |
| Table writer helper | `src/addons/printTable.lua` | Writes Lua tables used as cache/database files. |
| Translations | `src/translations/*.lua` | Text shown by the interface in each supported language. |
| Built-in lookup data | `src/addons/*.db` | Database files used by selected systems such as MAME, Neo Geo, ScummVM, and Amiga. |
| Documentation and tools | `docs/`, `Tools/` | User guides and two prebuilt export-tool VPKs. |

## Library scanning and cache

`SystemsToScan` near the top of `src/index.lua` describes systems, folders,
file extensions, and cache names. Quick directory scans begin around lines
907–1195. Full system-specific scans are later in the same file: Vita around
7193, PSP around 7981/8327, and PS1 around 8763.

The cache lives on a Vita at `ux0:/data/RetroFlow/CACHE/`; setup starts around
line 1480. Import, rebuild, and save helpers are around lines 2831–2939.
Favourites, recents, renamed titles, hidden titles, collections, and launch
overrides are stored as Lua data alongside the user database. Treat their file
format as part of the existing behaviour.

## Launch adapters

The common launch preparation is near line 5586. The adapters are grouped
together immediately after it:

- `launch_Adrenaline` for PSP/PS1;
- `launch_retroarch`, `launch_emu4vita`, and `launch_retro_emulator` for ROMs;
- individual adapters for ScummVM, FAKE-08, DaedalusX64, Flycast, DSVita, and
  EasyRPG;
- `launch_psmobile`, `launch_vita_title`, and `launch_vita_sysapp` for Vita
  and PSM content.

These adapters check that an app and game still exist, update recents, then
pass the appropriate argument or title ID to the target application.

## Interface and rendering

There is no separate view folder: UI state, input, menus, and rendering are
all in `src/index.lua`. Cover-model loading begins around line 2606. Drawing
helpers for flat, list, and 3D cover views begin around line 12698; category
drawing begins around line 13685. The main frame loop ends near line 22841.
It uses Lua Player Plus Vita `Screen`, `Graphics`, `Render`, and `Controls`
APIs.

For the XMB work, keep scanner and launcher data unchanged and introduce UI
changes in carefully bounded helpers. Avoid a wholesale rewrite of this file.

## Build and package workflow

This repository contains interpreted Lua source plus prebuilt VPK tools, not a
complete local packaging workflow. The README says RetroFlow runs using a
custom build of Lua Player Plus Vita. Before producing an installable XMBFlow
VPK, locate or document the matching runtime/package project and create a
repeatable, separate packaging procedure. Do not treat the VPKs in `Tools/` as
the XMBFlow application package.

## Fragile or high-risk areas

- Startup code can install a VPK, copy Adrenaline Bubble Booter assets, and
  request a reboot (around lines 4235–4460). Do not alter or trigger this path.
- `AutoMakeBootBin` and the Adrenaline launch path create/delete boot files
  used to launch PSP/PS1 content (around lines 5318–5670).
- Recovery can delete cache/config files and rename the data folder. It is a
  user-invoked recovery path, not a feature to extend (see
  `src/addons/recovery.lua`).
- Several UI menus can delete cached metadata, artwork temporary files, and
  collections. Preserve their confirmation behaviour and do not add new delete
  capabilities.
- `src/index.lua` is over one megabyte and highly coupled. Small changes can
  affect scanning, UI, caching, or launching unexpectedly.
