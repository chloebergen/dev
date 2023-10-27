####### Export DL to CSV
Connect-ExchangeOnline -UserPrincipalName $their-UPN-goes-here
$DistributionList = "Everyone@trueyouweightloss.com" 
$CSVFilePath = "C:\Temp\DL-Members.csv"

#Get DL Members and Exports to CSV
    Get-DistributionGroupMember -Identity $DistributionList -ResultSize Unlimited | Select DisplayName, PrimarySMTPAddress, RecipientType | sort-object DisplayName | Export-Csv $CSVFilePath -NoTypeInformation

# Same but DDL, 
    Get-DynamicDistributionGroupMember -Identity $DistributionList -ResultSize Unlimited | Select DisplayName, PrimarySMTPAddress, RecipientType | sort-object DisplayName | Export-Csv $CSVFilePath -NoTypeInformation