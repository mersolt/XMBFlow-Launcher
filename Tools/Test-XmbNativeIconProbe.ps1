$ErrorActionPreference = 'Stop'

$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$source = Get-Content -Raw (Join-Path $root 'src\xmb-native-installer-probe.c')
$builder = Get-Content -Raw (Join-Path $root 'Tools\build-xmb-native-icon-probe.sh')

foreach ($forbidden in @(
    'System.installVpk', 'System.reboot', 'System.deleteFile',
    'System.deleteDirectory', 'System.copyFile', 'AutoBoot', 'ux0:', 'ur0:',
    'sceAppMgr', 'sceShellUtil', 'scePromoterUtil'
)) {
    if (($source + $builder).Contains($forbidden)) {
        throw "Native icon probe contains forbidden capability text: $forbidden"
    }
}
if ($builder -notmatch 'vita-make-fself" -s' -or $builder -notmatch 'TITLE_ID=XMBF00003') {
    throw 'Native icon probe must be a safe FSELF with its distinct test title ID.'
}
foreach ($unexpected in @('livearea/contents/bg.png', 'livearea/contents/startup.png', 'livearea/contents/template.xml')) {
    if ($builder.Contains($unexpected)) { throw "Native icon probe must omit LiveArea content: $unexpected" }
}

Write-Host 'XMB native icon-only probe profile checks passed.'
