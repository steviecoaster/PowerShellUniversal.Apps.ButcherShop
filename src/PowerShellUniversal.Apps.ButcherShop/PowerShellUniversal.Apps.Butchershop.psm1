# Dot source all public and private functions (cross-platform paths)
$Public = @( Get-ChildItem -Path (Join-Path $PSScriptRoot 'functions' 'public' '*.ps1') -Recurse -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path (Join-Path $PSScriptRoot 'functions' 'private' '*.ps1') -ErrorAction SilentlyContinue )

# Dot source the functions so helper functions are available for initialization
foreach ($import in @($Public + $Private)) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
}
