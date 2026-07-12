# XMBFlow Launcher

## Charter

XMBFlow Launcher is a safe, polished, PSP XMB-inspired PS Vita launcher. It is
forked from RetroFlow and keeps RetroFlow's useful library features while its
interface evolves.

## Goals

- Keep launching support for Vita, PSP, PS1, PSM, ROMs, and the existing
  emulator adapters.
- Preserve search, collections, favourites, recently played, artwork, cache,
  and recovery features.
- Build an original PSP XMB-inspired interface; do not copy Sony assets.
- Make changes easy to test, review, and undo.

## Safety rules

- Work only on `dev`; never modify `main`.
- Do not enable AutoBoot.
- Do not add destructive file, database, or content-management features.
- Do not install, copy to, reboot, or otherwise change a PS Vita during normal
  development. Device testing requires an explicit later decision.
- Do not add or distribute extracted Sony fonts, icons, sounds, or other
  proprietary assets.
- Keep the MIT licence and existing credits with all distributed source.
- Make small, single-purpose, reversible commits.

## Milestones

1. Document the existing RetroFlow code and safety boundaries.
2. Separate or clearly identify UI state and rendering without changing
   library scanning or launching.
3. Prototype the XMB navigation and presentation using original assets.
4. Integrate it while retaining all current library and launch behaviour.
5. Test on a disposable or backed-up Vita setup only after explicit approval.
