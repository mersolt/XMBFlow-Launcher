param([string]$Manifest = (Join-Path $PSScriptRoot '..\packaging\package-inputs.json'))

$data = Get-Content -Raw $Manifest | ConvertFrom-Json
$missing = @($data.inputs | Where-Object { $_.status -ne 'approved' })
if ($missing.Count -gt 0) {
    $names = ($missing.path -join ', ')
    throw "Packaging is blocked: unapproved required inputs: $names"
}

foreach ($item in $data.inputs) {
    if ([string]::IsNullOrWhiteSpace($item.source) -or [string]::IsNullOrWhiteSpace($item.license)) {
        throw "Packaging is blocked: $($item.path) lacks source or licence provenance."
    }
}

Write-Host 'Package inputs are approved for a future staging step.'
