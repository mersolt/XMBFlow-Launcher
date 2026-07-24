# Safe-profile audit of `src/index.lua`

`XMBFLOW_SAFE_PROFILE=true` is an opt-in package-entry flag. It does not
change normal RetroFlow behavior. When enabled it starts the XMB prototype,
uses existing complete cache tables only, and blocks mutation/helper APIs.

## Disabled in the safe profile

| Area | Existing locations | Safe-profile treatment |
| --- | --- | --- |
| Recovery entry | 8-12 | Does not enter `recovery.lua`, whose tools delete/rename data. |
| Legacy migrations | 57-58, 3539 | Rename calls are blocked; early migrations are skipped. |
| Directory/default setup | 116-136, 1426-1512 | `createDirectory` and `copyFile` are blocked. Existing data is read only. |
| Cache rebuild/startup scan | 11078-11107 | Skipped. Only a complete existing cache is imported; otherwise the library is empty. |
| Artwork downloads | 12283-13645 | `Network.downloadFile` is blocked. |
| Helper install/repair/reboot | 4364-4492, 5374-5702 | `Setup_Adrenaline`, `AutoMakeBootBin`, and `launch_Adrenaline` return immediately; `installVpk`, payload copies/deletes, and reboot are also blocked at the API boundary. |
| Cache, collection, metadata deletes | throughout legacy menus | `deleteFile`, `deleteDirectory`, and `rename` are blocked. |
| Settings writes | `SaveSettings` at 3216 | Returns without writing. |

## Retained

- Existing cached table imports and collection imports.
- XMB rendering and legacy fallback.
- Existing `System.launchApp` and `System.executeUri` launch APIs. Launching
  a game may still use the installed adapter that RetroFlow already uses; it
  does not install helpers or edit AutoBoot in the safe profile.

## Package consequence

The safe profile needs an entry wrapper that sets
`XMBFLOW_SAFE_PROFILE=true` before executing `src/index.lua`, plus the normal
Lua sources/addons, translations, databases, original assets, runtime, and
LiveArea files. It is a separate package profile from both the smoke VPK and
ordinary RetroFlow.
