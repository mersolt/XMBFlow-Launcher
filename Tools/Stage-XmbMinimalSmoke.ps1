[CmdletBinding()]
param(
    [string]$RuntimePath = (Join-Path $env:TEMP 'xmbflow-runtime-safe\eboot.bin'),
    [string]$RuntimeManifest,
    [string]$SceSysRoot = (Join-Path $env:TEMP 'xmbflow-scesys-standard\sce_sys'),
    [string]$SceSysManifest,
    [string]$OutputDirectory = (Join-Path $env:TEMP 'xmbflow-minimal-stage-standard')
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($RuntimeManifest)) {
    $RuntimeManifest = Join-Path $PSScriptRoot '..\packaging\candidate-runtime-safe-manifest.json'
}
if ([string]::IsNullOrWhiteSpace($SceSysManifest)) {
    $SceSysManifest = Join-Path $PSScriptRoot '..\packaging\candidate-sce_sys-standard-manifest.json'
}

if (Test-Path -LiteralPath $OutputDirectory) {
    throw "Refusing to overwrite an existing staging directory: $OutputDirectory"
}
foreach ($path in @($RuntimePath, $SceSysRoot)) {
    if (-not (Test-Path -LiteralPath $path)) { throw "Required candidate input is missing: $path" }
}

& (Join-Path $PSScriptRoot 'Test-XmbMinimalProfile.ps1')

$runtime = Get-Content -Raw $RuntimeManifest | ConvertFrom-Json
$actualRuntimeHash = (Get-FileHash -LiteralPath $RuntimePath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($actualRuntimeHash -ne $runtime.output.sha256) {
    throw "Runtime SHA-256 does not match recorded candidate: $actualRuntimeHash"
}

$sceManifest = Get-Content -Raw $SceSysManifest | ConvertFrom-Json
foreach ($item in $sceManifest.files) {
    $source = Join-Path $SceSysRoot ($item.path.Substring('sce_sys/'.Length).Replace('/', '\'))
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Missing sce_sys candidate file: $($item.path)" }
    $actual = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -ne $item.sha256) { throw "sce_sys SHA-256 mismatch: $($item.path)" }
}

$root = Resolve-Path (Join-Path $PSScriptRoot '..')
New-Item -ItemType Directory -Path $OutputDirectory | Out-Null
Copy-Item -LiteralPath $RuntimePath -Destination (Join-Path $OutputDirectory 'eboot.bin')
Copy-Item -LiteralPath (Join-Path $root 'src\xmb-test.lua') -Destination (Join-Path $OutputDirectory 'index.lua')
Copy-Item -LiteralPath (Join-Path $root 'LICENSE') -Destination (Join-Path $OutputDirectory 'LICENSE')
Copy-Item -LiteralPath $SceSysRoot -Destination (Join-Path $OutputDirectory 'sce_sys') -Recurse

$stagedFiles = Get-ChildItem -LiteralPath $OutputDirectory -Recurse -File | ForEach-Object {
    [ordered]@{
        path = $_.FullName.Substring($OutputDirectory.Length + 1).Replace('\', '/')
        sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        bytes = $_.Length
    }
}
$expectedPaths = @('LICENSE', 'eboot.bin', 'index.lua') + @($sceManifest.files.path)
$actualPathSet = @($stagedFiles.path | Sort-Object) -join "`n"
$expectedPathSet = @($expectedPaths | Sort-Object) -join "`n"
if ($actualPathSet -ne $expectedPathSet) {
    throw 'Staged tree contains an unexpected file set.'
}

[ordered]@{
    schema = 1
    status = 'candidate-tree-only'
    purpose = 'PC-only XMBFlow visual smoke-test staging evidence; not a VPK and not authorised for Vita installation.'
    source_revision = (git -C $root rev-parse HEAD).Trim()
    files = @($stagedFiles)
    exclusions = @('DATA/**', 'addons/**', 'translations/**', 'payloads/**', 'boot.bin', 'boot.inf', '*.vpk', 'src/index.lua')
} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $OutputDirectory 'xmbflow-stage-manifest.json') -Encoding UTF8

Write-Host "Created candidate XMB smoke-test tree: $OutputDirectory"
