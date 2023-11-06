$directoryToKill = "C:\PN\*"

# Get all processes with executable paths starting with the specified directory
$processesToKill = Get-Process | Where-Object { $_.MainModule.FileName -like "$directoryToKill*" }


$processesToKill | ForEach-Object { Stop-Process -InputObject $_ -Force -Verbose; $_.WaitForExit() }


# All processes from the specified directory have been terminated
Write-Host "All processes in $directoryToKill have been successfully terminated."


