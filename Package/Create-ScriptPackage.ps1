param (
    [Parameter()][string]$Path
)


# Check/install IntuneWin32App module
if (!(Get-Module -ListAvailable -Name IntuneWin32App)) {
    try { Install-Module -Name IntuneWin32App -Force -Confirm:$false -ErrorAction Stop -WarningAction SilentlyContinue }
    catch { throw "Error installing IntuneWin32App module: $_" }
}


# Process path
if (!$Path) {
    $Path = $PSScriptRoot
    Write-Host "`"-Path`" not specified, using script root." -ForegroundColor Yellow
}
Write-Host "Checking for script at specified path..."
Start-Sleep 1


# Check for scripts
try { $setupFile = (Get-ChildItem $Path\*.ps1 -ErrorAction Stop).Name }
catch { throw $($_.Exception.Message) }

if (!$setupFile) { throw "No scripts found in $Path" }
if ($setupFile.count -gt 1) {
    $found = $false
    Write-Host "Multiple scripts found in $Path"
    Start-Sleep 1
    while (!$found) {
        $script = Read-Host "`nPlease enter the name of the script to package"
        try {
            $setupFile = (Get-ChildItem $Path\$script.ps1 -ErrorAction Stop).Name
            $found = $true
        }
        catch {
            Write-Host "Could not find script with the name: `"$script.ps1`""
        }
    }
}


# Create .intunewin file
$params = @{
    SourceFolder  = $Path
    OutputFolder  = $Path
    SetupFile     = $setupFile
    Force         = $true
    ErrorAction   = "Stop"
    WarningAction = "Stop"
}

try {
    $packagedApp = New-IntuneWin32AppPackage @params
    Write-Host "`n$($packagedApp.Path) packaged successfully." -ForegroundColor Green
    Read-Host "`nPress Enter to exit"
    Exit 0
}
catch { throw "Error creating .intunewin file: $($_.Exception.Message)" }
