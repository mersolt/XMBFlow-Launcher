param([Parameter(Mandatory = $true)][string]$Vpk)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $Vpk -PathType Leaf)) { throw "VPK not found: $Vpk" }
Add-Type -AssemblyName System.IO.Compression.FileSystem
$expected = @('eboot.bin', 'index.lua', 'LICENSE', 'sce_sys/icon0.png', 'sce_sys/param.sfo')
$zip = [IO.Compression.ZipFile]::OpenRead($Vpk)
try {
    $actual = @($zip.Entries | Where-Object { -not $_.FullName.EndsWith('/') } | ForEach-Object FullName | Sort-Object)
    if (($actual -join "`n") -ne (($expected | Sort-Object) -join "`n")) { throw 'VPK file set differs from the icon-only smoke profile.' }
    $index = [IO.StreamReader]::new($zip.GetEntry('index.lua').Open())
    try { $text = $index.ReadToEnd() } finally { $index.Dispose() }
    foreach ($forbidden in @('app0:', 'ux0:', 'ur0:', 'vs0:', 'System.installVpk', 'System.reboot', 'System.deleteFile', 'System.deleteDirectory', 'System.copyFile', 'dofile(', 'loadfile(', 'Sound.', 'Graphics.loadImage', 'Font.')) {
        if ($text.Contains($forbidden)) { throw "VPK entry script contains forbidden text: $forbidden" }
    }
}
finally { $zip.Dispose() }

Write-Host "XMB minimal icon-only VPK checks passed: $((Get-FileHash -LiteralPath $Vpk -Algorithm SHA256).Hash.ToLowerInvariant())"
