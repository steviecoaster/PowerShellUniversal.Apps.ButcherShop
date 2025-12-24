function Show-DonHogCutOrder {
    <#
    .SYNOPSIS
    Render a Don hog cut order input UI (UniversalDashboard components) and submit to Save-DonHogCutOrder.
    .DESCRIPTION
    A hog-only stepper UI. Visible controls and labels use pork terminology. On submit the UI values
    are mapped back to the existing constructor parameter names (which still use the internal "Beef" schema)
    before calling New-DonHogCutOrder and Save-DonHogCutOrder.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [int]$OrderId
    )

    $Session:OrderInfo = Get-Order -OrderId $OrderId

    $style = @"
.butcher-stepper-wrapper { display:flex; justify-content:center }
.butcher-stepper-card { width:100%; max-width:760px }
.butcher-stepper-card.psu-stepper-card { border-radius:12px; box-shadow:0 6px 18px rgba(0,0,0,0.08) }
.butcher-stepper-card .ud-card-body { padding:18px }
"@

    New-UDStyle -Style $style -Content {
        New-UDElement -Tag 'div' -ClassName 'butcher-stepper-wrapper' -Content {
            New-UDCard -ClassName 'butcher-stepper-card psu-stepper-card' -Title "Don's Custom Meats — Hog Cut Order" -Content {

                New-UDStepper -Id 'cutorder-stepper' -Steps {
                    # Step 1 — customer & pickup
                    New-UDStep -Title 'Customer' -Content {
                        New-UDGrid -Columns 2 -Content {
                            New-UDTextbox -Id 'cut_CutFor' -Label 'Cut For (Name)'
                            New-UDTextbox -Id 'cut_Phone' -Label 'Phone'
                            New-UDTextbox -Id 'cut_PorkFrom' -Label 'Pork From (if not your own raised)'
                            New-UDSelect -Id 'cut_CircleChoice' -Label 'Circle One' -Options {
                                New-UDSelectOption -Name 'Whole Hog' -Value ([string]'Whole Hog')
                                New-UDSelectOption -Name 'Half Hog' -Value ([string]'Half Hog')
                            }
                        }
                    }
                    # Step 2 — shoulder & chops, spare ribs
                    New-UDStep -Title 'Shoulder, Chops & Ribs' -Content {
                        New-UDGrid -Columns 2 -Content {
                            New-UDSelect -Id 'cut_ShoulderChoice' -Label 'Shoulder' -Options {
                                New-UDSelectOption -Name 'Roasts' -Value ([string]'Roasts')
                                New-UDSelectOption -Name 'Steaks' -Value ([string]'Steaks')
                                New-UDSelectOption -Name 'Picnic Ham' -Value ([string]'Picnic Ham')
                            }
                            New-UDTextbox -Id 'cut_ShoulderRoastsLbsPerRoast' -Label 'Shoulder Roasts Lbs per Roast'
                            New-UDTextbox -Id 'cut_ShoulderSteaksThicknessIn' -Label 'Shoulder Steak Thickness (in)'
                            New-UDTextbox -Id 'cut_ShoulderSteaksPerPackage' -Label 'Shoulder Steaks per Package'

                            New-UDSelect -Id 'cut_SpareRibsChoice' -Label 'Spare Ribs' -Options {
                                New-UDSelectOption -Name 'Lbs per Cut' -Value ([string]'Lbs per Cut')
                                New-UDSelectOption -Name 'Whole Slab' -Value ([string]'Whole Slab')
                            }
                            New-UDTextbox -Id 'cut_SpareRibsLbsPerCut' -Label 'Spare Ribs Lbs per Cut'
                            New-UDTextbox -Id 'cut_SpareRibsPiecesPerPackage' -Label 'Spare Ribs Pieces per Package'
                            New-UDTextbox -Id 'cut_SpareRibsWholeSlabPerPackage' -Label 'Spare Ribs Whole Slab per Package'
                        }
                    }

                    # Step 3 — hams, bacon, ham hocks
                    New-UDStep -Title 'Hams & Bacon' -Content {
                        New-UDGrid -Columns 2 -Content {
                            New-UDSelect -Id 'cut_HamChoice' -Label 'Ham' -Options {
                                New-UDSelectOption -Name 'Cured & Smoked' -Value ([string]'Cured & Smoked')
                                New-UDSelectOption -Name 'Fresh Leg' -Value ([string]'Fresh Leg')
                            }
                            New-UDTextbox -Id 'cut_CuredHamPortion' -Label 'Cured Ham Portion (Whole/Half)'
                            New-UDSelect -Id 'cut_CuredHamSliceStyle' -Label 'Cured Ham Slice Style' -Options {
                                New-UDSelectOption -Name 'Center slices' -Value ([string]'Center slices')
                                New-UDSelectOption -Name 'All sliced' -Value ([string]'All sliced')
                            }
                            New-UDTextbox -Id 'cut_CuredHamSlicesPerPackage' -Label 'Cured Ham Slices per Package'

                            New-UDSelect -Id 'cut_BaconChoice' -Label 'Bacon' -Options {
                                New-UDSelectOption -Name 'Cured & Smoked' -Value ([string]'Cured & Smoked')
                                New-UDSelectOption -Name 'Fresh Side' -Value ([string]'Fresh Side')
                            }
                            New-UDTextbox -Id 'cut_BaconLbsPerPackage' -Label 'Bacon Lbs per Package'
                            New-UDSelect -Id 'cut_BaconSliceThickness' -Label 'Bacon Slice Thickness' -Options {
                                New-UDSelectOption -Name 'Thick' -Value ([string]'Thick')
                                New-UDSelectOption -Name 'Medium' -Value ([string]'Medium')
                                New-UDSelectOption -Name 'Thin' -Value ([string]'Thin')
                            }

                            New-UDSelect -Id 'cut_HamHocksChoice' -Label 'Ham Hocks' -Options {
                                New-UDSelectOption -Name 'Cured & Smoked' -Value ([string]'Cured & Smoked')
                                New-UDSelectOption -Name 'Fresh Hocks' -Value ([string]'Fresh Hocks')
                            }
                            New-UDCheckBox -Id 'cut_PutHamHocksIntoSausage' -Label 'Put into Sausage?'
                        }
                    }

                    # Step 4 — sausage & offal & misc
                    New-UDStep -Title 'Sausage & Offal' -Content {
                        New-UDGrid -Columns 2 -Content {
                            New-UDSelect -Id 'cut_SausageSeasoning' -Label 'Sausage Seasoning' -Options {
                                New-UDSelectOption -Name 'Plain' -Value ([string]'Plain')
                                New-UDSelectOption -Name 'Salt & Pepper' -Value ([string]'Salt & Pepper')
                                New-UDSelectOption -Name 'Country Mild' -Value ([string]'Country Mild')
                                New-UDSelectOption -Name 'Sage Hot' -Value ([string]'Sage Hot')
                                New-UDSelectOption -Name 'Sweet Italian' -Value ([string]'Sweet Italian')
                                New-UDSelectOption -Name 'Hot Italian' -Value ([string]'Hot Italian')
                            }
                            New-UDCheckBox -Id 'cut_SausageBulk' -Label 'Bulk (no casing)'
                            New-UDTextbox -Id 'cut_SausageBulkLbsPerPackage' -Label 'Bulk Lbs per Package'
                            New-UDCheckBox -Id 'cut_SausageRegularCased' -Label 'Regular Cased'
                            New-UDTextbox -Id 'cut_SausageRegularCasedLbsPerPackage' -Label 'Regular Cased Lbs per Package'
                            New-UDCheckBox -Id 'cut_SausageSmallLink' -Label 'Small Link'
                            New-UDTextbox -Id 'cut_SausageSmallLinkLbsPerPackage' -Label 'Small Link Lbs per Package'
                            New-UDTextbox -Id 'cut_SausageNotes' -Label 'Sausage Notes'

                            New-UDSelect -Id 'cut_LiverChoice' -Label 'Liver' -Options {
                                New-UDSelectOption -Name 'Yes/Sliced' -Value ([string]'Yes/Sliced')
                                New-UDSelectOption -Name 'No' -Value ([string]'No')
                            }
                            New-UDSelect -Id 'cut_HeartChoice' -Label 'Heart' -Options {
                                New-UDSelectOption -Name 'Yes' -Value ([string]'Yes')
                                New-UDSelectOption -Name 'No' -Value ([string]'No')
                            }
                            New-UDSelect -Id 'cut_TongueChoice' -Label 'Tongue' -Options {
                                New-UDSelectOption -Name 'Yes' -Value ([string]'Yes')
                                New-UDSelectOption -Name 'No' -Value ([string]'No')
                            }

                            New-UDTextbox -Id 'cut_SpecialInstructions' -Label 'Special Instructions' -Rows 4
                        }
                    }
                } -OnFinish {
                    try {
                        function ToDecimal($v) { if ($v -and $v -match '[0-9]') { try { [decimal]$v } catch { $null } } else { $null } }
                        function ToInt($v)     { if ($v -and $v -match '[0-9]') { try { [int]$v } catch { $null } } else { $null } }

                        # UI naming (Pork) vs internal constructor naming (Beef)
                        $UIprefix = 'Pork'
                        $InternalPrefix = 'Beef'
                        $GroundUI = 'GroundPork'
                        $GroundInternal = 'GroundBeef'

                        $ids = @(
                            'cut_CutFor','cut_Phone','cut_PorkFrom','cut_CircleChoice',
                            'cut_PorkChopsThicknessIn','cut_PorkChopsPerPackage','cut_PorkLoinRoastLbsPerRoast',
                            'cut_ShoulderChoice','cut_ShoulderRoastsLbsPerRoast','cut_ShoulderSteaksThicknessIn','cut_ShoulderSteaksPerPackage','cut_PicnicHamWholeHalfSliced',
                            'cut_SpareRibsChoice','cut_SpareRibsLbsPerCut','cut_SpareRibsPiecesPerPackage','cut_SpareRibsWholeSlabPerPackage',
                            'cut_HamChoice','cut_CuredHamPortion','cut_CuredHamSliceStyle','cut_CuredHamSlicesPerPackage',
                            'cut_FreshLegPortion','cut_FreshLegCutIntoRoastsLbs','cut_FreshLegProcessStyle','cut_FreshLegSlicesOrSteaksPerPackage',
                            'cut_BaconChoice','cut_BaconLbsPerPackage','cut_BaconSliceThickness',
                            'cut_HamHocksChoice','cut_PutHamHocksIntoSausage',
                            'cut_SausageSeasoning','cut_SausageBulk','cut_SausageBulkLbsPerPackage','cut_SausageRegularCased','cut_SausageRegularCasedLbsPerPackage','cut_SausageSmallLink','cut_SausageSmallLinkLbsPerPackage','cut_SausageNotes',
                            'cut_LiverChoice','cut_HeartChoice','cut_TongueChoice','cut_SpecialInstructions'
                        )

                        $values = @{}
                        foreach ($id in $ids) {
                            $el = Get-UDElement -Id $id -ErrorAction SilentlyContinue
                            $values[$id] = if ($el) { $el.Value } else { $null }
                        }

                        # Normalize multi-select CircleChoice into CSV
                        $circleVal = $values['cut_CircleChoice']
                        if ($circleVal -is [System.Array]) { $circleVal = $circleVal -join ',' }

                        # Build pork-shaped object and pass directly to Save-DonHogCutOrder
                        $out = [ordered]@{}
                        $out.Schema = 'DonPorkCutSheet.v1'
                        foreach ($kv in $values.GetEnumerator()) {
                            $k = $kv.Key; $v = $kv.Value
                            if ($k -match '^cut_(.+)$') { $field = $matches[1]; $out[$field] = $v }
                        }
                        $out.OrderId = $OrderId

                        Save-DonHogCutOrder -CutOrder $out
                        Show-UDToast -Message "Saved hog cut order for OrderId $OrderId" -Duration 3000 -Position top
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