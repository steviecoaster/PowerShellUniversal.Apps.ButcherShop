<#
Invoke-SeedLargeDataset.ps1

Generates a configurable dataset into the test Pester DB for stress testing.
This script is intended to be run manually for heavier tests. The script is careful to
use transactions and provides a -Scale parameter to scale the number of generated rows.

Usage examples:
  .\Invoke-SeedLargeDataset.ps1 -Scale 1    # small dataset (~100 customers, 365 daily slots)
  .\Invoke-SeedLargeDataset.ps1 -Scale 10   # larger dataset
#>
param(
    [Parameter()]
    [int]
    $Scale = 1,

    [Parameter()]
    [int]
    $Customers,

    [Parameter()]
    [int]
    $Days,

    [Parameter()]
    [int]
    $Orders,

    [Parameter()]
    [int]
    $Seed = 42,

    [Parameter()]
    [string]
    $DatabasePath = $script:TestDbPath
)

if (-not $DatabasePath) {
    throw 'DatabasePath not set. Source Test.Bootstrap.ps1 before running this script in tests.'
}

# If explicit counts not provided, derive from Scale for convenient CLI use
$Customers = if ($PSBoundParameters.ContainsKey('Customers')) { $Customers } else { 100 * [math]::Max(1, $Scale) }
$Days = if ($PSBoundParameters.ContainsKey('Days')) { $Days } else { 365 * [math]::Max(1, $Scale) }
$Orders = if ($PSBoundParameters.ContainsKey('Orders')) { $Orders } else { [math]::Max(1, [int]($Customers * 2)) }

Set-StrictMode -Version Latest

Write-Host "Seeding using module functions into $DatabasePath"
Write-Host "Customers=$Customers Days=$Days Orders=$Orders Seed=$Seed"

# Ensure module functions are available
if (-not (Get-Command New-Customer -ErrorAction SilentlyContinue)) {
    $modulePath = Join-Path (Split-Path -Parent $PSScriptRoot) -ChildPath 'ButcherShop.psd1'
    if (Test-Path $modulePath) { Import-Module $modulePath -Force }
}
if (-not (Get-Command New-Customer -ErrorAction SilentlyContinue)) {
    throw "Could not find module functions (New-Customer). Run this script from the project / test harness that imports the module."
}

$rand = [System.Random]::new($Seed)
$species = @('Beef','Hog')
$createdCustomers = [System.Collections.Generic.List[int]]::new()

Write-Host "Creating $Customers customers..."
for ($i = 1; $i -le $Customers; $i++) {
    # Realistic first/last name lists (deterministic selection via seeded RNG)
    $firstNames = @('Olivia','Liam','Emma','Noah','Ava','Oliver','Sophia','Elijah','Isabella','Lucas','Mia','Mason','Amelia','Logan','Harper','James','Evelyn','Aiden','Abigail','Ethan','Emily','Jacob','Ella','Michael','Camila','Benjamin','Luna','Alexander','Sofia','William')
    $lastNames = @('Smith','Johnson','Williams','Brown','Jones','Garcia','Miller','Davis','Rodriguez','Martinez','Hernandez','Lopez','Gonzalez','Wilson','Anderson','Thomas','Taylor','Moore','Jackson','Martin','Lee','Perez','Thompson','White','Harris','Sanchez','Clark','Ramirez','Lewis','Robinson')

    # Pick names deterministically using the seeded RNG
    $fn = $firstNames[$rand.Next(0, $firstNames.Count)]
    $ln = $lastNames[$rand.Next(0, $lastNames.Count)]

    # Ensure reasonably realistic phone numbers: choose common area codes and generate a 7-digit number
    $areaCodes = @('206','425','509','360','253','971','503','412','617','718')
    $area = $areaCodes[$rand.Next(0, $areaCodes.Count)]
    $prefix = $rand.Next(200, 999)
    $line = $rand.Next(0, 10000)
    $phone = "($area) {0:D3}-{1:D4}" -f $prefix, $line

    # Email derived from name + index for uniqueness
    $local = "{0}.{1}{2}" -f ($fn.ToLower()), ($ln.ToLower()), $i
    $email = "$local@example.local"

    # Create customer (omit Notes for cleaner data)
    $id = (New-Customer -FirstName $fn -LastName $ln -Phone $phone -Email $email).CustomerId
    $createdCustomers.Add([int]$id) | Out-Null
}
Write-Host "Created $($createdCustomers.Count) customers."

Write-Host "Adding DailySlots for $Days days starting today..."
for ($d = 0; $d -lt $Days; $d++) {
    $date = (Get-Date).Date.AddDays($d)
    # choose 1 or 2 species per day (use deterministic $rand)
    $countSpecies = $rand.Next(1, $species.Length + 1)
    if ($countSpecies -eq 1) {
        $chosen = @($species[$rand.Next(0, $species.Length)])
    }
    else {
        # choose all species (only 2 in list currently)
        $chosen = $species
    }
    foreach ($s in $chosen) {
        $slotCount = $rand.Next(1, [Math]::Max(2, [int]([Math]::Ceiling($Customers / 10))))
        # Ensure we don't set TotalSlots to a value smaller than already-reserved slots
        $dateStr = $date.ToString('yyyy-MM-dd')
        try {
            $existing = Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "SELECT ReservedSlots FROM DailySlots WHERE SlotDate = '$dateStr' AND Species = '$s' LIMIT 1;" | Select-Object -First 1
            $reserved = if ($existing -and ($null -ne $existing.ReservedSlots)) { [int]$existing.ReservedSlots } else { 0 }
        }
        catch {
            # If query fails (table doesn't exist yet), assume 0
            $reserved = 0
        }

        if ($slotCount -lt $reserved) { $slotCount = $reserved }

        Add-AvailableSlot -Date $date -Type $s -SlotCount $slotCount -Mode Set | Out-Null
    }
}
Write-Host "Added DailySlots."

Write-Host "Creating $Orders orders..."
$createdOrders = [System.Collections.Generic.List[int]]::new()
for ($o = 1; $o -le $Orders; $o++) {
    $cust = $createdCustomers[$rand.Next(0, $createdCustomers.Count)]
    $sp = $species[$rand.Next(0,$species.Length)]
    $drop = (Get-Date).Date.AddDays($rand.Next(0, [Math]::Max(1,$Days)))
    $orderId = (New-Order -CustomerId $cust -Species $sp -Portion 'Half' -DropOffDate $drop).OrderId
    $createdOrders.Add([int]$orderId) | Out-Null

    if ($rand.NextDouble() -lt 0.5) {
        try { Register-OrderSlot -OrderId $orderId -SlotDate $drop } catch { }
    }
}
Write-Host "Created $($createdOrders.Count) orders (some registered)."

# Summary counts
$counts = Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query @"
SELECT
 (SELECT COUNT(1) FROM Customers) AS Customers,
 (SELECT COUNT(1) FROM DailySlots) AS DailySlots,
 (SELECT COUNT(1) FROM Orders) AS Orders
"@ | Select-Object -First 1

Write-Host "Seed summary: Customers=$($counts.Customers) DailySlots=$($counts.DailySlots) Orders=$($counts.Orders)"

return @{ Customers = $counts.Customers; DailySlots = $counts.DailySlots; Orders = $counts.Orders }
