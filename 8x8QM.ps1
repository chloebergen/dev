## This script removes the previous version of 8x8 QM Live Monitoring, downloads the new one, and installs it via msiexec.
## Author: Chloe Bergen (https://github.com/chloebergen)

$ConfirmPreference = "None"
Install-PackageProvider -Name "NuGet" -Confirm:$false -Force

## Remove old files + create installation directories.
Remove-Item -Path "C:\MedicusIT\8x8\ScreenRecorder\*.*" -Force -ErrorAction SilentlyContinue

$testPath = "C:\MedicusIT\8x8\ScreenRecorder"
if (Test-Path $testPath -PathType Container) {
    Write-Host "8x8 Screen Recorder directory already exists."
} else {
    New-Item -Path "C:\MedicusIT\8x8\ScreenRecorder" -ItemType Directory
}

## Creates a transcript 
$transcriptPath = "C:\MedicusIT\8x8\ScreenRecorder\Transcript.txt"
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

$programList = Get-Package -Name '*8x8 Quality Management*' | Select-Object Name, ProviderName, CanonicalId, Version 
if ($true -eq $programList) {
    foreach ($program in $programList) {
        Write-Host "Uninstalling pre-existing applications..."
        Uninstall-Package $program.Name
    }
}

## Download 8x8 Screen Recorder
$installUrl= "https://qm-screen-recorder.8x8.com/Windows/ScreenRecorderSetup-6.2.2.msi"
$installPath = "C:\MedicusIT\8x8\ScreenRecorder"
$filename = "ScreenRecorderSetup-6.2.2.msi"   

if (Get-Command Invoke-WebRequest -ErrorAction SilentlyContinue) {
    Invoke-WebRequest -Uri "$installUrl" -OutFile "$installPath\$filename"
} else {
    (New-Object Net.WebClient).DownloadFile($installUrl, "$installPath\$filename")
}

## Install via msiexec
$installer = "$installPath\$filename"
Start-Process "msiexec.exe" -ArgumentList "/i $installer /qn /norestart" -NoNewWindow -Wait

## Check if successful
$test = Get-Package -Name '*8x8 Quality Management*'

if($test.Count -gt 0) {
    Write-Host "8x8 Quality Management installed successfully."
} else { 
    Write-Error "8x8 Quality Management failed to install."
}

Stop-Transcript
$ConfirmPreference = "High"