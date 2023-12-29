Import-Module ExchangeOnlineManagement 
Connect-ExchangeOnline -UserPrincipalName "name@domain.com"

## Variables
$distributionGroup = "CorporateAP"
$csv = "C:\CSV\conant+report.csv"

## Function to check if the UPNs provided exist in this tenant 
function UserExists($upn) {
    $user = Get-EXOMailbox -Identity $upn -ErrorAction SilentlyContinue
    return $user -ne $null
}

#Get Existing Members of the Distribution List
$checkMembers =  Get-DistributionGroupMember -Identity $distributionGroup -ResultSize Unlimited | Select -Expand PrimarySmtpAddress
 
## Import CSV, iterate through each row checking if UPNs exist >> adding each UPN to the specified DG
Import-CSV $csv -Header "UPN" | 
ForEach-Object {
$upn = $_.UPN
    if ((UserExists $upn) -and ($DLMembers -contains $_.UPN)){
        Write-Host -ForegroundColor Green "Added $upn to $distributionGroup"
        Add-DistributionGroupMember -Identity $distributionGroup -Member $_.UPN
    } else {
        Write-Host -ForegroundColor Yellow "$upn is already a member, or does not exist."
}}