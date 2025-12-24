$app = @{
    Name = 'ButcherShop'
    BaseUrl = '/butchershop'
    Module = 'PowerShellUniversal.Apps.ButcherShop'
    Command = 'New-UDButcherShopApp'
    AutoDeploy = $true
    Description = 'A custom beef order scheduling tool'
    Environment = 'PowerShell 7'
}

New-PSUApp @app