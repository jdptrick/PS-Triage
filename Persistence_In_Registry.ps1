#Persistence in Registry
# Define array with registry values (machine keys)
$sysKeys = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run", "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunOnce"

#Create for loop to loops through the array and create var out of each key in array
ForEach($key in $sysKeys){
    Get-ItemProperty Registry::$key
}

#Each user assigned SID, so need to search and find the SID's (wont start with S-1-5-18-20, those are reserved for system) and then find the Current User Run registry keys
#Can use WMI for this task
$users = (Get-WmiObject Win32_UserProfile | Where-Object {$_.SID -notmatch 'S-1-5-(18|19|20).*'})

#gets the local path of each user from the atrributes listed in the $users var
$userPaths = $users.localpath

#gets the sid of each user from the atrributes listed in the $users var
$UserSIDs = $users.sid

#loop continues while counter is less than legnth of the array, each time through loop, we load path and sid into the vars based on the counter. Once loaded we query each users registry keys
#
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

#---------------------------------------------------------------------------------------
#Persistence in Services
Get-WmiObject win32_service | select Name, DisplayName | Format-List

#---------------------------------------------------------------------------------------
#Persistence in Scheduled Tasks

#load xml containing scheduled tasks file into array
$tasks = Get-ChildItem "C:\Windows\System32\Tasks" -Recurse

ForEach($task in $tasks){
    Write-Host "`r`n[+] Task: $task"
    Write-Host "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++`r`n"
    Get-Content $task -ErrorAction SilentlyContinue | Select-String -Pattern '<Command>' -SimpleMatch
}