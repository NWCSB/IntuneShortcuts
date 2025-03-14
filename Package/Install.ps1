$packageName = "IntuneShortcuts"
$packageVersion = "1.0"

$configPath = "C:\Intune"
$publicPath = "C:\Users\Public\Desktop"
$repoPath = "$configPath\$packageName-main"
$repoURL = "https://github.com/NWCSB/IntuneShortcuts/archive/refs/heads/main.zip"


# Create config folder
if (!(Test-Path -Path $configPath)) {
    New-Item -Path $configPath -ItemType Directory -Force | Out-Null
}

# Download repo
Invoke-WebRequest -Uri $repoURL -OutFile "$configPath\repo.zip"
Expand-Archive -Path "$configPath\repo.zip" -DestinationPath $configPath -Force
Remove-Item -Path "$configPath\repo.zip"

# Get users from device
$users = Get-ChildItem "C:\Users"

# Loop through apps in csv
$success = $true
Import-Csv -Path "$repoPath\Apps.csv" | ForEach-Object {
    try {
        $name = $_.name
        $link = $_.link
        $icon = "$repoPath\Icons\$($_.icon)"

        # Delete existing shortcuts
        foreach ($user in $users) {
            Get-ChildItem -Path "$($user.FullName)\Desktop" -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*$name*" } | Remove-Item -Force
            Get-ChildItem -Path "$($user.FullName)\OneDrive - nwcsb.com\Desktop" -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*$name*" } | Remove-Item -Force
        }

        # Create shortcut in Public Desktop
        if ($link -and $icon) { 
            $object = New-Object -ComObject WScript.Shell
            $shortcut = $object.CreateShortcut($publicPath + "\$name.lnk")
            $shortcut.TargetPath = $link
            $shortcut.IconLocation = $icon
            $shortcut.Save()
        }
    }
    catch {
        Write-Error $($_.Exception.Message)
        $success = $false
        continue
    }
}

# Create detection file if successful
if ($success) {
    New-Item -Path $repoPath -Name $PackageName -ItemType File -Value $PackageVersion -Force | Out-Null
    Write-Output "Success"
    Exit 0
}
else {
    Write-Error "Failed to create all shortcuts."
    Exit 1
}