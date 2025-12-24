# Stop PSU
Stop-Service PowerShellUniversal

# Copy ButcherShop app
$ButcherShopApp = Join-Path $PSScriptRoot -Childpath 'src' 'PowerShellUniversal.Apps.ButcherShop' -Verbose
$ButcherShopModule = Join-Path $PSScriptRoot -ChildPath 'src' 'ButcherShop'
$ModuleDestination = Join-Path $env:ProgramFiles -ChildPath 'PowerShell' 'Modules'
$AppDestination = Join-Path $Env:ProgramData -ChildPath 'UniversalAutomation' 'Repository' 'Modules' -Verbose

Copy-Item $ButcherShopApp -Recurse -Destination $AppDestination -Force
Copy-Item $ButcherShopModule -Recurse -Destination $ModuleDestination -Force

Start-Service PowerShellUniversal
Clear-Host