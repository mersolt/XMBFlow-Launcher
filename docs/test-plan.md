# Safe test and recovery plan

This first phase is documentation only. Do not install anything on a Vita or
change Vita files while following the desktop checks below.

## Before every change

1. Confirm you are on `dev`, not `main`.
2. Check which files have changed. If you see files you did not expect, stop
   and ask before continuing.
3. Make one focused change only. Keep a short note of what should remain the
   same (for example: scanning and launching).

## Desktop checks (safe now)

1. Review the changed-file list. For a documentation task, it should contain
   only the requested Markdown files.
2. Review the actual differences line by line. Check that no Lua, VPK,
   database, or media file changed by accident.
3. Search new text for `AutoBoot`, Sony asset names, installation actions, and
   delete/reboot commands. A safety document may mention them as restrictions;
   it must not instruct code to enable or run them.
4. Commit only after those checks pass. Keep the commit small and descriptive.

For the original LiveArea visuals, run the following with a per-process script
policy bypass if Windows blocks local scripts; it does not change the machine
policy and writes its check output only to the PC temporary directory:

`powershell -NoProfile -ExecutionPolicy Bypass -File Tools/Test-XmbFlowLiveAreaAssets.ps1`

## Future XMB prototype test-package profile (PC-only)

This is a design gate, not authorisation to build a VPK. It applies only after
`docs/package-recipe.md` is complete and its reproducibility gates pass.

The package must be a distinct, clearly labelled XMB prototype build. It may
set `xmbPrototypeEnabled` to `true`, but it must retain the legacy RetroFlow
renderer and make the legacy renderer the immediate fallback when that flag is
false. The prototype remains presentation-only: selecting a game is a no-op,
and the non-Games columns remain inert.

Before that integrated prototype can start, a smaller package smoke test may
stage `src/xmb-test.lua` as the package entry script. It is a separate,
presentation-only script: it uses no `DATA` assets, scans nothing, reads no
Vita paths, and has no launch, install, reboot, delete, copy, or AutoBoot
capability. Run `Tools/Test-XmbMinimalProfile.ps1` before considering it for a
package tree. This does not alter the normal `src/index.lua` entry point.

`packaging/minimal-smoke-inputs.json` is a separate manifest for that smoke
test. It deliberately excludes `DATA`, the normal RetroFlow entry script,
addons, translations, payloads, boot files, and VPKs. Its own gate is
`Tools/Test-XmbMinimalSmokeInputs.ps1`; it remains closed until the runtime and
`sce_sys` candidates are formally approved.

For PC-only assembly evidence, `Tools/Stage-XmbMinimalSmoke.ps1` may create a
candidate tree from the recorded runtime and `sce_sys` hashes. It refuses a
mismatched input, an unexpected file set, or an existing output directory. It
does not create a VPK and is not authorisation to install or test on a Vita.

When explicitly authorised, `Tools/new-xmb-minimal-smoke-vpk.sh` creates a
local candidate VPK from that verified staging tree. It checks the recorded
runtime hash, refuses overwrite, and packages only the minimal entry script,
licence, and original `sce_sys` files. It contains no Vita installation or
transfer command.

Run `Tools/Test-XmbMinimalSmokeVpk.ps1` against the resulting archive before
any Vita-side decision. It verifies the exact archive file set and rejects a
minimal entry script containing Vita paths, legacy loading, installer, reboot,
copy, or delete calls.

The test manifest must include only the reviewed runtime, Lua source,
translations, lookup databases, original/licensed `DATA` assets, original
`sce_sys` assets, licence notices, and the minimal files proven necessary to
start the app. It must exclude all of the following:

- `payloads/**`, helper-launcher VPKs, Adrenaline Bubble Booter files, and any
  helper-installation material;
- AutoBoot configuration or boot files;
- personal caches, ROMs, artwork libraries, saved settings, logs, secrets,
  Vita system/app files, and Sony-derived assets.

Before creating a VPK, run these PC-only checks against both the staged tree
and the eventual archive file list:

1. Compare every file and SHA-256 against the approved manifest; reject extras
   and omissions.
2. Reject paths or content referring to helper installation, `System.installVpk`,
   `System.reboot`, AutoBoot, `System.deleteFile`, `System.deleteDirectory`, or
   writes/copies into Vita system or application locations. An allowlist may
   describe existing legacy source only when the test build has demonstrably
   removed or made those paths unreachable; it cannot waive the exclusion.
3. Confirm `payloads/`, `boot.bin`, `boot.inf`, and helper VPK names are absent.
4. Confirm `sce_sys` and every asset has a manifest source and licence entry;
   reject Sony/Vita-extracted material.
5. Record the XMBFlow source revision, runtime revision, tool versions,
   manifest revision, archive SHA-256, and check results.

If a safe test variant cannot remove those capabilities without changing legacy
RetroFlow behaviour, stop at static review. Do not weaken the profile by
including the legacy helper or destructive paths.

## Later: Vita test procedure (only after explicit approval)

Never use your only working setup as the first tester. Back up VitaShell-accessible
data and note the current RetroFlow version/configuration first. Do not enable
AutoBoot.

1. Install a test build only when a packaging process has been reviewed.
2. Start it normally from LiveArea. Confirm it opens and can be closed.
3. Check navigation, search, categories, favourites, recents, collections,
   artwork, and each display view.
4. Test a single known-good entry for every supported launch route available on
   the test Vita: Vita, PSP, PS1, PSM, and each installed emulator adapter.
5. Rescan once and confirm the expected library, artwork, favourites, and
   recents still appear.
6. Record what happened, including anything that did not work. Do not attempt
   repair operations until the result is understood.

## If the app fails to start

Use the existing Recovery Tools from the Vita LiveArea, in this order:

1. **Delete Cache** — removes rebuildable cached titles/databases.
2. **Reset Configuration** — returns settings to their defaults.
3. **Full Reset** — last resort only. It renames the RetroFlow data folder; it
   does not intentionally remove ROMs or artwork, but restoring files may take
   manual work.

After each step, launch the app again and stop once it works. If the problem
began after an XMBFlow change, preserve the failing build and note the exact
commit before making another change.
