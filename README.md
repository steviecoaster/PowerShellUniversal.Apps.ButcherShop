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
2. Import the module (from repo root):

```powershell
Import-Module .\src\ButcherShop\ButcherShop.psd1 -Force
# or import the app module
Import-Module .\src\PowerShellUniversal.Apps.ButcherShop\PowerShellUniversal.Apps.Butchershop.psm1 -Force
```

3. Initialize the database:

```powershell
Initialize-Database -DatabasePath .\src\ButcherShop\data\Pester.db
```

Running tests

- Integration tests live under `src\ButcherShop\tests` and use Pester. From `src\ButcherShop` run:

```powershell
Invoke-Pester -Script .\tests\Integration.CoreWorkflow.Tests.ps1 -Verbose
```

Notes / Troubleshooting

- The test bootstrap sets a dedicated test DB so tests run in isolation.
- If you see a sqlite parse error about a ````sql```` fence, the schema file contains Markdown fences — the initializer strips these but check the schema file if you hit parsing errors.
- If you see a `ValidateSet` error for species (`All/Beef/Hog`), that usually means an empty string was passed; callers now normalize empty/`All` to $null before calling functions that validate species.

Contributing

- Please open issues or PRs. Run tests locally and include a short description of changes.

License

- See repository metadata for licensing information.

---
Generated README — concise developer notes for getting started and testing.
