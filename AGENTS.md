# Working rules for coding agents

Read `PROJECT.md`, `docs/architecture.md`, and `docs/test-plan.md` before
changing code.

## Required boundaries

- Commit only on `dev`; never check out, merge into, or edit `main`.
- Preserve RetroFlow behaviour unless the task specifically says to change it.
- Do not enable AutoBoot or add code that enables it.
- Do not add destructive operations. In particular, do not broaden uses of
  `System.deleteFile`, `System.deleteDirectory`, `System.installVpk`,
  `System.copyFile` to Vita system/app locations, or `System.reboot`.
- Do not perform Vita installation, configuration, file transfer, or testing
  without the user's explicit approval for that separate action.
- Never add extracted Sony assets. Use original, properly licensed assets only.
- Retain the MIT licence, upstream attributions, and copyright notices.

## How to work

- Inspect the relevant code before editing it. `src/index.lua` is large and
  tightly coupled; avoid unrelated formatting or broad rewrites.
- Make one small purpose-built change at a time. Do not mix UI, scan, cache,
  and launch-adapter changes in one commit.
- Explain changes in plain English and name user-visible risks.
- Run the checks in `docs/test-plan.md` that are possible without a Vita.
- Review `git diff` and `git status` before committing. Do not include
  generated caches, VPKs, proprietary content, secrets, or unrelated files.
- Use descriptive, conventional commit messages. Ask before pushing.

## Task completion handoff

When a task's stated outcome is genuinely complete, say so clearly and propose
finishing the current task tab. Include a concise copyable prompt for the next
task tab, with its objective and any safety boundaries. Do not treat an
unfinished, blocked, or merely partially tested task as complete.
