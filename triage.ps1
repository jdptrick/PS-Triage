# #Check for Recently Written Files

# Write-Host "`r`n[+] Recently Written Files `r`n"
# Write-Host "+++++++++++++++++++++++++++++++++++++++++"

# $recentFiles = Get-ChildItem -Path C:\ -include ('*.exe') -Recurse -ErrorAction SilentlyContinue -Force | ? {$_.LastWriteTime -gt (Get-Date).AddDays(-1)} | select -exp FullName

# foreach($file in $recentFiles) {
    # Write-Host $file
# }

# #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# #Check for Alternaste Data Streams in Recently Written Files

# Write-Host "`r`n[+] Files with ADS: `r`n"
# Write-Host "+++++++++++++++++++++++++++++++++++++++++"

# Foreach($file in $recentFiles){
    # Get-Item $file -stream * | ? stream -NE ':$Data'
# }

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Check Scheduled Tasks

Write-Host "`r`n[+] Scheduled Tasks: `r`n"
Write-Host "+++++++++++++++++++++++++++++++++++++++++"

$tasks = Get-ChildItem "C:\Windows\System32\Tasks" -Recurse

ForEach($task in $tasks){
    Write-Host "`r`n[+] Task: $task"
    Write-Host "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++`r`n"
    Get-Content $task -ErrorAction SilentlyContinue | Select-String -Pattern '<Command>' -SimpleMatch
}

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Check Services

Write-Host "`r`n[+] Services: `r`n"
Write-Host "+++++++++++++++++++++++++++++++++++++++++"

Get-WmiObject win32_service | select Name, DisplayName | Format-List

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Check Run/RunOnce registry keys for Machine and User

Write-Host "`r`n[+] Run/RunOnce Registry Keys `r`n"
Write-Host "+++++++++++++++++++++++++++++++++++++++++"

#Define array with registry values (machine keys)
$sysKeys = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run", "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunOnce"

#Create for loop to loops through the array and create var out of each key in array
ForEach($key in $sysKeys){
    Get-ItemProperty Registry::$key
}

#Each user assigned SID, so need to search and find the SID's (wont start with S-1-5-18-20, those are reserved for system) and then find the Current User Run registry keys
$users = (Get-WmiObject Win32_UserProfile | Where-Object { $_.SID -notmatch 'S-1-5-(18|19|20).*' })

#gets the local path of each user
$userPaths = $users.localpath

#gets the sid of each user from the atrributes listed in the $users var
$UserSIDs = $users.sid

#Each time through loop, load path and sid into the vars. Once loaded query each users registry keys.
for ($counter = 0; $counter -lt $users.Length; $counter++) {
    $path = $users[$counter].localpath
    $sid = $users[$counter].sid
    reg load hku\$sid $path\ntuser.dat
}

Get-ItemProperty Registry::\hku\*\software\microsoft\windows\currentversion\run;
Get-ItemProperty Registry::\hku\*\software\microsoft\windows\currentversion\runonce;

ForEach($key in $sysKeys){
    Get-ItemProperty Registry::$key
}

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Check logons via terminal services (RDP, WMI, PSExec)

Write-Host "`r`n[+] Terminal Services Logons: `r`n"
Write-Host "+++++++++++++++++++++++++++++++++++++++++"

$After = Get-Date 2022/7/6
$Before = Get-Date 2022/7/8
Get-WinEvent -FilterHashtable @{ LogName='Security'; StartTime=$After; EndTime=$Before; Id='4624'} | Where-Object {$_.Message -match 'Logon Type:		(3|10)'} 