function Disable-OneDriveFile {
    [CmdletBinding()]
    param (
        # Specifies a path to one or more locations. Unlike the Path parameter, the value of the LiteralPath parameter is
        # used exactly as it is typed. No characters are interpreted as wildcards. If the path includes escape characters,
        # enclose it in single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any
        # characters as escape sequences.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName="LiteralPath",
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   HelpMessage="Literal path to one or more locations.")]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $LiteralPath
    )
    
    begin {
        
    }
    
    process {
        foreach ($ODPath in $LiteralPath){
            $FileObject = Get-Item -LiteralPath $ODPath
            
            # we need to test if the file is ok to offline
            # we know that synced files show as a reprase point
            # which is attribute value 1024 or 0x400
            if ($FileObject.Attributes.value__ -band 0x400) {
                # we should check if the file is already
                # since there is no point in updating offlines files already
                # we use an -eq here as we want to test all the bits above 0xFF

                if ( ($FileObject.Attributes.value__ -band 0x501600) -eq 0x501600 ) {
                    # looks too much like an off line file already.
                    Write-Error "The Path $OdPath appears to already be set to offline." -TargetObject $ODPath

                } else {
                    # we want to take the existing attributes below 0x100 as they
                    # are regular attributes.
                    $regAttributes = $FileObject.Attributes -band 0xFF

                    ## now combinde at with the "magic number"
                    # we need to use this method to create our magic number as
                    # the needed attributes are not present on the enum

                    $newAttributes = $regAttributes -bor ([enum]::Parse([System.IO.FileAttributes], 0x501620))

                    Write-Verbose "Updating file $OdPath with new attributes: $newAttributes"
                    $FileObject.Attributes = $newAttributes
                }
            } else {
                Write-Error "The Path $OdPath is either not a OneDrive file using files on demand, or has not completed syncing." -TargetObject $ODPath
            }
        }
    }
    
    end {
        
    }
}