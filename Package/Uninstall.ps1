$packageName = "IntuneShortcuts"
$packageVersion = "1.0"

$configPath = "C:\Intune"
$publicPath = "C:\Users\Public\Desktop"
$repoPath = "$configPath\$packageName-main"

$shortcuts = Import-Csv -Path "$repoPath\Apps.csv"
foreach ($shortcut in $shortcuts) {
    Remove-Item -Path "$publicPath\$($shortcut.Name).lnk" -Force
}

Get-ChildItem -Path $repoPath -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force
Remove-Item -Path $repoPath -Force
