$ErrorActionPreference = 'Stop'

$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$source = Get-Content -Raw (Join-Path $root 'src\xmb-native-installer-probe.c')
$builder = Get-Content -Raw (Join-Path $root 'Tools\build-xmb-native-installer-probe.sh')
$inspector = Get-Content -Raw (Join-Path $root 'Tools\Inspect-VitaSdkToolchain.sh')
$materials = $source + $builder + $inspector

foreach ($forbidden in @(
    'System.installVpk', 'System.reboot', 'System.deleteFile',
    'System.deleteDirectory', 'System.copyFile', 'AutoBoot', 'ux0:', 'ur0:',
    'sceAppMgr', 'sceShellUtil', 'scePromoterUtil'
)) {
    if ($materials.Contains($forbidden)) {
        throw "Installer probe contains forbidden capability text: $forbidden"
    }
}

if ($source -notmatch 'sceKernelDelayThread' -or $source -notmatch 'sceKernelExitProcess') {
    throw 'Installer probe must only wait briefly and then exit.'
}
if ($builder -notmatch 'vita-make-fself" -s') {
    throw 'Installer probe must be built as a safe FSELF.'
}
if ($builder -notmatch 'Inspect-VitaSdkToolchain.sh') {
    throw 'Installer probe must inspect the installed VitaSDK before compiling.'
}
if ($inspector -notmatch 'libSceLibKernel_stub.a') {
    throw 'VitaSDK inspector must validate the exact installer-probe kernel stub.'
}
if ($builder -notmatch 'TITLE_ID=XMBF00002') {
    throw 'Installer probe must retain its distinct test title ID.'
}

Write-Host 'XMB native installer probe profile checks passed.'
