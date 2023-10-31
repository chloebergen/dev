Get-MsolUser -All | Set-MsolUserPassword -ForceChangePasswordOnly $true -ForceChangePassword $true



Get-MsolUser -All | Set-MsolUserPassword -ForceChangePasswordOnly $true -ForceChangePassword $true


$userList = Get-MsolUser -All
foreach ($user in $userList)
    Revoke-AzureADUserAllRefreshToken
    Set-MsolUserPassword -ForceChangePasswordOnly $true -ForceChangePassword $true
    Write-Host $





    Set-ADAccountPassword -Identity johndoe -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd1" -Force)
Set-ADAccountPassword -Identity johndoe -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd2" -Force)




###############

## Connect
Connect-MgGraph -Scopes Directory.AccessAsUser.All, Directory.ReadWrite.All, User.ReadWrite.All
Select-MgProfile Beta

## PW Hashtable 
$passwordprofile = @{}
$passwordprofile["Password"] = "verycomplicatedpasswordthatyoushouldchangeorgenerateautomaticallyideally"
$passwordprofile["forceChangePasswordNextSignIn"] = $True
$passwordprofile["forceChangePasswordNextSignInWithMfa"] = $False


#####

$upnOfAdminAccount = promedical@whateverdomain.onmicrosoft.com
$UsersToChangePassword = Get-MgUser -All -Property UserPrincipalName, Id | Where-Object {$_.DisplayName -ne "$upnOfAdminAccount"}
$CSVOutput = @()

foreach ($UserToChangePassword in $UsersToChangePassword) {
    #Preparing variables
    $UserUPN = $UserToChangePassword.UserPrincipalName
    $UserID = $UserToChangePassword.Id

    #Creating a random strong password
    Add-Type -AssemblyName 'System.Web'
    $NewPassword = [System.Web.Security.Membership]::GeneratePassword(16, 3)

    #Defining the Password Profile
    $passwordprofile = @{}
    $passwordprofile["Password"] = $NewPassword
    $passwordprofile["forceChangePasswordNextSignIn"] = $True
    $passwordprofile["forceChangePasswordNextSignInWithMfa"] = $False
    
    Write-Output "Getting the current password profile for user $UserUPN..."
    $CurrentPasswordProfile = Get-MgUser -UserId $UserID -Property * | Select-Object -ExpandProperty 'PasswordProfile' | Format-List
    $CurrentPasswordProfile
    
    Write-Output "Updating the password profile for user $UserUPN..."
    try {
        Update-MgUser -UserId $UserID -PasswordProfile $passwordprofile -ErrorAction Stop
        Write-Output "Password updated successfully for user $UserUPN..."
        $CSVOutput += [PSCustomObject]@{
            UserPrincipalName = $UserUPN
            NewPassword       = $NewPassword
            Status            = "Success"
        }
    }
    catch {
        Write-Output "Password update failed for user $UserUPN..."
        $CSVOutput += [PSCustomObject]@{
            UserPrincipalName = $UserUPN
            NewPassword       = $NewPassword
            Status            = "Failed"
        }
        Write-Warning $_.Exception.Message
    }  
    
    Write-Output "Getting the updated password profile for user $UserUPN..."
    $CurrentPasswordProfile = Get-MgUser -UserId $UserID -Property * | Select-Object -ExpandProperty 'PasswordProfile' | Format-List
    $CurrentPasswordProfile

}

$CSVOutput | Export-Csv -Path "C:\Temp\passwordtoresetoutput.csv" -NoTypeInformation