# Inspect-DbSchema.ps1
param(
    [string]$DatabasePath = "./data/Pester.db"
)

Set-StrictMode -Version Latest

if (-not (Test-Path $DatabasePath)) { Write-Host "DB not found: $DatabasePath"; exit 2 }

# Ensure module functions are available
if (-not (Get-Command Invoke-UniversalSQLiteQuery -ErrorAction SilentlyContinue)) {
    $modulePath = Join-Path (Split-Path -Parent $PSScriptRoot) -ChildPath '..\ButcherShop.psd1'
    $modulePath = (Resolve-Path $modulePath).ProviderPath
    if (Test-Path $modulePath) { Import-Module $modulePath -Force }
}

if (-not (Get-Command Invoke-UniversalSQLiteQuery -ErrorAction SilentlyContinue)) {
    Write-Host "Could not import module functions. Exiting."; exit 3
}

Write-Host "Inspecting table: DailySlots in $DatabasePath`n"
$rows = Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "PRAGMA table_info('DailySlots');"
if (-not $rows) { Write-Host "No rows returned from PRAGMA table_info('DailySlots')"; exit 4 }

$rows | Format-Table -AutoSize

# Also show entire schema for DailySlots
Write-Host "`nFull CREATE TABLE statement (if found):`n"
$create = Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "SELECT sql FROM sqlite_master WHERE type='table' AND name='DailySlots';" | Select-Object -First 1
$create | Format-List

return $rows
