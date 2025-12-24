function Show-DonBeefCutOrder {
    <#
.SYNOPSIS
Render a Don beef cut order input UI (UniversalDashboard components) and submit to Save-DonBeefCutOrder.

.DESCRIPTION
Renders a set of controls (textboxes, selects, number inputs) inside a card. Does not rely on New-UDForm. The Submit button collects control values using Get-UDElement and calls New-DonBeefCutOrder + Save-DonBeefCutOrder.

.PARAMETER OrderId
The OrderId to attach this cut order to. If omitted, the form will require it on submit.
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

            New-UDCard -ClassName 'butcher-stepper-card psu-stepper-card' -Title "Don's Custom Meats Beef Cut Order" -Content {

                New-UDStepper -Id 'cutorder-stepper' -Steps {
                    # Defensive: if someone changes this to use the builder later, keep correct constructor
                    $null
                    New-UDStep -Id 'customer' -Label 'Customer' -OnLoad {
                        New-UDCard -Content {
                            New-UDStack -Spacing 2 -Children {
                                # Guidance card (customer)
                                New-UDCard -Style @{ backgroundColor = '#f5f7fa'; borderRadius = '8px'; padding = '12px 14px'; marginBottom = '12px'; boxShadow = 'none'; borderLeft = '4px solid #1976d2' } -Content {
                                    New-UDElement -Tag 'ul' -Attributes @{ style = @{ margin = '0'; paddingLeft = '18px' } } -Content {
                                        New-UDElement -Tag 'li' -Content { New-UDTypography -Variant caption -Text 'Confirm the customer name and phone match the main order.' -Style @{ opacity = 0.9 } }
                                        New-UDElement -Tag 'li' -Content { New-UDTypography -Variant caption -Text 'These fields are read-only here; edit the main order to change them.' -Style @{ opacity = 0.9 } }
                                        New-UDElement -Tag 'li' -Content { New-UDTypography -Variant caption -Text 'If details are missing, update the order first before saving a cut sheet.' -Style @{ opacity = 0.9 } }
                                    }
                                }
                                $newUDTextboxSplat = @{ 
                                    Id          = 'cut_CutFor'
                                    Label       = 'Cut For'
                                    Placeholder = $('{0} {1}' -f $Session:OrderInfo.Firstname, $Session:OrderInfo.Lastname)
                                    Disabled    = $true
                                }

                                New-UDTextbox @newUDTextboxSplat
                        
                                $newUDTextboxSplat = @{ 
                                    Id          = 'cut_Phone'
                                    Label       = 'Phone'
                                    Placeholder = '{0}' -f $Session:OrderInfo.CustomerPhone
                                    Disabled    = $true
                                }

                                New-UDTextbox @newUDTextboxSplat

                                $newUDTextboxSplat = @{ 
                                    Id          = 'cut_BeefFrom'
                                    Label       = 'Beef From'
                                    Placeholder = 'Jerry Valdinger'
                                    Disabled    = $true
                                }

                                New-UDTextbox @newUDTextboxSplat
                            }
                        }
                    }

                    New-UDStep -Id 'rib-roast' -Label 'Rib & Roast' -OnLoad {
                        New-UDCard -Content {
                            # Guidance card (Rib & Roast)
                            New-UDCard -Style @{ backgroundColor = '#f5f7fa'; borderRadius = '8px'; padding = '12px 14px'; marginBottom = '12px'; boxShadow = 'none'; borderLeft = '4px solid #1976d2' } -Content {
                                New-UDElement -Tag 'ul' -Attributes @{ style = @{ margin = '0'; paddingLeft = '18px' } } -Content {
                                    New-UDElement -Tag 'li' -Content { New-UDTypography -Variant caption -Text 'Enter thickness in inches (decimals allowed, e.g. 0.75).' -Style @{ opacity = 0.9 } }
                                    New-UDElement -Tag 'li' -Content { New-UDTypography -Variant caption -Text 'Package counts should be whole numbers (e.g. 4).' -Style @{ opacity = 0.9 } }
                                    New-UDElement -Tag 'li' -Content { New-UDTypography -Variant caption -Text 'Use the Rib Roast selector for Yes/No and provide lbs per roast when applicable.' -Style @{ opacity = 0.9 } }
                                    New-UDElement -Tag 'li' -Content { New-UDTypography -Variant caption -Text 'Leave fields blank if you do not want that cut.' -Style @{ opacity = 0.85 } }
                                }

                            }

                            New-UDGrid -Container -Spacing 2 -Content {
                                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'cut_RibSteakThicknessIn' -Label 'Rib Steak Thickness (in)' -Placeholder 'e.g. 0.75' }
                                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'cut_RibSteakPerPackage' -Label 'Rib Steak Per Package' -Placeholder 'e.g. 4' }
                                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'cut_RibEyeThicknessIn' -Label 'Rib Eye Thickness (in)' -Placeholder 'e.g. 0.75' }
                                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'cut_RibEyePerPackage' -Label 'Rib Eye Per Package' -Placeholder 'e.g. 4' }
                                New-UDGrid -Item -SmallSize 6 -Content { New-UDSelect -Id 'cut_RibRoastChoice' -Label 'Rib Roast' -Option { @('Yes', 'No') | ForEach-Object { New-UDSelectOption -Name $_ -Value $_ } } }
                                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'cut_RibRoastLbsPerRoast' -Label 'Rib Roast Lbs/roast' -Placeholder 'e.g. 4.5' }
                            }
                        }
                    }

                    New-UDStep -Id 'roasts-short-ribs' -Label 'Roasts & Short Ribs' -OnLoad {
                        New-UDCard -Content {
                            New-UDCard -Style @{ backgroundColor = '#f5f7fa'; borderRadius = '8px'; padding = '12px 14px'; marginBottom = '12px'; boxShadow = 'none'; borderLeft = '4px solid #1976d2' } -Content {
                                New-UDElement -Tag 'ul' -Attributes @{ style = @{ margin = '0'; paddingLeft = '18px' } } -Content {
                                    New-UDElement -Tag 'li' -Content { New-UDTypography -Variant caption -Text 'Enter roast weights in pounds (decimals allowed, e.g. 3.0).' -Style @{ opacity = 0.9 } }
                                    New-UDElement -Tag 'li' -Content { New-UDTypography -Variant caption -Text 'For short ribs: select None or Some, then provide lbs per package and number of packages.' -Style @{ opacity = 0.9 } }
                                    New-UDElement -Tag 'li' -Content { New-UDTypography -Variant caption -Text 'Leave fields blank if you do not require this cut.' -Style @{ opacity = 0.85 } }
                                }

                            }

                            New-UDGrid -Container -Spacing 2 -Content {
                                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'cut_ChuckRoastLbsPerRoast' -Label 'Chuck Roast Lbs/roast' -Placeholder 'e.g. 3.0' }
                                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'cut_ArmEnglishRoastLbsPerRoast' -Label 'Arm/English Roast Lbs/roast' -Placeholder 'e.g. 2.5' }
                                New-UDGrid -Item -SmallSize 6 -Content { New-UDSelect -Id 'cut_BeefShortRibsChoice' -Label 'Short Ribs' -Option { @('None', 'Some') | ForEach-Object { New-UDSelectOption -Name $_ -Value $_ } } }
                                New-UDGrid -Item -SmallSize 3 -Content { New-UDTextbox -Id 'cut_BeefShortRibsLbsPerPackage' -Label 'Short Ribs Lbs/pkg' -Placeholder 'e.g. 1.5' }
                                New-UDGrid -Item -SmallSize 3 -Content { New-UDTextbox -Id 'cut_BeefShortRibsPackagesWanted' -Label 'Short Ribs pkgs' -Placeholder 'e.g. 2' }
                            }
                        }
                    }

                    New-UDStep -Id 'tbone-porterhouse-sirloin' -Label 'T-Bone / Porterhouse / Sirloin' -OnLoad {
                        New-UDCard -Content {
                            New-UDCard -Style @{ backgroundColor = '#f5f7fa'; borderRadius = '8px'; padding = '12px 14px'; marginBottom = '12px'; boxShadow = 'none'; borderLeft = '4px solid #1976d2' } -Content {
                                New-UDElement -Tag 'ul' -Attributes @{ style = @{ margin = '0'; paddingLeft = '18px' } } -Content {
                                    New-UDElement -Tag 'li' -Content { New-UDTypography -Variant caption -Text 'Enter steak thickness in inches (typical 0.5–1.0). Decimals allowed.' -Style @{ opacity = 0.9 } }
                                    New-UDElement -Tag 'li' -Content { New-UDTypography -Variant caption -Text 'Specify count per package as whole numbers.' -Style @{ opacity = 0.9 } }
                                    New-UDElement -Tag 'li' -Content { New-UDTypography -Variant caption -Text 'Leave blank if you do not want this cut.' -Style @{ opacity = 0.85 } }
                                }

                            }

                            New-UDGrid -Container -Spacing 2 -Content {
                                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'cut_TBoneThicknessIn' -Label 'T-Bone Thickness (in)' -Placeholder 'e.g. 0.75' }
                                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'cut_TBonePerPackage' -Label 'T-Bone Per Package' -Placeholder 'e.g. 2' }
                                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'cut_PorterhouseThicknessIn' -Label 'Porterhouse Thickness (in)' -Placeholder 'e.g. 0.75' }
                                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'cut_PorterhousePerPackage' -Label 'Porterhouse Per Package' -Placeholder 'e.g. 2' }
                                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'cut_SirloinThicknessIn' -Label 'Sirloin Thickness (in)' -Placeholder 'e.g. 0.75' }
                                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'cut_SirloinPerPackage' -Label 'Sirloin Per Package' -Placeholder 'e.g. 4' }
                            }
                        }
                    }

                    New-UDStep -Id 'rounds-steaks' -Label 'Rounds & Steaks' -OnLoad {
                        New-UDCard -Content {
                            New-UDCard -Style @{ backgroundColor = '#f5f7fa'; borderRadius = '8px'; padding = '12px 14px'; marginBottom = '12px'; boxShadow = 'none'; borderLeft = '4px solid #1976d2' } -Content {
                                New-UDElement -Tag 'ul' -Attributes @{ style = @{ margin = '0'; paddingLeft = '18px' } } -Content {
                                    New-UDElement -Tag 'li' -Content { New-UDTypography -Variant caption -Text 'Select Roast, Steaks, Both, or None.' -Style @{ opacity = 0.9 } }
                                    New-UDElement -Tag 'li' -Content { New-UDTypography -Variant caption -Text 'Enter roast weight in lbs and steak thickness in inches where needed.' -Style @{ opacity = 0.9 } }
                                    New-UDElement -Tag 'li' -Content { New-UDTypography -Variant caption -Text 'Provide package counts for packaged items.' -Style @{ opacity = 0.85 } }
                                }

                            }

                            New-UDGrid -Container -Spacing 2 -Content {
                                New-UDGrid -Item -SmallSize 12 -Content { New-UDSelect -Id 'cut_RoundTipChoice' -Label 'Round Tip' -Option { @('Roast', 'Steaks', 'Both', 'None') | ForEach-Object { New-UDSelectOption -Name $_ -Value $_ } } }
                                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'cut_RoundTipRoastLbsEach' -Label 'Round Tip Roast Lbs' -Placeholder 'e.g. 3.0' }
                                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'cut_RoundTipSteakThicknessIn' -Label 'Round Tip Steak Thickness' -Placeholder 'e.g. 0.5' }
                                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'cut_RoundTipSteakPerPackage' -Label 'Round Tip Steak Per Package' -Placeholder 'e.g. 4' }

                                New-UDGrid -Item -SmallSize 12 -Content { New-UDSelect -Id 'cut_RoundSteakChoice' -Label 'Round Steak' -Option { @('AllPlain', 'HalfPlainHalfCubed', 'AllCubed') | ForEach-Object { New-UDSelectOption -Name $_ -Value $_ } } }
                                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'cut_RoundSteakThicknessIn' -Label 'Round Steak Thickness' -Placeholder 'e.g. 0.5' }
                                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'cut_PlainRoundSteakWholePerPackage' -Label 'Plain Round Whole/pkg' -Placeholder 'e.g. 1' }
                                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'cut_PlainRoundSteakHalfPerPackage' -Label 'Plain Round Half/pkg' -Placeholder 'e.g. 2' }
                                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'cut_CubedSteakServingSizePerPackage' -Label 'Cubed Steak Serving Size/pkg' -Placeholder 'e.g. 1' }
                            }
                        }
                    }

                    New-UDStep -Id 'packages-misc' -Label 'Packages & Misc' -OnLoad {
                        New-UDCard -Content {
                            New-UDCard -Style @{ backgroundColor = '#f5f7fa'; borderRadius = '8px'; padding = '12px 14px'; marginBottom = '12px'; boxShadow = 'none'; borderLeft = '4px solid #1976d2' } -Content {
                                New-UDElement -Tag 'ul' -Attributes @{ style = @{ margin = '0'; paddingLeft = '18px' } } -Content {
                                    New-UDElement -Tag 'li' -Content { New-UDTypography -Variant caption -Text 'Use the Yes/No selects for simple preferences.' -Style @{ opacity = 0.9 } }
                                    New-UDElement -Tag 'li' -Content { New-UDTypography -Variant caption -Text 'Specify lbs per package and total package counts as applicable.' -Style @{ opacity = 0.9 } }
                                    New-UDElement -Tag 'li' -Content { New-UDTypography -Variant caption -Text 'Add bespoke requests in Special Instructions (e.g., "No salt", "Extra trimming").' -Style @{ opacity = 0.85 } }
                                }

                            }

                            New-UDGrid -Container -Spacing 2 -Content {
                                New-UDGrid -Item -SmallSize 6 -Content { New-UDSelect -Id 'cut_StewMeatChoice' -Label 'Stew Meat' -Option { @('No', 'Yes') | ForEach-Object { New-UDSelectOption -Name $_ -Value $_ } } }
                                New-UDGrid -Item -SmallSize 3 -Content { New-UDTextbox -Id 'cut_StewMeatLbsPerPackage' -Label 'Stew Lbs/pkg' -Placeholder 'e.g. 1.5' }
                                New-UDGrid -Item -SmallSize 3 -Content { New-UDTextbox -Id 'cut_StewMeatTotalPackages' -Label 'Stew Total pkgs' -Placeholder 'e.g. 2' }

                                New-UDGrid -Item -SmallSize 6 -Content { New-UDSelect -Id 'cut_SoupBoilingBonesChoice' -Label 'Soup/Boiling Bones' -Option { @('No', 'Yes') | ForEach-Object { New-UDSelectOption -Name $_ -Value $_ } } }
                                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'cut_SoupBoilingBonesTotalPackages' -Label 'Soup Bones pkgs' -Placeholder 'e.g. 1' }

                                New-UDGrid -Item -SmallSize 6 -Content { New-UDSelect -Id 'cut_PlateBoilChoice' -Label 'Plate Boil' -Option { @('No', 'Yes') | ForEach-Object { New-UDSelectOption -Name $_ -Value $_ } } }
                                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'cut_PlateBoilTotalPackages' -Label 'Plate Boil pkgs' -Placeholder 'e.g. 1' }

                                New-UDGrid -Item -SmallSize 6 -Content { New-UDSelect -Id 'cut_ShankCrossCutChoice' -Label 'Shank Cross Cut' -Option { @('No', 'Yes') | ForEach-Object { New-UDSelectOption -Name $_ -Value $_ } } }
                                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'cut_ShankCrossCutTotalPackages' -Label 'Shank Cross Cut pkgs' -Placeholder 'e.g. 1' }

                                New-UDGrid -Item -SmallSize 12 -Content { New-UDSelect -Id 'cut_CircleChoice' -Label 'Circle Choice' -Multiple -Option { @('None', 'BeefLiver', 'BeefHeart', 'BeefTongue') | ForEach-Object { New-UDSelectOption -Name $_ -Value $_ } } }

                                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'cut_GroundBeefLbsPerPackage' -Label 'Ground Beef Lbs/pkg' -Placeholder 'e.g. 1.0' }
                                New-UDGrid -Item -SmallSize 3 -Content { New-UDTextbox -Id 'cut_PattiesPerPackage' -Label 'Patties/pkg' -Placeholder 'e.g. 12' }
                                New-UDGrid -Item -SmallSize 3 -Content { New-UDTextbox -Id 'cut_HowMuchMadeInPattiesLbs' -Label 'Made in patties lbs' -Placeholder 'e.g. 5.0' }

                                New-UDGrid -Item -SmallSize 12 -Content { New-UDTextbox -Id 'cut_SpecialInstructions' -Label 'Special Instructions' -Placeholder 'Any special requests...' -Multiline -Rows 4 -RowsMax 12 }

                                # final submit in the stepper content
                                New-UDGrid -Item -SmallSize 12 -Content {
                                    New-UDButton -Text 'Submit Cut Order' -OnClick {
                    
                                    }
                                }
                            }
                        }
                    }
                } -OnFinish {
                    try {
                        # helper converters
                        function ToDecimal($v) { if ($v -and $v -match "[0-9]") { try { [decimal]$v } catch { $null } } else { $null } }
                        function ToInt($v) { if ($v -and $v -match "[0-9]") { try { [int]$v } catch { $null } } else { $null } }

                        $values = @{}
                        $ids = @( 
                            'cut_CutFor', 'cut_Phone', 'cut_BeefFrom',
                            'cut_RibSteakThicknessIn', 'cut_RibSteakPerPackage', 'cut_RibEyeThicknessIn', 'cut_RibEyePerPackage',
                            'cut_RibRoastChoice', 'cut_RibRoastLbsPerRoast', 'cut_ChuckRoastLbsPerRoast', 'cut_ArmEnglishRoastLbsPerRoast',
                            'cut_BeefShortRibsChoice', 'cut_BeefShortRibsLbsPerPackage', 'cut_BeefShortRibsPackagesWanted',
                            'cut_TBoneThicknessIn', 'cut_TBonePerPackage', 'cut_PorterhouseThicknessIn', 'cut_PorterhousePerPackage', 'cut_SirloinThicknessIn', 'cut_SirloinPerPackage',
                            'cut_RoundTipChoice', 'cut_RoundTipRoastLbsEach', 'cut_RoundTipSteakThicknessIn', 'cut_RoundTipSteakPerPackage',
                            'cut_RoundSteakChoice', 'cut_RoundSteakThicknessIn', 'cut_PlainRoundSteakWholePerPackage', 'cut_PlainRoundSteakHalfPerPackage', 'cut_CubedSteakServingSizePerPackage',
                            'cut_TopRoundLbsPerRoast', 'cut_BottomRoundLbsPerRoast', 'cut_EyeOfRoundLbsPerRoast',
                            'cut_RumpRoastChoice', 'cut_RumpRoastLbsPerRoast', 'cut_PotRoastChoice', 'cut_PotRoastLbsPerRoast',
                            'cut_StewMeatChoice', 'cut_StewMeatLbsPerPackage', 'cut_StewMeatTotalPackages',
                            'cut_SoupBoilingBonesChoice', 'cut_SoupBoilingBonesTotalPackages', 'cut_PlateBoilChoice', 'cut_PlateBoilTotalPackages',
                            'cut_ShankCrossCutChoice', 'cut_ShankCrossCutTotalPackages', 'cut_CircleChoice',
                            'cut_GroundBeefLbsPerPackage', 'cut_PattiesPerPackage', 'cut_HowMuchMadeInPattiesLbs', 'cut_SpecialInstructions'
                        )

                        foreach ($id in $ids) {
                            $el = Get-UDElement -Id $id -ErrorAction SilentlyContinue
                            if ($el) { $values[$id] = $el.Value } else { $values[$id] = $null }
                        }

                        # build full splat
                        # Normalize multi-select CircleChoice into CSV string if needed
                        $circleVal = $values['cut_CircleChoice']
                        if ($circleVal -is [System.Array]) { $circleVal = ($circleVal -join ',') }

                        # Some UD versions return an array for single-selects in certain contexts.
                        # Normalize any '*Choice' values (except CircleChoice which is intentionally multi-select)
                        foreach ($k in $values.Keys) {
                            if ($k -like '*Choice' -and $k -ne 'cut_CircleChoice') {
                                $v = $values[$k]
                                if ($v -is [System.Array]) {
                                    # take the first selected value for single-choice controls
                                    $values[$k] = if ($v.Count -gt 0) { $v[0] } else { $null }
                                }
                            }
                        }

                        $splat = @{
                            OrderId                         = $OrderId
                            CutFor                          = $values['cut_CutFor']
                            Phone                           = $values['cut_Phone']
                            BeefFrom                        = $values['cut_BeefFrom']

                            RibSteakThicknessIn             = ToDecimal $values['cut_RibSteakThicknessIn']
                            RibSteakPerPackage              = ToInt $values['cut_RibSteakPerPackage']
                            RibEyeThicknessIn               = ToDecimal $values['cut_RibEyeThicknessIn']
                            RibEyePerPackage                = ToInt $values['cut_RibEyePerPackage']
                            RibRoastChoice                  = $values['cut_RibRoastChoice']
                            RibRoastLbsPerRoast             = ToDecimal $values['cut_RibRoastLbsPerRoast']

                            ChuckRoastLbsPerRoast           = ToDecimal $values['cut_ChuckRoastLbsPerRoast']
                            ArmEnglishRoastLbsPerRoast      = ToDecimal $values['cut_ArmEnglishRoastLbsPerRoast']

                            BeefShortRibsChoice             = $values['cut_BeefShortRibsChoice']
                            BeefShortRibsLbsPerPackage      = ToDecimal $values['cut_BeefShortRibsLbsPerPackage']
                            BeefShortRibsPackagesWanted     = ToInt $values['cut_BeefShortRibsPackagesWanted']

                            TBoneThicknessIn                = ToDecimal $values['cut_TBoneThicknessIn']
                            TBonePerPackage                 = ToInt $values['cut_TBonePerPackage']
                            PorterhouseThicknessIn          = ToDecimal $values['cut_PorterhouseThicknessIn']
                            PorterhousePerPackage           = ToInt $values['cut_PorterhousePerPackage']
                            SirloinThicknessIn              = ToDecimal $values['cut_SirloinThicknessIn']
                            SirloinPerPackage               = ToInt $values['cut_SirloinPerPackage']

                            RoundTipChoice                  = $values['cut_RoundTipChoice']
                            RoundTipRoastLbsEach            = ToDecimal $values['cut_RoundTipRoastLbsEach']
                            RoundTipSteakThicknessIn        = ToDecimal $values['cut_RoundTipSteakThicknessIn']
                            RoundTipSteakPerPackage         = ToInt $values['cut_RoundTipSteakPerPackage']

                            RoundSteakChoice                = $values['cut_RoundSteakChoice']
                            RoundSteakThicknessIn           = ToDecimal $values['cut_RoundSteakThicknessIn']
                            PlainRoundSteakWholePerPackage  = ToInt $values['cut_PlainRoundSteakWholePerPackage']
                            PlainRoundSteakHalfPerPackage   = ToInt $values['cut_PlainRoundSteakHalfPerPackage']
                            CubedSteakServingSizePerPackage = ToInt $values['cut_CubedSteakServingSizePerPackage']

                            TopRoundLbsPerRoast             = ToDecimal $values['cut_TopRoundLbsPerRoast']
                            BottomRoundLbsPerRoast          = ToDecimal $values['cut_BottomRoundLbsPerRoast']
                            EyeOfRoundLbsPerRoast           = ToDecimal $values['cut_EyeOfRoundLbsPerRoast']

                            RumpRoastChoice                 = $values['cut_RumpRoastChoice']
                            RumpRoastLbsPerRoast            = ToDecimal $values['cut_RumpRoastLbsPerRoast']

                            PotRoastChoice                  = $values['cut_PotRoastChoice']
                            PotRoastLbsPerRoast             = ToDecimal $values['cut_PotRoastLbsPerRoast']

                            StewMeatChoice                  = $values['cut_StewMeatChoice']
                            StewMeatLbsPerPackage           = ToDecimal $values['cut_StewMeatLbsPerPackage']
                            StewMeatTotalPackages           = ToInt $values['cut_StewMeatTotalPackages']

                            SoupBoilingBonesChoice          = $values['cut_SoupBoilingBonesChoice']
                            SoupBoilingBonesTotalPackages   = ToInt $values['cut_SoupBoilingBonesTotalPackages']

                            PlateBoilChoice                 = $values['cut_PlateBoilChoice']
                            PlateBoilTotalPackages          = ToInt $values['cut_PlateBoilTotalPackages']

                            ShankCrossCutChoice             = $values['cut_ShankCrossCutChoice']
                            ShankCrossCutTotalPackages      = ToInt $values['cut_ShankCrossCutTotalPackages']

                            CircleChoice                    = $circleVal

                            GroundBeefLbsPerPackage         = ToDecimal $values['cut_GroundBeefLbsPerPackage']
                            PattiesPerPackage               = ToInt $values['cut_PattiesPerPackage']
                            HowMuchMadeInPattiesLbs         = ToDecimal $values['cut_HowMuchMadeInPattiesLbs']

                            SpecialInstructions             = $values['cut_SpecialInstructions']
                        }

                        if (-not $splat.OrderId -or $splat.OrderId -eq 0) {
                            $maybe = $Session:OrderId
                            if ($maybe) { $splat.OrderId = [int]$maybe }
                        }

                        if (-not $splat.OrderId -or $splat.OrderId -eq 0) {
                            Show-UDToast -Message 'OrderId is required to save a cut order' -Duration 4000 -Position top
                            return
                        }

                        $cut = New-DonBeefCutOrder @splat
                        Save-DonBeefCutOrder -CutOrder $cut

                        Show-UDToast -Message "Saved cut order for OrderId $($splat.OrderId)" -Duration 3000 -Position top
                        Sync-UDElement -Id 'cut-orders-list' -IgnoreNull
                    }
                    catch {
                        Show-UDToast -Message "Error saving cut order: $($_.Exception.Message)" -Duration 8000 -Position top
                    }
                }

            }
        }
    }
}