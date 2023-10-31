## Remove old files + create installation directories.
Remove-Item -Path "C:\MedicusIT\8x8\*.*" -Force -SilentlyContinue

$testPath = "C:\MedicusIT"
if (Test-Path $testPath -PathType Leaf){
    Write-Host "MedicusIT directory already exists."
} else 
    {New-Item -Path "C:\MedicusIT" -ItemType Directory}

$testPath2 = "C:\MedicusIT\8x8"
if (Test-Path $testPath2 -PathType Leaf){
    Write-Host "8x8 directory already exists."
} else 
    {New-Item -Path "C:\MedicusIT\8x8" -ItemType Directory}

# Set .Net to TLS1.2 (3072)
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

## Process Killer
$process8x8 = Get-Process -Name '*8x8*'
if ($null -ne $process8x8) {
    Stop-Process -InputObject $process8x8 -Force
    Get-Process | Where-Object {$_.HasExited}
} else {
    Write-Host "8x8 is not currently running, continuing.."}


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


## Download 8x8 
$installUrl= "https://vod-updates.8x8.com/ga/work-64-msi-v8.7.2-3.msi"
$installPath = "C:\MedicusIT\8x8"
$filename = "work-64-msi-v8.7.2-3.msi"

if (Get-Command Invoke-WebRequest -ErrorAction SilentlyContinue) {
    Invoke-WebRequest -Uri "$installUrl" -OutFile "$installPath\$filename"
} else {
    (New-Object Net.WebClient).DownloadFile($installUrl, "$installPath\$filename")
}


## Install 8x8
$installer = "$installPath\$filename"
Start-Process msiexec "/i $installer /qn /norestart"


## Check if successful
$test = Get-Package -Name '*8x8*'

if($test -eq $true){
    Write-Host "8x8 installed successfully."
} else { 
    Write-Error "8x8 failed to install."
}









###############################
######### WMI Version #########
###############################

## WMI Objects
$programList = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -like 'Threatlocker'}
if ($true -eq $programList){
foreach ($program in $programList){
    Write-Host "Uninstalling pre-existing applications..."
    Uninstall-Program -Verbose
    }
}


$check = get-wmiobject -class win32_product | Where-Object {$_.Name -like $programInstallName}

if($check)
  {
    Write-Host "$programInstallName installed successfully."
    exit 0
  }
else
  { 
    Write-Error "$programInstallName failed to install."
    exit 1
  }
