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
