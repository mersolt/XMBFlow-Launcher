param([string]$Sfo = (Join-Path $env:TEMP 'xmbflow-scesys-standard\sce_sys\param.sfo'))

$ErrorActionPreference = 'Stop'
$metadata = Get-Content -Raw (Join-Path $PSScriptRoot '..\packaging\metadata.json') | ConvertFrom-Json
$bytes = [IO.File]::ReadAllBytes($Sfo)
if ($bytes.Length -lt 20 -or [Text.Encoding]::ASCII.GetString($bytes, 1, 3) -ne 'PSF') { throw "Not a param.sfo file: $Sfo" }

function Read-U16([int]$offset) { [BitConverter]::ToUInt16($bytes, $offset) }
function Read-U32([int]$offset) { [BitConverter]::ToUInt32($bytes, $offset) }

$keyTable = Read-U32 8
$dataTable = Read-U32 12
$count = Read-U32 16
$values = @{}
for ($index = 0; $index -lt $count; $index++) {
    $entry = 20 + (16 * $index)
    $keyOffset = Read-U16 $entry
    $format = Read-U16 ($entry + 2)
    $dataOffset = Read-U32 ($entry + 12)
    $keyBytes = [Collections.Generic.List[byte]]::new()
    for ($cursor = $keyTable + $keyOffset; $bytes[$cursor] -ne 0; $cursor++) { $keyBytes.Add($bytes[$cursor]) }
    $key = [Text.Encoding]::ASCII.GetString($keyBytes.ToArray())
    if ($format -eq 0x0404) { $values[$key] = Read-U32 ($dataTable + $dataOffset) }
    else { $values[$key] = [Text.Encoding]::UTF8.GetString($bytes, $dataTable + $dataOffset, (Read-U32 ($entry + 4))).TrimEnd([char]0) }
}

if ($values['ATTRIBUTE'] -ne 0) { throw "param.sfo requests extended permissions (ATTRIBUTE=$($values['ATTRIBUTE']))." }
if ($values['CATEGORY'] -ne 'gd') { throw "Unexpected CATEGORY: $($values['CATEGORY'])" }
if ($values['TITLE_ID'] -ne $metadata.title_id) { throw "Unexpected TITLE_ID: $($values['TITLE_ID'])" }
Write-Host 'XMBFlow param.sfo checks passed (standard permissions).'
