# RetroFlow package recipe evidence record

## Status: not yet reproducible

This record covers the RetroFlow **v8.1.1 source baseline** used by this
checkout (`a02cb507af687fb8b385e63942f925841e3cea3f`, tagged `v8.1.1`). It is
evidence, not a permission to build or distribute a VPK.

The upstream source tag contains only Lua source, lookup databases,
translations, documentation, and media for the repository page. It contains
no executable, `sce_sys`, `DATA`, payload, or package recipe. Consequently the
exact release package cannot be reconstructed from tracked source, and no
unreviewed release VPK or extracted Vita file may be used to fill the gap.

## Runtime evidence

RetroFlow's v8.1.1 README identifies
[`jimbob4000/lpp-vita`](https://github.com/jimbob4000/lpp-vita) as its custom
Lua Player Plus Vita runtime. The currently tagged upstream candidate is:

| Field | Recorded value | Confidence |
| --- | --- | --- |
| Repository | `https://github.com/jimbob4000/lpp-vita.git` | Direct upstream source |
| Candidate revision | `f797059c9f1403d417d81351e26303d1702577d6` (`v1.1`) | Direct upstream source |
| Licence | GPL-3.0-only text in `LICENSE.txt` | Direct upstream source |
| Produced files | `eboot_unsafe.bin` and `eboot_safe.bin`; a system-mode unsafe binary is also supported | Direct upstream Makefile |
| Compatibility with RetroFlow v8.1.1 | **Unproven** | No RetroFlow release build record pins a runtime commit or flags |

Do not substitute this candidate for the runtime used in the v8.1.1 release.
Obtain a maintainer-provided build record, or an independently auditable source
commit-to-package attestation, before marking the runtime compatible.

The candidate Makefile requires VitaSDK's `arm-vita-eabi` toolchain and links
against the following build inputs: `copyicons`, curl, OpenSSL, zlib, Ogg,
Vorbis, libsndfile, vita2d, libjpeg-turbo, FreeType, libpng, SpeexDSP, mpg123,
imagequant, opusfile, FLAC, Opus, LuaJIT 2.1, libdl, bzip2, and the Vita SDK
stub libraries named in that Makefile. Its documented setup also lists
libftpvita. Record the exact VitaSDK, vita-portlibs, EasyRPG Vita toolchain,
and each dependency revision/licence before a build; the upstream list is not
a lockfile.

## Required package layout and provenance gate

`src/index.lua` requires an app tree with at least these logical components.
The table deliberately records an unknown as unknown rather than assigning a
source by inference.

| Package item | Expected purpose | Provenance / licence record | Release status |
| --- | --- | --- | --- |
| `eboot.bin` | Lua Player Plus Vita executable | Candidate source above is GPL-3.0-only, but the v8.1.1 revision and build flags are unproven | Blocked |
| `index.lua` | Application entry script | This repository at the source commit above; MIT `LICENSE` retained | Traceable |
| `addons/*.lua`, `addons/*.db` | Helpers and built-in lookup data | This repository at the source commit above; verify original authorship/redistribution for each database before release | Needs per-file licence review |
| `translations/*.lua` | UI translations | This repository at the source commit above; retain contributor attributions from the README history | Needs attribution manifest |
| `DATA/**` | Fonts, images, models, sounds and wallpapers referenced at `app0:` | Absent from the source tag and this checkout | Blocked |
| `sce_sys/**` | Vita metadata and LiveArea assets, including `param.sfo` | Absent from the source tag and this checkout | Blocked |
| `payloads/**` | Legacy Adrenaline helper setup files | Absent from the source tag and this checkout; excluded from the XMB test profile | Must not be included |

The exact `sce_sys` title ID, `param.sfo` fields, LiveArea files, and their
licences are therefore **not recovered**. A new XMBFlow manifest must use an
original title ID and only newly created or explicitly licensed metadata and
LiveArea assets. It must never copy `sce_sys` from a commercial title, a Vita,
or an untraceable VPK.

## Licence and source record required before distribution

For every packaged file, create a machine-readable manifest entry with:

1. package path and SHA-256;
2. source repository or original-asset location and immutable revision;
3. author/copyright notice and SPDX licence identifier (or written permission
   reference);
4. transformation/build command, if generated;
5. included licence and attribution file; and
6. reviewer and review date.

The runtime's GPL-3.0-only licence and XMBFlow's MIT licence must be reviewed
as a combined distribution before release. This document does not provide a
legal compatibility determination. The complete corresponding source and all
required notices must be made available if a GPL-covered runtime is conveyed.

## Reproducibility gates

No VPK may be built or distributed until all conditions below are true:

1. The baseline runtime commit, exact build flags, toolchain versions, and
   output checksums are traced to auditable source.
2. A complete file-by-file manifest resolves every `DATA` and `sce_sys` input
   to original or properly licensed source material.
3. All database, translation, runtime, and asset notices have been reviewed
   and included.
4. A PC-only assembly procedure can create the tree from those pinned inputs
   in a fresh temporary directory and reproduce the recorded file manifest.
5. The test profile below passes its static safety checks.

Until then, documentation and source review are the only approved package work.
