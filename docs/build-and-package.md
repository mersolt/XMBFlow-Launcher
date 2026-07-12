# Build and package status

## Current answer

XMBFlow cannot yet be packaged reproducibly from this repository alone. This
checkout contains the Lua application source, translations, lookup databases,
and documentation, but it does not contain a complete Vita application tree or
the custom Lua runtime binary that executes the source.

This document records what is known and sets a safe path to a future package.
It does **not** add a build script, create a VPK, install anything, or change a
PS Vita.

## What we know

RetroFlow uses [jimbob4000/lpp-vita](https://github.com/jimbob4000/lpp-vita),
a custom fork of Lua Player Plus Vita, as its Vita runtime. Its `Makefile`
builds the runtime executables `eboot_unsafe.bin` and `eboot_safe.bin` with
VitaSDK. The runtime repository says that it needs VitaSDK plus several Vita
libraries, including LuaJIT, vita2d, image/audio libraries, and copyicons.

`src/index.lua` expects these items to be present inside the installed Vita
application:

- the main Lua script and the `addons` and `translations` folders;
- a `DATA` folder containing images, models, fonts, sounds, and other assets;
- a `payloads` folder used by existing RetroFlow helper-launcher logic;
- a Vita application manifest folder named `sce_sys`;
- the executable runtime that provides the `System`, `Graphics`, `Render`,
  `Screen`, and `Controls` functions.

The current XMBFlow checkout does not include `DATA`, `payloads`, `sce_sys`,
or the runtime executable. Therefore, attempting to create a VPK now would
produce an incomplete application or require copying unknown files from another
package. We will not do that.

## Licensing boundary

XMBFlow's current source licence is MIT. The identified Lua Player Plus Vita
runtime repository is GPL-3.0. Combining a runtime binary and application into
a distributed VPK may have licence consequences. Before any runtime is copied,
built, bundled, or released, we must record its exact upstream revision and
confirm the resulting distribution complies with both projects' licences and
all required notices. This is a release gate, not a step to skip.

Likewise, every bundled asset must have known permission to redistribute. Do
not copy Sony assets or extract files from a Vita. Original or properly
licensed replacement assets are required.

## Safe packaging plan

### Gate 1: recover the original package recipe

Before building, find a trusted, documented source for the original RetroFlow
application layout and the exact runtime revision used by the release being
used as the baseline. Record:

- runtime repository URL, commit ID, licence, and build flags;
- application title ID and `sce_sys` metadata source;
- a manifest of every non-source file required at runtime, with licence and
  origin;
- whether any payload is optional, required, or must remain excluded from
  XMBFlow;
- the original package command and tool versions.

Do not use a release VPK as a source of unreviewed assets or runtime files.
If a component cannot be traced to a source and licence, leave it out and mark
it as a blocker.

### Gate 2: make desktop builds repeatable

Once Gate 1 is complete, set up a separate, documented VitaSDK environment.
The runtime's upstream README lists the required toolchain and libraries. Keep
that environment outside this source checkout where possible, and pin the
versions used. A future build script must:

1. build the reviewed runtime from its pinned source;
2. assemble a temporary application tree from a written manifest;
3. validate that tree before packaging;
4. create a VPK only from that temporary tree;
5. never copy files to a Vita or enable AutoBoot.

The script must refuse to run if the manifest, licence record, `sce_sys`,
runtime executable, or required original assets are missing.

### Gate 3: static package validation

Before any hardware test, validate the generated VPK on the PC:

- inspect its file list and compare it with the written manifest;
- confirm the Lua entry script, runtime executable, `sce_sys`, and only the
  reviewed application assets are present;
- search the package list for Sony-derived assets and unexpected payloads;
- verify no cache, ROM, artwork library, personal data, token, or local Vita
  path was accidentally packaged;
- record the source commit, runtime commit, manifest version, and checksums.

This verifies package contents. It cannot prove that the Vita application will
start; only a controlled hardware test can do that.

### Gate 4: controlled hardware test (later, with your approval)

You are the hardware tester. When a reviewed test package exists and you give
explicit approval, the first test must be manual and reversible:

1. use a backed-up or disposable Vita setup;
2. note the XMBFlow source commit and package checksum;
3. install only the test VPK manually;
4. launch it normally from LiveArea; do not enable AutoBoot;
5. test startup and exit before testing scanning or launching;
6. report the visible result, error text, and a screenshot or log if one is
   available;
7. use the existing Recovery Tools only if startup fails.

Do not test changes that alter helper-package installation, Adrenaline files,
system files, reboot handling, or content deletion. Those areas remain out of
scope.

## What Codex can do versus what needs you

| Work | Who does it | Notes |
| --- | --- | --- |
| Source review, documentation, UI changes, static file checks, and commits | Codex | Performed in the local repository on `dev`. |
| Find and review public upstream source/licence information | Codex | Read-only research; no assets are copied. |
| Install a VPK, operate a Vita, inspect LiveArea, and report actual behaviour | You | Only after a specific test package and explicit approval. |
| Provide screenshots, error text, logs, runtime source, or licence proof when requested | You | These let Codex diagnose a hardware result safely. |

## Immediate next task

The next safe development task is not packaging. It is a small, disabled-by-
default XMB renderer prototype that draws from the existing library data but
does not change scanning, caching, launching, file operations, or settings.
It can be reviewed statically while Gate 1 is being completed.
