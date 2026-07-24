$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$probe = Get-Content -Raw (Join-Path $root 'src\xmb-lua-runtime-probe.lua')
$builder = Get-Content -Raw (Join-Path $root 'Tools\new-xmb-lua-runtime-probe-vpk.sh')
foreach ($forbidden in @('app0:', 'ux0:', 'ur0:', 'vs0:', 'System.installVpk', 'System.reboot', 'System.deleteFile', 'System.deleteDirectory', 'System.copyFile', 'AutoBoot', 'Graphics.', 'Controls.', 'Sound.')) {
    if (($probe + $builder).Contains($forbidden)) { throw "Lua runtime probe contains forbidden capability text: $forbidden" }
}
$executable = (($probe -split "`r?`n" | Where-Object { -not $_.TrimStart().StartsWith('--') }) -join "`n").Trim()
if ($executable -ne 'System.exit()') { throw 'Lua runtime probe must only exit.' }
if ($builder -notmatch 'TITLE_ID=XMBF00005') { throw 'Lua runtime probe must retain its distinct test title ID.' }
Write-Host 'XMB Lua runtime probe profile checks passed.'
