Write-Host "`r`n[+] Recently Written Files `r`n"
Write-Host "+++++++++++++++++++++++++++++++++++++++++"

$recentFiles = Get-ChildItem -Path C:\ -Filter *.exe -Recurse -ErrorAction SilentlyContinue -Force | ? {$_.LastWriteTime -gt (Get-Date).AddDays(-1)} | select -exp FullName

foreach($file in $recentFiles) {
    Write-Host $file
}

#Check for Alternaste Data Streams
Write-Host "`r`n[+] FIles with ADS: `r`n"
Write-Host "+++++++++++++++++++++++++++++++++++++++++"

#Loop that will return all friles htat have NTFS ADS
Foreach($file in $recentFiles){
    Get-Item $file -stream * | ? stream -NE ':$Data'
}