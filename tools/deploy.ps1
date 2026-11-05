param(
    [string]$WowPath = 'C:\Program Files (x86)\World of Warcraft\_forever_'
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$sourceRoot = (Resolve-Path -LiteralPath (Join-Path $projectRoot 'ForeverXPOptimizer')).Path
$clientRoot = (Resolve-Path -LiteralPath $WowPath).Path
$flavorPath = Join-Path $clientRoot '.flavor.info'
if (-not (Test-Path -LiteralPath (Join-Path $clientRoot 'Wow.exe'))) {
    throw 'Keine WoW-Installation am Ziel.'
}
if (-not (Test-Path -LiteralPath $flavorPath) -or
    -not ((Get-Content -LiteralPath $flavorPath) -contains 'wowf')) {
    throw 'Das Ziel ist kein offizieller Forever-Client (Produkt wowf).'
}

$addonRoot = Join-Path $clientRoot 'Interface\AddOns'
$targetRoot = [IO.Path]::GetFullPath((Join-Path $addonRoot 'ForeverXPOptimizer'))
if (-not $targetRoot.StartsWith($clientRoot + '\', [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Ziel liegt außerhalb des geprüften Clients.'
}
foreach ($candidate in @($clientRoot, (Join-Path $clientRoot 'Interface'), $addonRoot, $targetRoot, (Join-Path $targetRoot 'Locales'))) {
    if ((Test-Path -LiteralPath $candidate) -and
        ((Get-Item -LiteralPath $candidate).Attributes -band [IO.FileAttributes]::ReparsePoint)) {
        throw "Verknüpfter Zielordner wird nicht automatisch beschrieben: $candidate"
    }
}

$distRoot = Join-Path $projectRoot 'dist'
New-Item -ItemType Directory -Path $distRoot -Force | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$files = @('ForeverXPOptimizer.toc', 'Locale.lua', 'Data.lua', 'Model.lua', 'Client.lua', 'UI.lua', 'README.md', 'Icon.tga')
$files += @(Get-ChildItem -LiteralPath (Join-Path $sourceRoot 'Locales') -Filter '*.lua' -File |
    Sort-Object Name | ForEach-Object { 'Locales\' + $_.Name })
$versionLine = Get-Content -LiteralPath (Join-Path $sourceRoot 'ForeverXPOptimizer.toc') |
    Where-Object { $_ -match '^## Version: ([0-9]+\.[0-9]+\.[0-9]+)$' } | Select-Object -First 1
if (-not $versionLine) { throw 'Keine gültige Addon-Version in der TOC.' }
$version = ($versionLine -split ': ', 2)[1]
foreach ($file in $files) {
    if (-not (Test-Path -LiteralPath (Join-Path $sourceRoot $file))) { throw "Quelldatei fehlt: $file" }
}
$backupRoot = $null
if (Test-Path -LiteralPath $targetRoot) {
    $backupRoot = Join-Path $distRoot "backups\$stamp\ForeverXPOptimizer"
    New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
    foreach ($file in $files) {
        $existing = Join-Path $targetRoot $file
        if (Test-Path -LiteralPath $existing) {
            if ((Get-Item -LiteralPath $existing).Attributes -band [IO.FileAttributes]::ReparsePoint) {
                throw "Verknüpfte Zieldatei wird nicht überschrieben: $existing"
            }
            $backupFile = Join-Path $backupRoot $file
            New-Item -ItemType Directory -Path (Split-Path -Parent $backupFile) -Force | Out-Null
            Copy-Item -LiteralPath $existing -Destination $backupFile
        }
    }
}

$archive = Join-Path $distRoot "ForeverXPOptimizer-$version.zip"
Compress-Archive -LiteralPath $sourceRoot -DestinationPath $archive -Force
New-Item -ItemType Directory -Path $targetRoot -Force | Out-Null
$manifest = foreach ($file in $files) {
    $source = Join-Path $sourceRoot $file
    $target = Join-Path $targetRoot $file
    New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
    Copy-Item -LiteralPath $source -Destination $target -Force
    $sourceHash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
    $targetHash = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash
    if ($sourceHash -ne $targetHash) { throw "Prüfsummenabweichung: $file" }
    [pscustomobject]@{ file = $file; sha256 = $targetHash }
}
$report = [ordered]@{
    version = $version
    installedAt = (Get-Date).ToUniversalTime().ToString('o')
    product = 'wowf'
    target = $targetRoot
    archive = $archive
    backup = $backupRoot
    files = @($manifest)
}
$report | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $distRoot 'deployment.json') -Encoding UTF8
Write-Output "Installiert: $targetRoot"
Write-Output "ZIP: $archive"
Write-Output "Verifiziert: $(@($manifest).Count) Dateien, SHA-256 identisch."
