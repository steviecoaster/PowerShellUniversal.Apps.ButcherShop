function New-UDButcherShopApp {
    [CmdletBinding()]
    Param()
    <#
    .SYNOPSIS
    Creates a new Butcher Shop app.

    .DESCRIPTION
    Creates a new Butcher Shop app for PowerShell Universal.
    #>

    try {
        # Get the module root from the module base
        $Module = Get-Module -Name 'PowerShellUniversal.Apps.ButcherShop'
        if (-not $Module) {
            throw "PowerShellUniversal.Apps.ButcherShop module is not loaded"
        }
        
        $ModuleRoot = $Module.ModuleBase
        Write-Verbose "Module root: $ModuleRoot"
        
        # Load all page scripts
        $DashboardPath = Join-Path $ModuleRoot -ChildPath 'dashboards\ButcherShop'
        $PagesPath = Join-Path $DashboardPath -ChildPath 'pages'
        
        Write-Verbose "Loading pages from: $PagesPath"
        Get-ChildItem $PagesPath -Recurse -Filter *.ps1 | ForEach-Object {
            Write-Verbose "Loading page: $($_.FullName)"
            . $_.FullName
        }

        # Execute the main app script and return the app
        $AppScript = Join-Path $DashboardPath 'ButcherShop.ps1'
        Write-Verbose "Executing app script: $AppScript"
        
        if (-not (Test-Path $AppScript)) {
            throw "App script not found at: $AppScript"
        }
        
        & $AppScript
    }
    catch {
        Write-Error "Failed to create Herd Manager app: $_"
        throw
    }
}