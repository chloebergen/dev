



## Var

$dirPath = "C:\Users"
$dirGet = Get-ChildItem $dirPath -Directory
$dirBefore = Get-Date "01-Jan-2022"
$keep = "Public","Promedical","PMIT_ADMIN","admin",""


## Pew pew

foreach ($directory in $dirGet) {
    if ($directory.LastWriteTime -lt $dirBefore) -and ($directory.Name -notin $keep){
        Write-Host "Deleting $($directory.FullName)...."
        Remove-Item -Path $directory.FullName -Recurse -Force
    }
}


###########################







## Var

$dirPath = "C:\Users\cbergen\OneDrive - Medicus IT LLC\\Desktop\TestPWSH"
$dirGet = Get-ChildItem $dirPath -Directory
$keep = "Public","Yay","Lol"


## Pew pew

foreach ($directory in $dirGet){
    if ($directory.Name -notin $keep){
        Write-Host "Deleting $($directory.FullName)...."
        Remove-Item -Path $directory.FullName -Recurse -Force
    }
}








