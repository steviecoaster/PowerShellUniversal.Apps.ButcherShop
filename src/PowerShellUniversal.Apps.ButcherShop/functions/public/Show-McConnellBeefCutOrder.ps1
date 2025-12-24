function Show-McConnellBeefCutOrder {
    <#
.SYNOPSIS
Render a McConnell beef cut order input UI (UniversalDashboard components) and submit to Save-DonBeefCutOrder.
#>
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$OrderId
    )

    $Session:OrderInfo = Get-Order -OrderId $OrderId


    $style = @"
.butcher-stepper-wrapper {
    display: flex;
    justify-content: center;
}

.butcher-stepper-card {
    width: 100%;
    max-width: 720px;
}

.butcher-stepper-card.psu-stepper-card {
    border-radius: 14px;
    box-shadow: 0 8px 24px rgba(0,0,0,0.10);
}

.butcher-stepper-card .ud-card-body {
    padding: 20px 22px;
}
"@

    New-UDStyle -Style $style -Content {

        New-UDElement -Tag 'div' -ClassName 'butcher-stepper-wrapper' -Content {

            New-UDCard -ClassName 'butcher-stepper-card psu-stepper-card' -Title "McConnell's Farm Market Beef Cut Order" -Content {

                New-UDStepper -Id 'cutorder-stepper' -Steps {
                    # Dynamically build steps from constructor parameters
                    $steps = Build-CutOrderStepper -ConstructorName 'New-McConnellBeefCutOrder'

                    foreach ($s in $steps) { & $s }
                } -OnFinish {}

            }
        }
    }
}
