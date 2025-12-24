param(
    [string]$DatabasePath = "./data/ButcherShop.db",
    [ValidateSet('Don','McConnell')][string]$DefaultShop = 'Don'
)

Set-StrictMode -Version Latest

if (-not (Test-Path $DatabasePath)) { throw "Database not found: $DatabasePath" }

$backup = "$DatabasePath.bak.$((Get-Date).ToString('yyyyMMddHHmmss'))"
Copy-Item -Path $DatabasePath -Destination $backup -Force
Write-Host "Backed up $DatabasePath -> $backup"

# Ensure module functions available
if (-not (Get-Command Invoke-UniversalSQLiteQuery -ErrorAction SilentlyContinue)) {
    $modulePath = Join-Path (Split-Path -Parent $PSScriptRoot) -ChildPath '..\ButcherShop.psd1'
    if (Test-Path $modulePath) { Import-Module $modulePath -Force }
}
if (-not (Get-Command Invoke-UniversalSQLiteQuery -ErrorAction SilentlyContinue)) {
    throw "Could not import module functions. Ensure you run this from the project where the module is available."
}

# Build migration SQL: create new table, copy data, swap names
$migration = @"
PRAGMA foreign_keys = OFF;
BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS DailySlots_new (
  SlotDate        TEXT NOT NULL,
  Species         TEXT NOT NULL CHECK (Species IN ('Beef','Hog')),
  Shop            TEXT NOT NULL CHECK (Shop IN ('Don','McConnell')) DEFAULT '$DefaultShop',
  TotalSlots      INTEGER NOT NULL CHECK (TotalSlots >= 0),
  ReservedSlots   INTEGER NOT NULL DEFAULT 0 CHECK (ReservedSlots >= 0),
  PRIMARY KEY (SlotDate, Species, Shop),
  CHECK (ReservedSlots <= TotalSlots)
);

INSERT INTO DailySlots_new (SlotDate, Species, Shop, TotalSlots, ReservedSlots)
SELECT SlotDate, Species, '$DefaultShop', TotalSlots, ReservedSlots FROM DailySlots;

-- Drop any views that reference DailySlots before swapping the tables
DROP VIEW IF EXISTS v_DailyAvailability;

DROP TABLE IF EXISTS DailySlots;
ALTER TABLE DailySlots_new RENAME TO DailySlots;

CREATE INDEX IF NOT EXISTS idx_dailyslots_date ON DailySlots(SlotDate);

CREATE VIEW IF NOT EXISTS v_DailyAvailability AS
SELECT
  SlotDate,
  Species,
  TotalSlots,
  ReservedSlots,
  (TotalSlots - ReservedSlots) AS AvailableSlots
FROM DailySlots;

COMMIT;
PRAGMA foreign_keys = ON;
"@

Write-Host "Running migration SQL against: $DatabasePath"
Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query $migration | Out-Null
Write-Host "Migration complete. Verifying schema..."

# Show new schema
Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "PRAGMA table_info('DailySlots');" | Format-Table -AutoSize

Write-Host "Done."
