param(
    [Parameter(Mandatory = $true)][string]$Vpk,
    [Parameter(Mandatory = $true)][string]$DataDirectory
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$expected = @('eboot.bin', 'index.lua', 'LICENSE', 'sce_sys/icon0.png', 'sce_sys/param.sfo')
$expected += Get-ChildItem -LiteralPath $DataDirectory -File | ForEach-Object { "DATA/$($_.Name)" }
$zip = [IO.Compression.ZipFile]::OpenRead($Vpk)
try {
    $actual = @($zip.Entries | Where-Object { -not $_.FullName.EndsWith('/') } | ForEach-Object FullName | Sort-Object)
    if (($actual -join "`n") -ne (($expected | Sort-Object) -join "`n")) { throw 'VPK file set differs from the full-placeholder read-only profile.' }
    $reader = [IO.StreamReader]::new($zip.GetEntry('index.lua').Open())
    try { $entry = $reader.ReadToEnd() } finally { $reader.Dispose() }
    foreach ($forbidden in @('ux0:', 'ur0:', 'vs0:', 'System.installVpk', 'System.reboot', 'System.deleteFile', 'System.deleteDirectory', 'System.copyFile', 'dofile(', 'loadfile(')) {
        if ($entry.Contains($forbidden)) { throw "Read-only VPK entry contains forbidden text: $forbidden" }
    }
} finally { $zip.Dispose() }
Write-Host "Full-placeholder read-only VPK checks passed: $((Get-FileHash -LiteralPath $Vpk -Algorithm SHA256).Hash.ToLowerInvariant())"
