$ErrorActionPreference = 'Stop'

$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$source = Get-Content -Raw (Join-Path $root 'src\xmb-native-installer-probe.c')
$builder = Get-Content -Raw (Join-Path $root 'Tools\build-xmb-native-installer-probe.sh')

foreach ($forbidden in @(
    'System.installVpk', 'System.reboot', 'System.deleteFile',
    'System.deleteDirectory', 'System.copyFile', 'AutoBoot', 'ux0:', 'ur0:',
    'sceAppMgr', 'sceShellUtil', 'scePromoterUtil'
)) {
    if ($source.Contains($forbidden) -or $builder.Contains($forbidden)) {
        throw "Installer probe contains forbidden capability text: $forbidden"
    }
}

if ($source -notmatch 'sceKernelDelayThread' -or $source -notmatch 'sceKernelExitProcess') {
    throw 'Installer probe must only wait briefly and then exit.'
}
if ($builder -notmatch 'vita-make-fself -s') {
    throw 'Installer probe must be built as a safe FSELF.'
}
if ($builder -notmatch 'TITLE_ID=XMBF00002') {
    throw 'Installer probe must retain its distinct test title ID.'
}

Write-Host 'XMB native installer probe profile checks passed.'
