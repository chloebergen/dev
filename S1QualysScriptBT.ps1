## Remove old files + create installation directories.
Remove-Item -Path "C:\Temp\BTS\*.*" -Force -ErrorAction SilentlyContinue

$testPath = "C:\Temp\BTS"
if (Test-Path $testPath -PathType Container) {
    Write-Host "Directory already exists."
} else {
    New-Item -Path "C:\Temp\BTS" -ItemType Directory
}


## Download S1
$installUrlS1= "https://www.dropbox.com/s/af8q1eld9096edf/SentinelInstaller_windows_64bit_v22_3_4_612.msi?dl=1"
$installPathS1 = "C:\Temp\BTS\"
$filenameS1 = "SentinelInstaller_windows.msi"

if (Get-Command Invoke-WebRequest -ErrorAction SilentlyContinue) {
    Invoke-WebRequest -Uri "$installUrlS1" -OutFile "$installPathS1\$filenameS1"
} else {
    (New-Object Net.WebClient).DownloadFile($installUrlS1, "$installPathS1\$filenameS1")
}


## Install S1 via msiexec
$installerS1 = "$installPathS1\$filenameS1"
Start-Process "msiexec.exe" -ArgumentList "/i $installerS1 /qn Site_token=eyJ1cmwiOiAiaHR0cHM6Ly91c2VhMS1kZmlyLnNlbnRpbmVsb25lLm5ldCIsICJzaXRlX2tleSI6ICI1ODA4NDdlYTBjZWJmZmMxIn0=" -Wait


#################
#################

## Download Qualys
$installUrlQ= "https://www.dropbox.com/scl/fi/lzik8a22jkem3vz7ijwrf/Eye_Specialty_Group-4254.msi?rlkey=8uru193s2810n0jeindjpt7fz&dl=1"
$installPathQ = "C:\Temp\BTS\"
$filenameQ = "QualysInstaller.msi"

if (Get-Command Invoke-WebRequest -ErrorAction SilentlyContinue) {
    Invoke-WebRequest -Uri "$installUrlQ" -OutFile "$installPathQ\$filenameQ"
} else {
    (New-Object Net.WebClient).DownloadFile($installUrlQ, "$installPathQ\$filenameQ")
}


## Install Qualys via msiexec
$installerQ = "$installPathQ\$filenameQ"
Start-Process "msiexec.exe" -ArgumentList "/i $installerQ /qn" -Wait