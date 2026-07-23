param([string]$Vpk = (Join-Path $env:TEMP 'XMBFlow-minimal-smoke.vpk'))

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $Vpk -PathType Leaf)) { throw "VPK not found: $Vpk" }

Add-Type -AssemblyName System.IO.Compression.FileSystem
$expected = @(
    'eboot.bin', 'index.lua', 'LICENSE', 'sce_sys/icon0.png', 'sce_sys/param.sfo',
    'sce_sys/livearea/contents/bg.png', 'sce_sys/livearea/contents/startup.png',
    'sce_sys/livearea/contents/template.xml'
)

$zip = [System.IO.Compression.ZipFile]::OpenRead($Vpk)
try {
    $entries = @($zip.Entries | ForEach-Object { $_.FullName })
    $actualSet = @($entries | Sort-Object) -join "`n"
    $expectedSet = @($expected | Sort-Object) -join "`n"
    if ($actualSet -ne $expectedSet) { throw 'VPK file set differs from the minimal smoke profile.' }

    $index = $zip.GetEntry('index.lua')
    $reader = [IO.StreamReader]::new($index.Open())
    try { $indexText = $reader.ReadToEnd() } finally { $reader.Dispose() }
    foreach ($forbidden in @(
        'app0:', 'ux0:', 'ur0:', 'vs0:', 'System.installVpk', 'System.reboot',
        'System.deleteFile', 'System.deleteDirectory', 'System.copyFile',
        'dofile(', 'loadfile(', 'Sound.', 'Graphics.loadImage', 'Font.'
    )) {
        if ($indexText.Contains($forbidden)) { throw "VPK entry script contains forbidden text: $forbidden" }
    }
}
finally {
    $zip.Dispose()
}

$hash = (Get-FileHash -LiteralPath $Vpk -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "XMB minimal smoke VPK checks passed: $hash"
