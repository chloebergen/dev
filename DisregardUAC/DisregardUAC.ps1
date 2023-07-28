# Path of the application
$appPath = "C:\PN\CloudLoader\PatientNowCloudLoader.exe"

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
