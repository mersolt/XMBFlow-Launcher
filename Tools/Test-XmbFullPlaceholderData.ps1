param(
    [Parameter(Mandatory = $true)][string]$DataDirectory,
    [string]$InventoryPath
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($InventoryPath)) { $InventoryPath = Join-Path $PSScriptRoot '..\packaging\data-asset-inventory.json' }
$inventory = Get-Content -Raw -LiteralPath $InventoryPath | ConvertFrom-Json
$expected = @($inventory.assets.path | ForEach-Object { $_ -replace '^DATA/', '' } | Sort-Object)
$actual = @(Get-ChildItem -LiteralPath $DataDirectory -File | Select-Object -ExpandProperty Name | Sort-Object)
if (($expected -join "`n") -ne ($actual -join "`n")) { throw 'Placeholder DATA file set does not match the source inventory.' }
foreach ($file in Get-ChildItem -LiteralPath $DataDirectory -File) {
    if ($file.Length -eq 0) { throw "Placeholder DATA file is empty: $($file.Name)" }
}
Write-Host "Full placeholder DATA checks passed: $($actual.Count) files."
