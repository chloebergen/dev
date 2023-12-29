Import-Csv “C:\CSV\conant+report.csv” | foreach {Add-DistributionGroupMember -Identity “CorporateAP” -Member $_.alias}

----------------

$distributionGroup = "CorporateAP"
$csv = "C:\CSV\conant+report.csv"



Import-CSV $csv -Header "UPN" | 
	ForEach {
	Add-DistributionGroupMember –Identity $distributionGroup -Member $_.UPN
    Write-Host -f Green "Added User to Distribution List:"$_.UPN
}


----

Get-DistributionGroupMember -Identity "CorporateAP" | Select-Object DisplayName, PrimarySmtpAddress