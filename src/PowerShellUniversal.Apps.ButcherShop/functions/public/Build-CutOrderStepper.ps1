function Build-CutOrderStepper {
    param(
        [Parameter(Mandatory)] [string] $ConstructorName,
        [switch] $ReturnStrings
    )

    # Read function parameter metadata where possible, otherwise parse source param() block
    $cmd = Get-Command -Name $ConstructorName -ErrorAction SilentlyContinue
    if ($cmd -and $cmd.Parameters) {
        $paramMeta = $cmd.Parameters.Values
    }
    else {
        $file = Get-ChildItem -Path $PSScriptRoot -Recurse -Filter '*.ps1' | Where-Object { $_.Name -match $ConstructorName }
        if (-not $file) { throw "Constructor $ConstructorName not found as command or source file." }
        $content = Get-Content $file.FullName -Raw
        $matches = [regex]::Matches($content, 'param\\s*\\((?<body>.*?)\\)', [System.Text.RegularExpressions.RegexOptions]::Singleline)
        if ($matches.Count -eq 0) { throw "Could not parse parameters for $ConstructorName" }
        $body = $matches[0].Groups['body'].Value
        $paramNames = ([regex]::Matches($body, '\\$([a-zA-Z0-9_]+)') | ForEach-Object { $_.Groups[1].Value }) | Select-Object -Unique
        $paramMeta = foreach ($n in $paramNames) { @{ Name = $n; ParameterType = 'string' } }
    }

    $params = @()
    foreach ($p in $paramMeta) {
        $name = $p.Name
        $type = if ($p.ParameterType) { $p.ParameterType.FullName } else { 'System.String' }
        $validateSetAttr = $p.Attributes | Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] }
        $validateSet = if ($validateSetAttr) { $validateSetAttr.ValidValues } else { $null }
        $params += [PSCustomObject]@{ Name = $name; Type = $type; ValidateSet = $validateSet }
    }

    $groups = [ordered]@{
        'Customer'                       = @('CutFor', 'Phone', 'BeefFrom', 'MeatFrom')
        'Rib & Roast'                    = @('Rib')
        'Roasts & Short Ribs'            = @('Chuck', 'ArmEnglish', 'BeefShortRibs')
        'T-Bone / Porterhouse / Sirloin' = @('TBone', 'Porterhouse', 'Sirloin')
        'Rounds & Steaks'                = @('Round', 'PlainRound', 'CubedSteak', 'TopRound', 'BottomRound', 'EyeOfRound', 'RumpRoast', 'PotRoast')
        'Packages & Misc'                = @('StewMeat', 'SoupBoilingBones', 'PlateBoil', 'ShankCrossCut', 'Circle', 'GroundBeef', 'Patties', 'HowMuchMadeInPatties', 'SpecialInstructions')
    }

    $steps = @()
    foreach ($groupName in $groups.Keys) {
        $prefixes = $groups[$groupName]
        $groupParams = $params | Where-Object {
            $found = $false
            foreach ($pr in $prefixes) { if ($_.Name -like "*${pr}*") { $found = $true; break } }
            $found
        }
        if (-not $groupParams) { continue }

        $controls = ""
            foreach ($gp in $groupParams) {
                # Default control id derived from parameter name
                $idName = $gp.Name
                # If building for a hog/pork constructor, prefer pork-flavored control ids
                if ($ConstructorName -match 'Hog') {
                    # specific replacements first
                    $idName = $idName -replace 'GroundBeef', 'GroundPork'
                    # general Beef -> Pork
                    $idName = $idName -replace 'Beef', 'Pork'
                }
                $id = 'cut_' + $idName
                # Build a human-friendly label once and escape single quotes for embedding
                # Insert spaces between a lower->upper boundary, e.g. "RibSteak" -> "Rib Steak"
                # Build label by iterating characters and inserting spaces at meaningful transitions:
                # - lower->Upper (e.g. "ribSteak" -> "rib Steak")
                # - letter->digit or digit->letter
                $raw = $gp.Name
                $chars = $raw.ToCharArray()
                $sb = New-Object System.Text.StringBuilder
                for ($i = 0; $i -lt $chars.Length; $i++) {
                    $c = $chars[$i]
                    if ($i -gt 0) {
                        $prev = $chars[$i - 1]
                        if ([char]::IsUpper($c) -and -not [char]::IsUpper($prev)) {
                            $sb.Append(' ') | Out-Null
                        }
                        elseif ([char]::IsDigit($c) -and -not [char]::IsDigit($prev)) {
                            $sb.Append(' ') | Out-Null
                        }
                        elseif (-not [char]::IsDigit($c) -and [char]::IsDigit($prev)) {
                            $sb.Append(' ') | Out-Null
                        }
                    }
                    $sb.Append($c) | Out-Null
                }
                $label = $sb.ToString().Trim()

                # If building for a hog constructor, make labels pork-friendly (only label text, do not change param names)
                if ($ConstructorName -match 'Hog') {
                    # specific mappings
                    $label = $label -replace 'Ground Beef', 'Ground Pork'
                    # general Beef -> Pork mapping (word boundary first)
                    $label = $label -replace '\bBeef\b', 'Pork'
                    $label = $label -replace 'Beef', 'Pork'
                }
                $labelEsc = $label -replace "'", "''"

                if ($gp.Name -match 'SpecialInstructions') {
                    $controls += "New-UDGrid -Item -SmallSize 12 -Content { New-UDTextbox -Id '$id' -Label 'Special Instructions' -Placeholder 'Any special requests...' -Multiline -Rows 4 -RowsMax 12 }`n"
                    continue
                }

                if ($gp.ValidateSet -and $gp.ValidateSet.Count -gt 0) {
                    # Build options as an explicit array of New-UDSelectOption scriptblocks so Value is a string
                    $optLines = $gp.ValidateSet | ForEach-Object { 
                        # Normalize/trim and escape single quotes; force string literal on Value
                        $rawVal = $_.ToString().Trim()
                        $val = $rawVal -replace "'", "''"
                        "New-UDSelectOption -Name '$val' -Value ([string] '$val')"
                    }
                    # Emit as a scriptblock so Universal Dashboard/PowerShell Universal evaluates options in its runspace
                    $optBlock = "{`n    " + ($optLines -join "`n    ") + "`n}"
                    $controls += "New-UDGrid -Item -SmallSize 12 -Content { New-UDSelect -Id '$id' -Label '$labelEsc' -Option $optBlock }`n"
                    continue
                }

                if ($gp.Name -match 'Lbs|LbsPer|ThicknessIn|PerPackage|Packages|TotalPackages|Patties|HowMuch') {
                    $placeholder = 'e.g. 1.5'
                    $controls += "New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id '$id' -Label '$labelEsc' -Placeholder '$placeholder' }`n"
                    continue
                }

                $controls += "New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id '$id' -Label '$labelEsc' -Placeholder '' }`n"
        }

        $stepCode = @"
New-UDStep -Id '$($groupName -replace '\\s','-')' -Label '$groupName' -OnLoad {
    New-UDCard -Content {
        New-UDGrid -Container -Spacing 2 -Content {
$controls
        }
    }
}
"@
        if ($ReturnStrings) {
            $steps += $stepCode
        }
        else {
            $steps += [scriptblock]::Create($stepCode)
        }
    }

    return ,$steps
}
