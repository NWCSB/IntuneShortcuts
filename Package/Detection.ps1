$packageName = "IntuneShortcuts"
$packageVersion = "1.0"

$configPath = "C:\Intune"
$repoPath = "$configPath\$packageName-main"

$version = Get-Content -Path "$repoPath\$packageName" -ErrorAction SilentlyContinue

if (!$version) {
    Write-Output "Package Not Found"
    Exit 1
}

if ($version) {
    if ($version -eq $packageVersion) {
        Write-Output "Package Found: $version"
        Exit 0
    }
    else {
        Write-Output "Package Found, Wrong Version: $version"
        Exit 1
    }
}