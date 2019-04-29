# Install help files locally and ignore errors because MS ignores to maintain them
# Update-Help  -Force -Ea 0

Get-ChildItem -Path C:\Users\Public\Pictures\IMG_20180717_104917.jpg | select -property PSIsContainer

# check what we have here:
Get-ChildItem -Path C:\Users\Public\Pictures | Measure-Object -property length -sum

Get-ChildItem -Path C:\Users\Public\Pictures |
    Where-Object PSIsContainer -eq $false
    Sort-Object -Property LastWriteTime |
    Format-Table -Property Name, Length


$files = Get-ChildItem -Path C:\Users\Public\Pictures | 
    Where-Object PSIsContainer -eq $false
    Sort-Object -Property LastWriteTime

$LIMIT = 740MB
$total = 0
$count = 0

ForEach ($f in $files) {
    $total += $f.length
    $count += 1
    if ($total -gt $LIMIT) {
        $total -= $f.length
        $count--
        break
    } elseif ($total -eq $LIMIT) {
        Write-Host $f 
        break
    } else {
        Write-Host $f
    }
}
Write-Host ($count.ToString() + " files, " + $total.ToString() + " bytes to be backed up")

Write-Host ($count.ToString() + " files, in total = " + ($total/1MB).ToString() + "MB")


# PSISContainer: directory 
$files | ForEach-Object -Process {if (!$_.PSIsContainer) {Set-ItemProperty -Size $_.Length / 1024 /1024; }} | Measure-Object -Property Size -sum

get-childitem -Path d:\scripts –recurse |
  where-object {$_.lastwritetime -gt (get-date).addDays(-1)} |
  where-object {-not $_.PSIsContainer} |
  Foreach-Object { $_.FullName }

$lastWriteTime = (Get-Item -Path "C:\Users\Public\Pictures\IMG_20181113_145307.jpg").LastWriteTime
$nexts = Get-ChildItem -Path C:\Users\Public\Pictures | Where-Object LastWriteTime -gt $lastWriteTime


# The following command finds all executables within the Program Files folder
#   that were last modified after October 1, 2005 and which are neither smaller
#   than 1 megabyte nor larger than 10 megabytes:

Get-ChildItem -Path $env:ProgramFiles -Recurse -Include *.exe | Where-Object -FilterScript {($_.LastWriteTime -gt '2005-10-01') -and ($_.Length -ge 1mb) -and ($_.Length -le 10mb)}

// Create a new temporay folder
New-Item -Path 'C:\temp\New Folder' -ItemType Directory

// copy files and overwrite
Copy-Item -Path C:\boot.ini -Destination C:\boot.bak -Force

// clean up after finishing backup
Remove-Item -Path C:\temp\DeleteMe -Recurse

Remove-Item -Path C:\temp\DeleteMe

Confirm
The item at C:\temp\DeleteMe has children and the -recurse parameter was not
specified. If you continue, all children will be removed with the item. Are you
sure you want to continue?
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help
(default is "Y"):


# If you do not want to be prompted for each contained item, specify the Recurse parameter:
Remove-Item -Path C:\temp\DeleteMe -Recurse

# Reading text from file
# PS> Get-Content -Path C:\boot.ini
