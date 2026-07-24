param([Parameter(Mandatory = $true)][string]$Vpk)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $Vpk -PathType Leaf)) { throw "VPK not found: $Vpk" }
Add-Type -AssemblyName System.IO.Compression.FileSystem
$expected = @('eboot.bin', 'index.lua', 'LICENSE', 'sce_sys/icon0.png', 'sce_sys/param.sfo', 'DATA/xmb-icon-settings.png', 'DATA/xmb-icon-photo.png', 'DATA/xmb-icon-music.png', 'DATA/xmb-icon-video.png', 'DATA/xmb-icon-games.png', 'DATA/xmb-icon-network.png', 'DATA/xmb-icon-apps.png', 'DATA/xmb-setting-sound.png', 'DATA/xmb-setting-network.png', 'DATA/xmb-setting-display.png', 'DATA/xmb-setting-system.png', 'DATA/xmb-setting-time.png', 'DATA/xmb-object-photoviewer.png', 'DATA/xmb-object-trophy.png', 'DATA/xmb-cursor.ogg', 'DATA/font-SawarabiGothic-Regular.ttf', 'THIRD-PARTY-NOTICES/SawarabiGothic-OFL.txt')
$zip = [IO.Compression.ZipFile]::OpenRead($Vpk)
try {
    $actual = @($zip.Entries | Where-Object { -not $_.FullName.EndsWith('/') } | ForEach-Object FullName | Sort-Object)
    if (($actual -join "`n") -ne (($expected | Sort-Object) -join "`n")) { throw 'VPK file set differs from the icon-only smoke profile.' }
    $index = [IO.StreamReader]::new($zip.GetEntry('index.lua').Open())
    try { $text = $index.ReadToEnd() } finally { $index.Dispose() }
    foreach ($forbidden in @('ux0:', 'ur0:', 'vs0:', 'System.installVpk', 'System.reboot', 'System.deleteFile', 'System.deleteDirectory', 'System.copyFile', 'dofile(', 'loadfile(')) {
        if ($text.Contains($forbidden)) { throw "VPK entry script contains forbidden text: $forbidden" }
    }
    foreach ($requiredSoundCall in @('Sound.init()', 'Sound.open("app0:/DATA/xmb-cursor.ogg")', 'Sound.play(navigation_click, NO_LOOP)', 'Sound.close(navigation_click)')) {
        if (-not $text.Contains($requiredSoundCall)) { throw "VPK entry script is missing reviewed navigation sound call: $requiredSoundCall" }
    }
}
finally { $zip.Dispose() }

Write-Host "XMB minimal icon-only VPK checks passed: $((Get-FileHash -LiteralPath $Vpk -Algorithm SHA256).Hash.ToLowerInvariant())"
