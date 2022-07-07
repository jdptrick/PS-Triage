Write-Host "`r`n[+] Terminal Services Logons: `r`n"
Write-Host "+++++++++++++++++++++++++++++++++++++++++"
$Before = Get-Date 2022/07/08
$After = Get-Date 2022/07/06
Get-WinEvent -FilterHashtable @{ LogName='Security'; StartTime=$After; EndTime=$Before; Id='4624'} | where {$_.Message -match "Logon Type:\s+10"} | Select-Object TimeCreated,Message

