$book = New-UDPage -Name 'Book Slot' -Url '/book' -Content {
$Session:StepperFinished = $false
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

        New-UDGrid -Container -Spacing 4 -Content {

            # LEFT: Intro / context
            New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 5 -Content {

                New-UDTypography -Variant h3 -Text 'Book a Butcher Appointment' -Style @{
                    fontWeight   = 600
                    marginBottom = '12px'
                }

                New-UDTypography -Variant body1 -Text 'Use this form to schedule an appointment, select the type of animal, and choose an available processing date.' -Style @{
                    opacity    = 0.85
                    lineHeight = '1.7'
                }

                New-UDTypography -Variant caption -Text 'This usually takes just a couple of minutes.' -Style @{
                    marginTop = '10px'
                    opacity   = 0.7
                }

                New-UDElement -Tag 'div' -Attributes @{
                    style = @{
                        height = '18px'
                    }
                }


                New-UDElement -Tag 'div' -Id 'stepper-wrapper' -ClassName 'butcher-stepper-wrapper' -Content {

                    # Define card params explicitly here so it's obvious where they come from.
                    

                    New-UDDynamic -Id 'stepperdynamic' -Content {
                        $cardParams = @{
                            ClassName = 'butcher-stepper-card psu-stepper-card'
                            Content   = {
                                if ($Session:StepperFinished) {
                                    New-UDCard -Style @{ padding = '14px'; borderRadius = '10px' } -Content {
                                        New-UDGrid -Container -Spacing 2 -Content {
                                            New-UDGrid -Item -SmallSize 12 -Content {
                                                New-UDTypography -Variant display2 -Text 'Thank you!' -FontWeight bold
                                            }
                                            New-UDGrid -Item -SmallSize 12 -Content {
                                                New-UDAlert -Severity success -Text 'Order received!'
                                            }
                                            New-UDGrid -Item -SmallSize 12 -Content {
                                                # keep the toast for quick debug/confirmation as well
                                                Show-UDToast -Message ($Session:BookingContext | ConvertTo-Json)
                                            }
                                        }
                                    }
                                }
                                else {
                                    New-UDStepper -Steps {

                                        # Step 1 - Customer Info
                                        New-UDStep -Id 'customer' -Label 'Customer Information' -OnLoad {
                                            New-UDGrid -Container -Spacing 2 -Content {

                                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                                    $firstNameParams = @{
                                                        Id          = 'firstName'
                                                        Label       = 'First name'
                                                        Type        = 'text'
                                                        Placeholder = 'Jane'
                                                    }
                                                    New-UDTextbox @firstNameParams
                                                }

                                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                                    $lastNameParams = @{
                                                        Id          = 'lastName'
                                                        Label       = 'Last name'
                                                        Type        = 'text'
                                                        Placeholder = 'Doe'
                                                    }
                                                    New-UDTextbox @lastNameParams
                                                }

                                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                                    $phoneParams = @{
                                                        Id          = 'phone'
                                                        Label       = 'Phone'
                                                        Type        = 'text'
                                                        Placeholder = '555-1234'
                                                    }
                                                    New-UDTextbox @phoneParams
                                                }

                                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                                    $emailParams = @{
                                                        Id          = 'email'
                                                        Label       = 'Email'
                                                        Type        = 'email'
                                                        Placeholder = 'jane@example.local'
                                                    }
                                                    New-UDTextbox @emailParams
                                                }

                                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                    $notesParams = @{
                                                        Id        = 'notes'
                                                        Label     = 'Notes'
                                                        Multiline = $true
                                                        Rows      = 4
                                                        RowsMax   = 10
                                                    }
                                                    New-UDTextbox @notesParams
                                                }
                                            }
                                        }

                                        # Step 2 - Animal
                                        New-UDStep -Id 'animal-step' -Label 'Animal Type' -OnLoad {

                                            New-UDCard -Style @{
                                                backgroundColor = '#f5f7fa'
                                                borderRadius    = '10px'
                                                padding         = '14px 16px'
                                                marginBottom    = '16px'
                                                boxShadow       = 'none'
                                                borderLeft      = '4px solid #1976d2'
                                            } -Content {

                                                New-UDTypography -Variant subtitle1 -Text 'Select Animal Type' -Style @{
                                                    fontWeight    = 600
                                                    marginBottom  = '2px'
                                                    letterSpacing = '0.2px'
                                                }

                                                New-UDTypography -Variant caption -Text 'Choose the type of animal being brought in for processing. This helps determine available cutting options and scheduling.' -Style @{
                                                    opacity    = 0.85
                                                    lineHeight = '1.6'
                                                }

                                                New-UDElement -Tag 'br'

                                                New-UDTypography -Variant caption -Text "Select Shop Don for Don's Custom Meat. Select McConnell for McConnell's Farm Market" -Style @{
                                                    opacity    = 0.85
                                                    lineHeight = '1.6'
                                                }
                                            }

                                            New-UDStack -Direction row -Spacing 1 -Children {
                                                # Animal selector
                                                $animalParams = @{
                                                    Id           = 'animal'
                                                    Label        = 'Animal'
                                                    Option       = {
                                                        New-UDSelectOption -Name 'Beef' -Value 'Beef'
                                                        New-UDSelectOption -Name 'Hog'  -Value 'Hog'
                                                    }
                                                    DefaultValue = 'Beef'
                                                }

                                                New-UDSelect @animalParams

                                                # Shop selector (Don / McConnell)
                                                $shopParams = @{ 
                                                    Id           = 'shop'
                                                    Label        = 'Shop'
                                                    Option       = {
                                                        New-UDSelectOption -Name 'Don' -Value 'Don'
                                                        New-UDSelectOption -Name 'McConnell' -Value 'McConnell'
                                                    }
                                                    DefaultValue = 'Don'
                                                }

                                                New-UDSelect @shopParams

                                                # Portion selector (Whole / Half)
                                                $portionParams = @{
                                                    Id           = 'portion'
                                                    Label        = 'Portion'
                                                    Option       = {
                                                        New-UDSelectOption -Name 'Whole' -Value 'Whole'
                                                        New-UDSelectOption -Name 'Half'  -Value 'Half'
                                                    }
                                                    DefaultValue = 'Whole'
                                                }

                                                New-UDSelect @portionParams
                                            }
                                    
                                        }

                                        # Step 3 - Slot
                                        New-UDStep -Id 'slots' -Label 'Choose Date' -OnLoad {

                                            New-UDCard -Style @{
                                                backgroundColor = '#f5f7fa'
                                                borderRadius    = '10px'
                                                padding         = '14px 16px'
                                                marginBottom    = '16px'
                                                boxShadow       = 'none'
                                                borderLeft      = '4px solid #2e7d32'
                                            } -Content {

                                                New-UDTypography -Variant subtitle1 -Text 'Select an Available Butcher Slot' -Style @{
                                                    fontWeight    = 600
                                                    marginBottom  = '2px'
                                                    letterSpacing = '0.2px'
                                                }

                                                New-UDTypography -Variant caption -Text 'Pick a date with available capacity for this animal. Only dates with open slots are shown.' -Style @{
                                                    opacity    = 0.85
                                                    lineHeight = '1.6'
                                                }
                                            }

                                            $slotParams = @{
                                                Id     = 'chosen-slot'
                                                Label  = 'Slot'
                                                Option = {
                                                    $year = (Get-Date).Year

                                                    # Determine selected type and portion from stepper elements or EventData
                                                    $type = $null
                                                    if ($EventData -and $EventData.Context -and $EventData.Context.animal) {
                                                        $type = $EventData.Context.animal
                                                    }
                                                    if ([string]::IsNullOrWhiteSpace($type)) {
                                                        try { $type = (Get-UDElement -Id 'animal').value } catch { $type = '' }
                                                    }

                                                    $portion = $null
                                                    try { $portion = (Get-UDElement -Id 'portion').value } catch { $portion = $null }
                                                    if (-not $portion) { $portion = $EventData.Context.portion }

                                                    # Determine selected shop
                                                    $shop = $null
                                                    try { $shop = (Get-UDElement -Id 'shop').value } catch { $shop = $EventData.Context.shop }
                                                    if (-not $shop) { $shop = 'Don' }

                                                    # Map portion to required units
                                                    switch ($portion) {
                                                        'Whole' { $req = 4 }
                                                        'Half'  { $req = 2 }
                                                        default { $req = 0 }
                                                    }

                                                    # Query available slots for the year and type; then filter by portion units when applicable
                                                    $available = Get-AvailableSlot -YearOnly $year -Type $type -Shop $shop
                                                    $available | Where-Object {
                                                        # If no portion selected, show all
                                                        if ($req -eq 0) { return $true }
                                                        # Ensure there are enough portion-units available
                                                        return ([int]$_.AvailablePortionUnits -ge $req)
                                                    } | ForEach-Object {
                                                        $label = "{0} — {1} portions ({2} animals) available — {3}" -f ((Get-Date $_.SlotDate).ToLongDateString()), $_.AvailablePortionUnits, $_.AvailableAnimals, $_.Shop
                                                        New-UDSelectOption -Name $label -Value $_.SlotDate
                                                    }
                                                }
                                            }

                                            New-UDSelect @slotParams
                                        }

                                        # Step 4 - Place Order (review)
                                        New-UDStep -Id 'place-order' -Label 'Place Order' -OnLoad {
                                            # Render a review card directly from the stepper's EventData.Context
                                            New-UDElement -Tag 'div' -Content {
                                                # Safely read context values (may be null if user navigated here directly)
                                                $ctx = $EventData.Context
                                                if (-not $ctx) {
                                                    New-UDCard -Content {
                                                        New-UDTypography -Variant h6 -Text 'No booking data available' -Style @{ color = '#666' }
                                                        New-UDTypography -Text 'Please complete the previous steps to review your booking.' -Style @{ opacity = 0.8 }
                                                    }
                                                    return
                                                }

                                                $first = $ctx.firstName
                                                $last = $ctx.lastName
                                                $phone = $ctx.phone
                                                $email = $ctx.email
                                                $notes = $ctx.notes
                                                $animal = $ctx.animal
                                                $portion = $ctx.portion
                                                $shop = $ctx.shop
                                                $slotVal = $ctx.'chosen-slot'

                                                # Normalize slot display
                                                $slotText = if ($slotVal -and ($slotVal -is [string])) {
                                                    try { ([DateTime]::Parse($slotVal)).ToShortDateString() } catch { $slotVal }
                                                }
                                                else { $slotVal }

                                                New-UDCard -Style @{ padding = '18px'; borderRadius = '10px' } -Content {
                                                    New-UDGrid -Container -Spacing 2 -Content {
                                                        New-UDGrid -Item -SmallSize 12 -Content {
                                                            New-UDTypography -Variant h5 -Text 'Review your booking' -Style @{ marginBottom = '6px'; fontWeight = 700 }
                                                            New-UDTypography -Variant caption -Text 'Please confirm the details below before finishing.' -Style @{ opacity = 0.7 }
                                                        }

                                                        # Two-column summary
                                                        New-UDGrid -Container -Spacing 2 -Content {
                                                            New-UDGrid -Item -SmallSize 6 -Content {
                                                                New-UDTypography -Variant subtitle2 -Text 'Customer' -Style @{ fontWeight = 700; marginBottom = '6px' }
                                                                New-UDTypography -Text ("{0} {1}" -f $first, $last) -Style @{ marginBottom = '6px' }
                                                                New-UDElement -Tag 'br'
                                                                if ($phone) {
                                                                    New-UDTypography -Text ("Phone: {0}" -f $phone) -Style @{ color = '#666'; marginBottom = '4px' } 
                                                                }

                                                                if ($email) { 
                                                                    New-UDElement -Tag 'br'
                                                                    New-UDTypography -Text ("Email: {0}" -f $email) -Style @{ color = '#666'; marginBottom = '4px' } 
                                                            
                                                                }
                                                            }

                                                            New-UDGrid -Item -SmallSize 6 -Content {
                                                                New-UDTypography -Variant subtitle2 -Text 'Order' -Style @{ fontWeight = 700; marginBottom = '6px' }
                                                                New-UDTypography -Text ("{0} — {1}" -f ($animal ?? '-'), ($portion ?? '-')) -Style @{ marginBottom = '6px' }
                                                                if ($slotText) { 
                                                                    New-UDElement -Tag 'br'
                                                                    New-UDTypography -Text ("Selected slot: {0}" -f $slotText) -Style @{ color = '#666'; marginBottom = '4px' } 
                                                                }

                                                                if ($shop) { 
                                                                    New-UDElement -Tag 'br'
                                                                    New-UDTypography -Text ("Shop: {0}" -f $shop) -Style @{ color = '#666'; marginBottom = '4px' } 
                                                                }
                                                            }
                                                        }

                                                        if ($notes) {
                                                            New-UDGrid -Item -SmallSize 12 -Content {
                                                                New-UDTypography -Variant subtitle2 -Text 'Notes' -Style @{ fontWeight = 700; marginTop = '10px'; marginBottom = '6px' }
                                                                New-UDTypography -Text $notes -Style @{ color = '#555' }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                    } -OnFinish {
                                        $Session:StepperFinished = $true
                                        $Session:BookingContext = $EventData.Context
                                        Submit-Order -Context $Session:BookingContext
                                        Sync-UDElement -Id 'stepperdynamic'
                                    }
                                }
                            
                            }
                        }

                        New-UDCard @cardParams

                    }
                }
            }
        }
    }
}
