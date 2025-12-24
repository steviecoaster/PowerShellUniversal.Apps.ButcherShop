param(
    [string]$DatabasePath = "..\data\ButcherShop.db",
    [string]$DefaultShop = 'Don'
)

Set-StrictMode -Version Latest

if (-not (Test-Path $DatabasePath)) { throw "Database not found: $DatabasePath" }

Write-Host "Using DB: $DatabasePath`n"

# Import module functions if needed
$modulePath = Join-Path (Split-Path -Parent $PSScriptRoot) -ChildPath '..\ButcherShop.psd1'
if (Test-Path $modulePath) { Import-Module $modulePath -Force }
if (-not (Get-Command Invoke-UniversalSQLiteQuery -ErrorAction SilentlyContinue)) { throw 'Invoke-UniversalSQLiteQuery not available' }

function RunSql([string]$sql) {
    Write-Host "--- Executing SQL ---"
    Write-Host $sql
    try {
        $res = Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query $sql -ErrorAction Stop
        Write-Host "--- Success. Rows returned: $($res.Count) ---"
        if ($res) { $res | Format-Table -AutoSize }
    }
    catch {
        Write-Host "ERROR: $($_.Exception.Message)"
    }
    Write-Host "---------------------`n"
}

RunSql "PRAGMA foreign_keys = OFF;"
RunSql "BEGIN TRANSACTION;"

$create = @"
CREATE TABLE IF NOT EXISTS DailySlots_new (
  SlotDate        TEXT NOT NULL,
  Species         TEXT NOT NULL CHECK (Species IN ('Beef','Hog')),
  Shop            TEXT NOT NULL CHECK (Shop IN ('Don','McConnell')) DEFAULT '$DefaultShop',
  TotalSlots      INTEGER NOT NULL CHECK (TotalSlots >= 0),
  ReservedSlots   INTEGER NOT NULL DEFAULT 0 CHECK (ReservedSlots >= 0),
  PRIMARY KEY (SlotDate, Species, Shop),
  CHECK (ReservedSlots <= TotalSlots)
);
"@

RunSql $create

RunSql "INSERT INTO DailySlots_new (SlotDate, Species, Shop, TotalSlots, ReservedSlots) SELECT SlotDate, Species, '$DefaultShop', TotalSlots, ReservedSlots FROM DailySlots;"

RunSql "DROP VIEW IF EXISTS v_DailyAvailability;"
RunSql "DROP TABLE IF EXISTS DailySlots;"
RunSql "ALTER TABLE DailySlots_new RENAME TO DailySlots;"
RunSql "CREATE INDEX IF NOT EXISTS idx_dailyslots_date ON DailySlots(SlotDate);"

$view = @"
CREATE VIEW IF NOT EXISTS v_DailyAvailability AS
SELECT
  SlotDate,
  Species,
  TotalSlots,
  ReservedSlots,
  (TotalSlots - ReservedSlots) AS AvailableSlots
FROM DailySlots;
"@
RunSql $view

RunSql "COMMIT;"
RunSql "PRAGMA foreign_keys = ON;"

RunSql "PRAGMA table_info('DailySlots');"
