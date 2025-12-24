# ButcherShop

PowerShell module + PowerShell Universal app for a small butcher scheduling and cut-sheet workflow.

Quick overview

- Module: `src\ButcherShop` — core functions (orders, slots, cut sheets).
- App: `src\PowerShellUniversal.Apps.ButcherShop` — dashboards and pages (calendar, booking, etc.).
- DB schema: `src\PowerShellUniversal.Apps.ButcherShop\data\Database-Schema.sql` and `src\ButcherShop\data\Schema.sql` (used by tests).

Requirements

- PowerShell 7.x
- `sqlite3` CLI available on PATH
- (Optional) PowerShell Universal to run the dashboards

Quick start

1. Install sqlite3 and ensure it's on PATH.
1. Import the module (from repo root):

```powershell
Import-Module .\src\ButcherShop\ButcherShop.psd1 -Force
# or import the app module
Import-Module .\src\PowerShellUniversal.Apps.ButcherShop\PowerShellUniversal.Apps.Butchershop.psm1 -Force
```

1. Initialize the database:

```powershell
Initialize-Database -DatabasePath .\src\ButcherShop\data\Pester.db
```

Running tests

Integration tests live under `src\ButcherShop\tests` and use Pester. From `src\ButcherShop` run:

```powershell
Invoke-Pester -Script .\tests\Integration.CoreWorkflow.Tests.ps1 -Verbose
```

ButcherShop is a PowerShell project that provides:

- A core PowerShell module that manages orders, scheduling slots, and cut-sheet constructors (src/ButcherShop).
- A PowerShell Universal app that renders dashboards and pages (calendar, booking UI, cut-sheet steppers) for interactive use (src/PowerShellUniversal.Apps.ButcherShop).

This repository contains the code and database schema used to run and test a small butcher shop workflow: creating orders, scheduling slots, and filling cut-sheets for beef and hogs.

## Main features

- Order creation and scheduling (calendar + slots)
- Dynamic cut-sheet constructors and save/load for Don and McConnell shops (beef and hog variants)
- UniversalDashboard / PowerShell Universal pages that render stepper-style cut-sheet UIs
- SQLite-based persistence with helper functions and SQL helpers

## Quick start (developer)

Prerequisites

- PowerShell 7.x (pwsh)
- sqlite3 available on PATH (used by the DB initializer and tests)
- Optional: PowerShell Universal or Universal Server to host the dashboards

Clone and import the module

From the repo root in a PowerShell prompt:

```powershell
# Import the core module (exports functions used by the app)
Import-Module .\src\ButcherShop\ButcherShop.psd1 -Force

# Import the app module (UD pages / show-* functions)
Import-Module .\src\PowerShellUniversal.Apps.ButcherShop\PowerShellUniversal.Apps.Butchershop.psd1 -Force
```

Initialize a local development database (creates SQLite DB and tables):

```powershell
Initialize-Database -DatabasePath .\src\ButcherShop\data\dev.db
```

Run the dashboards (PowerShell Universal)

- If you have PowerShell Universal: point the dashboard to the `src\PowerShellUniversal.Apps.ButcherShop` folder or import the module in your UD startup script and mount pages.

## File layout

- src/ButcherShop
  - functions/public — constructors and persistence helpers (New-*, Save-*, Get-*)
  - data — SQL schema files
  - tests — Pester tests (integration and unit)
- src/PowerShellUniversal.Apps.ButcherShop
  - functions/public — Show-* pages rendered by the app (UD steppers and pages)
  - dashboards — dashboard page definitions and sample pages

## Important development notes

- Cut-sheet constructors historically reused a single storage schema. Some constructors were refactored to use pork-specific shapes. Check the constructor and save functions before changing schema names.
- The dynamic step builder `Build-CutOrderStepper` generates UD step blocks from constructor metadata and is used by Show-* pages. Use `-ReturnStrings` for debugging its output.
- UD Select options are emitted as scriptblocks with explicit string Values to avoid runspace coercion issues between the app runspace and the module.

## Testing

- Integration and unit tests use Pester. Run tests from the `src/ButcherShop` directory. Example:

```powershell
Push-Location src\ButcherShop
Invoke-Pester -Script .\tests\Integration.CoreWorkflow.Tests.ps1 -Verbose
Pop-Location
```

## Common troubleshooting

- Duplicate-hash-key parse errors in Show-* files usually mean there is a literal hashtable with duplicate keys. Prefer programmatic [ordered]@{} splats or check for accidental pasted blocks.
- If UD step controls show type conversion issues (select values becoming arrays or being typed incorrectly), inspect the builder output and ensure `New-UDSelectOption -Value ([string] '...')` is used.

## Next steps and suggestions

- Sweep Show-* pages to ensure UI labels are consistent (pork vs beef) and mapping back to constructors is explicit.
- Add a migration helper if you plan to consolidate beef/pork schema names in the DB.
- Add more Pester tests for edge cases in the dynamic step builder and Save/Load paths.

## Contact / Contribution

Open issues or PRs on GitHub. Include short descriptions and test updates.

---
Small, self-contained PowerShell app and module for a butcher's scheduling and cut-sheet workflow.
