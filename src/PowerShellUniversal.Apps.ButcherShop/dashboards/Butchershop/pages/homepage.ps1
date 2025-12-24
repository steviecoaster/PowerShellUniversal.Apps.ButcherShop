$homepage = New-UDPage -Name 'Home' -Url '/Home' -Content {
    
    New-UDCard -Style @{
        backgroundColor = '#2e7d32'
        color           = 'white'
        padding         = '40px'
        marginBottom    = '30px'
        borderRadius    = '8px'
        backgroundImage = 'linear-gradient(135deg, #2e7d32 0%, #66bb6a 100%)'
        boxShadow       = '0 4px 6px rgba(0,0,0,0.1)'
    } -Content {
        New-UDGrid -Container -Content {
            New-UDGrid -Item -ExtraSmallSize 12 -Content {

                New-UDTypography -Text '🐂 Custom Meat Ordering' -Variant h2 -Style @{
                    fontWeight   = 'bold'
                    textAlign    = 'center'
                    marginBottom = '15px'
                }

                New-UDTypography -Text 'Since 2013' -Variant h5 -Style @{
                    textAlign    = 'center'
                    opacity      = '0.9'
                    marginBottom = '10px'
                }

                New-UDTypography -Text "We raise 'em, you eat 'em" -Variant body1 -Style @{
                    textAlign = 'center'
                    opacity   = '0.85'
                }
            }
        }
    }

    New-UDGrid -Container -Spacing 3 -Content {

        New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -LargeSize 4 -content {
            New-UDCard -Content {
                New-UDElement -Tag 'div' -Content {
                    New-UDTypography 'New Slot Booking' -Variant h5 -Style @{
                        color        = '#2e7d32'
                        fontWeight   = 'bold'
                        marginBottom = '15px'
                    }

                    New-UDElement -Tag 'br'

                    New-UDElement -tag 'div' -Content {
                        New-UDTypography -Text 'Schedule a new butcher slot' -Variant body1 -Style @{
                            marginBottom = '15px'
                            color        = '#555'
                        }
                    }

                    New-UDButton -Text 'Book Slot' -Variant contained -style @{
                        backgroundColor = '#2e7d32'
                        color           = 'white'
                        width           = '100%'
                    } -OnClick {
                        Invoke-UDRedirect -url '/book'
                    }
                }
            }
        }
    }
}