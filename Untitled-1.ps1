## "Chloe can't take a joke"

$oneDrivePath = "%USERPROFILE%\OneDrive - Medicus IT LLC\"
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"

if ($null -eq $oneDrivePath){
    Write-Error "Oopsie!"
    Exit
}

Set-ItemProperty -Path $regPath -Name "Desktop" -Value "$oneDrivePath\Desktop"
Set-ItemProperty -Path $regPath -Name "Documents" -Value "$oneDrivePath\Documents"
Set-ItemProperty -Path $regPath -Name "Pictures" -Value "$oneDrivePath\Pictures"


$whyMicrosoftWhy = "🥲🥲🥲🥲🥲"
Write-Host $whyMicrosoftWhy

