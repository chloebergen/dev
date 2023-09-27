# SharePoint site URL:
$spUrl = "https://careplasticsurgery.sharepoint.com/sites/CarePlasticSurgeryPA-BusinessAdministration"

# Connect to SharePoint
Connect-PnPOnline -Url $spUrl -Interactive 

# Restore time-period
$today = (Get-Date) 
$dateFrom = $today.date.addDays(-10)
$dateTo = $today.date.addDays(-2)

# Set user to find files from
$deletedByUser = "drcoan@careplasticsurgery.com"

# Show dates
Write-Host "Finding files from $dateFrom to $dateTo..." -ForegroundColor Cyan

# Retrieves all items that were deleted X days ago and displays a list of the last 10 items for validation
Get-PnPRecycleBinItem | Where-Object {($_.DeletedDate -gt $dateFrom -and $_.DeletedDate -lt $dateTo) -and ($_.DeletedByEmail -eq $deletedByUser)}  | Select-Object -last 10 | ft *

# Confirm test results
$confirmation = Read-Host "Are the result as aspected? [y/n]"
if ($confirmation -eq 'y') {
  Write-Host "Restoring items..." -ForegroundColor Cyan
  Get-PnPRecycleBinItem -firststage -rowlimit 10000 | 
    Where-Object {($_.DeletedDate -gt $dateFrom -and $_.DeletedDate -lt $dateTo) -and ($_.DeletedByEmail -eq $deletedByUser)} | 
    Restore-PnpRecycleBinItem -Force

  Write-Host "Restore completed" -ForegroundColor Green
}


###### Successful ######

Install-Module SharePointPnPPowerShellOnline
Import-Module SharePointPnPPowerShellOnline

$siteURL = "https://careplasticsurgery.sharepoint.com/sites/CarePlasticSurgeryPA-BusinessAdministration"
Connect-PnPOnline -Url $siteURL -Interactive

$deletedByUser = "who@domain.com"

## How many files in recycle bin?
(Get-PnPRecycleBinItem).count

## Filter by email
Get-PnPRecycleBinItem -FirstStage | ? DeletedByEmail -eq $deletedByUser

## Validate
Get-PnPRecycleBinItem | Where-Object {($_.DeletedByEmail -eq $deletedByUser)} | Select-Object -last 10 | Format-Table *

## Export to CSV
Get-PnPRecycleBinItem | Where-Object {($_.DeletedByEmail -eq $deletedByUser)} | Export-Csv c:\temp\restore.csv

## Send it, brother 
Get-PnPRecycleBinItem -FirstStage | Where-Object {($_.DeletedByEmail -eq $deletedByUser)} | Restore-PnpRecycleBinItem -Force


##### Add this to it to not restore dupes
recycleBin = Get-PnPRecycleBinItem

$recycleBin | ForEach-Object {
    $dir = $_.DirName
    $title = $_.Title
    $path = "$dir/$title"

    $fileExists = Get-PnPFile -url $path -ErrorAction SilentlyContinue

    if ($fileExists) {
        Write-Host "$title exists"
    } else {
        Write-Host "$title Restoring"
        $_ | Restore-PnpRecycleBinItem -Force
    }
}
