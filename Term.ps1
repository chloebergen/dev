### Notes 
## Add lines to remove user from their current manager/direct report
# Make an interactive dialogue window where you can enter UNCs
Import-Module MSOnline
$userAccount = "yes@no.com"

#Block 1
Set-AzureADUser -ObjectID $userAccount -AccountEnabled $false
#Check if blocked
Get-AzureADUser  -ObjectID $userAccount | Select-Object DisplayName,AccountEnabled

## Set random PW
Set-MsolUserPassword -UserPrincipalName $userAccount -ForceChangePassword

## Block Multiple -- can use Get-Content -Path too
$userList = "yes@no.com"
foreach ($user in $userList)
    {Set-AzureADUser -ObjectID $_ -AccountEnabled $false}

## Convert to Shared
Set-Mailbox -Identity $userAccount -Type Shared
Get-Mailbox -Identity $userAccount | Format-List Name,RecipientTypeDetails,UserPrincipalName,AccountDisabled

# Hide from GAL
Set-Mailbox -Identity $userList -HiddenFromAddressListsEnabled $true

## License removal
$licensedUsers = Get-MgUser -UserPrincipalName $userList
foreach($user in $licensedUsers)
    {$licencesToRemove = $user.AssignedLicenses | Select-Object -ExpandProperty SkuId
    $user = Set-MgUserLicense -UserId $user.UserPrincipalName -RemoveLicenses $licencesToRemove -AddLicenses @{}}