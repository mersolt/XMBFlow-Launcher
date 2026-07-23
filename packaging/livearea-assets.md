# XMBFlow LiveArea visual assets

The XMBFlow prototype uses an original, XMB-inspired blue wave background. It
is a project-specific image, generated on 2026-07-23 with the built-in image
generation tool from this development environment. It contains no text,
logo, Sony asset, extracted Vita content, or third-party image input.

`Tools/New-XmbFlowLiveAreaAssets.ps1` is the reproducible transformation step.
Given the reviewed source image it creates only:

- `sce_sys/icon0.png` (a separate, code-drawn XMBFlow mark);
- `sce_sys/livearea/contents/bg.png` (840 by 500);
- `sce_sys/livearea/contents/startup.png` (280 by 158); and
- `sce_sys/livearea/contents/template.xml`.

These are package inputs only after their SHA-256 values appear in the
approved manifest. The script does not create a VPK, write to a Vita, enable
AutoBoot, install a helper, reboot anything, or copy content to a Vita path.
