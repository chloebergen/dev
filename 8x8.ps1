## Package Manager 
## Make sure to use PS5.1, not PS Core 7 -- 7 doesn't seem to show msi/msu/Programs as Package Providers..?
$providers = Get-PackageProvider | Select-Object Name
Write-Host $providers

$programList = Get-Package -Name '*8x8*' | Select-Object Name, ProviderName, CanonicalId, Version
if ($true -eq $programList){
    foreach ($program in $programList){
        Write-Host "Uninstalling pre-existing applications..."
        Uninstall-Package -Verbose
    }
}



## WMI Objects
$programList = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -like 'Threatlocker'}
if ($true -eq $programList){
foreach ($program in $programList){
    Write-Host "Uninstalling pre-existing applications..."
    Uninstall-Program -Verbose
    }
}



