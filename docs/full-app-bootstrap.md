# Full-app bootstrap asset profile

## Status: blocked by source and licence evidence

`packaging/full-app-data-manifest.json` is a one-to-one manifest seed for all
DATA paths named by the Lua source. A missing field means unknown, not
implicitly permitted. Original project placeholders generated in
`assets/bootstrap-placeholders/` are recorded with their hashes and
`LicenseRef-XMBFlow-Original`; this traces their provenance but does not make
the full manifest package-ready.

## Smallest normal-start profile

The normal English/default configuration reaches the integrated XMB renderer
only after `src/index.lua` has already loaded 23 DATA files:

- the loading image, click sound, default font, and Cross/Circle/Triangle/
  Square indicators;
- default background, floor, footer gradient, Wi-Fi/battery, favourite/hidden,
  and cartridge images;
- `noimg.png` fallback artwork; and
- `planebg.obj` and `planefloor.obj`, which the legacy frame renderer loads
  before the XMB overlay draws.

The three Noto CJK fonts are conditional boot requirements when a saved
language selects Korean, Simplified Chinese, or Traditional Chinese. The other
151 tracked assets are deferred, lazy, or view-dependent; excluding them does
not prove they may be omitted from a later full-feature package.

The current placeholder generator supplies 21 of the 23 default boot files:
19 original PNGs and the two original plane models. The remaining default
inputs are the font and click sound, both deliberately unresolved pending
separate source and licence records.

## Package gate

Before a full-app VPK may be created, every manifest entry must receive its
source location and immutable revision, copyright/licence record, SHA-256,
and any transformation record. This applies equally to a smallest test build:
the 23 boot files cannot be substituted with extracted RetroFlow, Sony, or
Vita content.

Run `Tools/New-XmbFlowFullAppDataManifest.ps1` after inventory changes, then
`Tools/Test-XmbFlowFullAppDataManifest.ps1`. The test deliberately fails a
manifest that appears resolved without the required evidence fields.
