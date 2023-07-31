# Path of the application
$appPath = "C:\PN\CloudLoader\PatientNowCloudLoader.exe"
$errorPath = "C:\PN\CloudLoader\AutomationError.txt"

# Abort if the manifest file already exists.
$errorMessage = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')]"
function ManifestExists {
if ($null -eq $appPath.manifest) {
    Write-Error "$errorMessage Manifest has been applied previously."
    Exit
} else {
    Write-Host "Manifest has not been applied previously, continuing with application."
}
}
ManifestExists 2>&1 > $errorPath

# If PatientNow is currently running as any user, the process will terminate.
$processPN = Get-Process -name "*PatientNow*"
if ($null -ne $processPN) {
Stop-Process -InputObject $processPN
Get-Process | Where-Object {$_.HasExited}
} else {
    Write-Host "PatientNow is not running currently, proceeding..."}

# Adds an application compatibility entry to prevent UAC prompts for the specified application
Write-Host "Disabling UAC for PatientNow..."
$manifestPath = "$appPath.manifest"
@"
<?xml version='1.0' encoding='UTF-8' standalone='yes'?>
<assembly xmlns='urn:schemas-microsoft-com:asm.v1' manifestVersion='1.0'>
    <trustInfo xmlns="urn:schemas-microsoft-com:asm.v3">
        <security>
            <requestedPrivileges>
                <requestedExecutionLevel level='asInvoker' uiAccess='false' />
            </requestedPrivileges>
        </security>
    </trustInfo>
</assembly>
"@ | Out-File -Encoding ASCII $manifestPath

# Applies the manifest file to the application
Write-Host "Applying the compatibility manifest to PatientNow..."
cmd.exe /c "mt.exe -manifest $manifestPath -outputresource:`"$appPath`;#1"
Write-Host "UAC prompts have been disabled for PatientNow."

#######  Testing Policy #######
## Variables
$GetPolicy = Get-ExecutionPolicy -List
$SetPolicy = Set-ExecutionPolicy Unrestricted
$hasChangePolicyTriggered = $false

## Change the ExecutionPolicy if it would give us errors running our script. 
if ($GetPolicy -ne "Unrestricted"){
    $SetPolicy
    Write-Error "Changing the Execution Policy to Unrestricted... "
    $hasChangePolicyTriggered = $true
}

## Revert the ExecutionPolicy back after the script is done runniung.
$RevertPolicy = Set-ExecutionPolicy Default

if ($hasChangePolicyTriggered -eq $true){
    $RevertPolicy
    Write-Host "Reverting the Execution Policy back to system defaults..."

}











#######  Testing OneDrive Files-on-Demand  #######

Get-ChildItem $ENV:OneDriveCommercial -Force -File -Recurse -ErrorAction SilentlyContinue |
Where-Object {$_.Attributes -match 'ReparsePoint' -or $_.Attributes -eq '525344' } |
ForEach-Object {
    attrib.exe $_.fullname +U -P /s
}


Get-ChildItem -Path "C:\Users\kmyers\Medbridge Development" -Force -File -Recurse -ErrorAction SilentlyContinue |
Where-Object {$_.Attributes -match 'ReparsePoint' -or $_.Attributes -eq '525344' } |
ForEach-Object {
    attrib.exe $_.fullname +U -P /s
}



#######  Testing...  #######


Locally Available (1.ps1) -> has no attribute number, just the 'regular' Archive/ReparsePoint
Always Available (2.ps1) -> Has the attribute 525344
Online Available (3.ps1) -> Has the attribute 5248544



# (Online only)
# attrib +u "Full Path"

# (Locally available)
# attrib -p "Full Path"

# (Always available)
# attrib +p "Full Path"



# attrib /?
# +   Sets an attribute.
# -   Clears an attribute.
# R   Read-only file attribute.
# A   Archive file attribute.
# S   System file attribute.
# H   Hidden file attribute.
# O   Offline attribute.
# I   Not content indexed file attribute.
# X   No scrub file attribute.
# V   Integrity attribute.
# P   Pinned attribute.
# U   Unpinned attribute.
# B   SMR Blob attribute.
# [drive:][path][filename]
#     Specifies a file or files for attrib to process.
# /S  Processes matching files in the current folder
#     and all subfolders.
# /D  Processes folders as well.
# /L  Work on the attributes of the Symbolic Link versus
#     the target of the Symbolic Link #>



#### Disk Space #### 

Get-ChildItem -Directory | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse | Measure-Object Length -Sum).Sum / 1Gb
    [PSCustomObject]@{
        FolderName = $_.Name
        Size       = $size
    }
}

-ErrorAction 'SilentlyContinue'


## Disk Cleanup

Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/d [driveletter]:", "/sageset:allsettings"
Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:allsettings"

## ?? cleanmgr /verylowdisk

cleanmgr /verylowdisk


## Storage Sense
Function Enable-StorageSense{
    # Enable Storage Sense
    # Enable deleting temp files, Enable daily cleanup
    # Dehydrate onlne files after 180 days
    # Clean Recycle Bin of files older than 7 days
    # Clean Downloads of files older than 180 days
    reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\StorageSense" /V "AllowStorageSenseGlobal" /T REG_DWORD /d "1" /f
    reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\StorageSense" /V "AllowStorageSenseTemporaryFilesCleanup" /T REG_DWORD /d "1" /f
    reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\StorageSense" /V "ConfigStorageSenseGlobalCadence" /T REG_DWORD /d "1" /f
    reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\StorageSense" /V "ConfigStorageSenseCloudContentDehydrationThreshold" /T REG_DWORD /d "180" /f
    reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\StorageSense" /V "ConfigStorageSenseRecycleBinCleanupThreshold" /T REG_DWORD /d "7" /f
    reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\StorageSense" /V "ConfigStorageSenseDownloadsCleanupThreshold" /T REG_DWORD /d "180" /f
}


##  GPO for clear profiles older than X 
# (Administrative Templates > System > User Profiles) 

# OneDrive GPO
https://learn.microsoft.com/en-us/sharepoint/use-group-policy


[HKLM\SOFTWARE\Policies\Microsoft\OneDrive]"FilesOnDemandEnabled"=dword:00000001



HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList