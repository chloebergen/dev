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
