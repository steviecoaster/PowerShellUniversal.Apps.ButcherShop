[CmdletBinding()]
Param()

end {
    $navigation = New-UDList -Content {
        New-UDListItem -Label 'Home' -Icon (New-UDIcon -Icon Home) -OnClick { Invoke-UDRedirect -Url '/Home' }
        New-UDListItem -Label 'Book Slot' -Icon (New-UDIcon -Icon Calendar) -OnClick { Invoke-UDRedirect -Url '/book' }
        New-UDListItem -Label 'Calendar' -Icon (New-UDIcon -Icon Calendar) -OnClick { Invoke-UDRedirect -Url '/calendar' }
        New-UDListItem -Label 'Cut Order' -OnClick { Invoke-UDRedirect -Url '/cutorder' }
    }

    $app = @{
        Title = 'Butcher Shop'
        Pages = @($homepage,$book,$calendar,$cutorder)
        Navigation = $navigation
        NavigationLayout = 'Temporary'
    }

    New-UDApp @app
}