$calendar = New-UDPage -Name "Scheduling Calendar" -Url '/calendar' -Content {
    $Session:monthNumber = @{
        January   = 1
        February  = 2
        March     = 3
        April     = 4
        May       = 5
        June      = 6
        July      = 7
        August    = 8
        September = 9
        October   = 10
        November  = 11
        December  = 12
    }
    New-UDStyle -Style ' 
    /* Ensure the calendar fills the page without creating a page scrollbar */
    .butcher-calendar {
        height: calc(100vh - 120px);
        max-height: calc(100vh - 120px);
        overflow: hidden;
        display: flex;
        flex-direction: column;
    }
    /* FullCalendar root element should fill its parent */
    .butcher-calendar .fc {
        flex: 1 1 auto;
        height: 100% !important;
        overflow: auto;
    }
    /* Make day grid scroll if needed but keep it inside the calendar area */
    .butcher-calendar .fc-daygrid-body {
        overflow: auto;
    }' -Content {

        New-UDCard -Style @{ 
            padding      = '14px 16px'
            borderRadius = '12px'
            boxShadow    = '0 8px 24px rgba(0,0,0,0.08)'
            margin       = '0 auto 12px'
            width        = '100%'
            maxWidth     = '720px'
        } -Content {

            New-UDStack -Direction column -Spacing 2 -Children {
                New-UDSelect -Id 'month' -DefaultValue 'January' -Option {
                    $months = @('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December')
                    @($months) | ForEach-Object {
                        New-UDSelectOption -Name $_ -Value $_
                    }
                } -Label 'Month'

                New-UDSelect -Id 'year' -DefaultValue '2025' -Option {
                    '2025'..'2035' | ForEach-Object {
                        New-UDSelectOption -Name $_ -Value $_
                    }
                }

                New-UDSelect -Id 'shop' -DefaultValue 'McConnell' -Option {
                    @('Don', 'McConnell') | ForEach-Object { 
                        New-UDSelectOption -Name $_ -Value $_
                    }
                } -Label 'Shop'

                New-UDButton -Text 'See Orders' -OnClick {
                    Sync-UDElement -Id 'calendar'
                }
            }
        }

        New-UDDynamic -Id 'calendar' -Content {
            $Session:Shop = (Get-UDElement -Id 'shop').Value
            $Session:Month = (Get-UDElement -Id 'month').Value
            $session:Year = (Get-UDElement -Id 'year').Value

            # compute month number safely from mapping; fall back to current date when session values are missing
            $now = Get-Date
            $year = if ($session:Year -and [int]::TryParse($session:Year, [ref]0)) { [int]$session:Year } else { $now.Year }

            $monthNumberValue = $null
            if ($Session:Month) {
                try {
                    if ($Session:monthNumber.ContainsKey($Session:Month)) { $monthNumberValue = $Session:monthNumber[$Session:Month] }
                }
                catch {
                    $monthNumberValue = $null
                }
            }

            if (-not $monthNumberValue) { $monthNumberValue = $now.Month }

            $shopFilter = if ($Session:Shop -and $Session:Shop -ne '') { $Session:Shop } else { $null }
            $orders = Get-OrdersByMonth -Year $year -Month $monthNumberValue -Shop $shopFilter

            $events = $orders | Where-Object { $_.SlotDate } | ForEach-Object {
                @{
                    id     = $_.OrderId
                    title  = "Order #$($_.OrderId) - $($_.Species) - $($_.FirstName) $($_.LastName)"
                    start  = $_.SlotDate
                    allDay = $true
                }
            }

            New-UDCard -Class 'butcher-calendar' -Style @{ 
                padding       = '10px'
                borderRadius  = '12px'
                boxShadow     = '0 12px 36px rgba(0,0,0,0.06)'
                width         = '100%'
                maxWidth      = '1400px'
                margin        = '0 auto'
                display       = 'flex'
                flex          = '1 1 auto'   # allow card to expand vertically
                minHeight     = '0'          # important to let flex children shrink properly
                flexDirection = 'column'
            } -Content {

                New-UDElement -Tag 'div' -Attributes @{ 
                    style = @{ 
                        display       = 'flex'
                        flex          = '1 1 auto'
                        minHeight     = '0'
                        height        = '100%'
                        width         = '100%'
                        flexDirection = 'column'
                    } 
                } -Content {
                    # inner full-width container to make calendar expand horizontally
                    New-UDElement -Tag 'div' -Attributes @{ 
                        style = @{ 
                            display   = 'flex'
                            flex      = '1 1 auto'
                            width     = '100%'
                            minHeight = '0' 
                        } 
                    } -Content {
                        # Make calendar expand to fill its container
                   
                        # compute initial date for calendar safely
                        $initialMonth = if ($Session:Month -and $Session:monthNumber.ContainsKey($Session:Month)) { $Session:monthNumber[$Session:Month] } else { (Get-Date).Month }
                        $initialYear = if ($session:Year -and [int]::TryParse($session:Year, [ref]0)) { [int]$session:Year } else { (Get-Date).Year }
                        $initialDate = Get-Date -Month $initialMonth -Year $initialYear -Day 1
                        New-UDCalendar -InitialDate $initialDate -Events $events -HeaderToolbar @{}
                    }
                }
            }
        }
    
        
    }
}