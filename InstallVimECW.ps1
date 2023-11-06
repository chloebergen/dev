$ConfirmPreference = "None"
$transcriptPath = "C:\MedicusIT\VimECW\Transcript.txt"
Start-Transcript -Path $transcriptPath -Append

 ## Remove old files + create installation directories.
Remove-Item -Path "C:\MedicusIT\VimECW\*.*" -Force -ErrorAction SilentlyContinue

$testPath = "C:\MedicusIT"
if (Test-Path $testPath -PathType Container) {
    Write-Host "MedicusIT directory already exists."
} else 
    {New-Item -Path "C:\MedicusIT" -ItemType Directory
}

$testPath2 = "C:\MedicusIT\VimECW"
if (Test-Path $testPath2 -PathType Container) {
    Write-Host "VimECW directory already exists."
} else 
    {New-Item -Path "C:\MedicusIT\VimECW" -ItemType Directory
}


# Set .Net to TLS1.2 (3072)
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

## Download VimECW 
$installUrl= "https://vim.health/desktop_ecw"
$installPath = "C:\MedicusIT\VimECW"
$filename = "vim-connect-ecw-1.80.0.msi"

if (Get-Command Invoke-WebRequest -ErrorAction SilentlyContinue) {
    Invoke-WebRequest -Uri "$installUrl" -OutFile "$installPath\$filename"
} else {
    (New-Object Net.WebClient).DownloadFile($installUrl, "$installPath\$filename")
}


## Install MSI
$installer = "$installPath\$filename"
$installLog = "C:\MedicusIT\VimECW\InstallLog.txt"
Start-Process -Wait $env:systemroot\system32\msiexec.exe -ArgumentList "/i $installer PRODUCT_KEY=unzBthe5Zs4g36b8uKLdzh RUN_ON_STARTUP=true /LV ""$installLog"""

## Check if successfully installed
$test = Get-Package -Name '*Vim*'

if($test.Count -gt 0) {
    Write-Host "Vim Connect ECW has been installed successfully."
} else { 
    Write-Error "Vim Connect ECW failed to install."
}

$ConfirmPreference = "High"