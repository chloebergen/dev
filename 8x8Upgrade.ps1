$ConfirmPreference = "None"
$transcriptPath = "C:\MedicusIT\8x8\Transcript.txt"
Start-Transcript -Path $transcriptPath -Append

## Remove old files + create installation directories.
Remove-Item -Path "C:\MedicusIT\8x8\*.*" -Force -ErrorAction SilentlyContinue

$testPath = "C:\MedicusIT"
if (Test-Path $testPath -PathType Container) {
    Write-Host "MedicusIT directory already exists."
} else {
    New-Item -Path "C:\MedicusIT" -ItemType Directory
}

$testPath2 = "C:\MedicusIT\8x8"
if (Test-Path $testPath2 -PathType Container) {
    Write-Host "8x8 directory already exists."
} else {
    New-Item -Path "C:\MedicusIT\8x8" -ItemType Directory
}


# Transcript
Start-Transcript -Path $transcriptPath -Append

# Set .Net to TLS1.2 (3072)
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

## Process Killer
$process8x8 = Get-Process -Name '*8x8*'
if ($null -ne $process8x8) {
    Stop-Process -InputObject $process8x8 -Force
    Get-Process | Where-Object {$_.HasExited}
} else {
    Write-Host "8x8 is not currently running, continuing.."
}

## Package Manager 
## Make sure to use PS5.1, not PS Core 7 -- 7 doesn't seem to show msi/msu/Programs as Package Providers..?
$providers = Get-PackageProvider | Select-Object Name
Write-Host $providers

$programList = Get-Package -Name '*8x8*' | Select-Object Name, ProviderName, CanonicalId, Version 
if ($true -eq $programList) {
    foreach ($program in $programList) {
        Write-Host "Uninstalling pre-existing applications..."
        Uninstall-Package $program.Name
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


## Install via msiexec
$installer = "$installPath\$filename"
Start-Process "msiexec.exe" -ArgumentList "/i $installer /qn /norestart" -NoNewWindow -Wait

## Check if successful
$test = Get-Package -Name '*8x8*'

if($test.Count -gt 0) {
    Write-Host "8x8 installed successfully."
} else { 
    Write-Error "8x8 failed to install."
}