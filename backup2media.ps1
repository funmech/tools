<#
  .Synopsis
    backup files to CD or DVD
  .Description
    This function copies files from $Path to working directories based on the $Size of media is used.
    The default working directory is $HOME\Downloads, and $Size is 470MB (int32) for CD and
    4.7GB for DVD (double).
  .Example
    Backup-to-Media some\path -Size 4.7GB
#>

# Install help files locally and ignore errors because MS ignores to maintain them
# Update-Help  -Force -Ea 0

# Start a PS sesssion in Unrestricted mode
# PowerShell.exe –ExecutionPolicy Unrestricted
# Set other execution policies?
# Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
# Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

Get-ChildItem -Path C:\Users\Public\Pictures\IMG_20180717_104917.jpg | select -property PSIsContainer


$LIMIT = 4MB
$TopDir = $HOME + "\Downloads"
cd $TopDir

Get-ChildItem -Path $TopDir\IMG_20180717_104917.jpg | select -property PSIsContainer

# check what we have here:
Get-ChildItem -Path C:\Users\Public\Pictures | Measure-Object -property length -sum

Get-ChildItem -Path $TopDir |
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

function Get-Files {
<#
  .Synopsis
    Get files from a location in total close to a size
  .Description
    This function gets files from $Path whose total size is no greater than given $Size
  .Example
    Get-Files some\path -Size 4.7GB
#>
    param(
        [String]$Path = $HOME + "\Downloads",
        $Size = 470MB,
        [int]$DiskNoSeek = 1
    )

    if (!(Test-Path $Path)) {
        Write-Error "Path $Path does not exists." -Category InvalidData
        Return
    }

    Write-Host "Source path =", $Path, ", size of media for backup =", $Size -ForegroundColor Yellow

    $files = Get-ChildItem -Path $Path | 
        Where-Object PSIsContainer -eq $false
        Sort-Object -Property LastWriteTime

    $total = 0
    $maxIndx = $files.Count - 1
    $stack = @()

    0..$maxIndx | ForEach-Object {
        $f = $files[$_]
        if ($f.Length -gt $Size) {
            Write-Warning ("{0} exceeds the size limit: {1:N0} vs {2:N0}" -f $f.Name, $f.Length, $Size)
            Break
        }
        Write-Host ("`t ${f}: {0:N0}" -f $f.Length)

        $total += $f.length
        if ($_ -lt $maxIndx) {
            $nextTotal = $total + $files[$_ + 1].Length
        } else {
            $nextTotal = 0
        }
        $stack += $f
        if ($total -ge $Size -or $nextTotal -gt $Size -or $_ -eq $maxIndx) {
            Write-Host ($stack.Count.ToString() + " files, in total = " + ($total/1MB).ToString() + "MB to be backed up")  -ForegroundColor Yellow
 
            Copy-Files -Files $stack
            $stack = @()
            $total = 0
        }
    }
    #Write-Host ($stack.Count.ToString() + " files, in total = " + ($total/1MB).ToString() + "MB to be backed up")  -ForegroundColor Yellow

    # To check, run this and do calculation with the csv
    # .\funmech-tools\Backup-to-Media -Size 40MB | Select-Object Name, Length | Export-Csv check.csv
    # Here 1KB = 1024B

    #Return $files | Select-Object -First $count
}

function Copy-Files {
<#
  .Synopsis
    Copy a list of files to a location
#>
    param(
        [String]$TargetPath,
        [Parameter(Mandatory=$True)]$Files
    )
    Write-Host -ForegroundColor Yellow $Files.Count, "to be backed up"
    $Files | ForEach-Object {
        Write-Host -ForegroundColor Yellow $_.Name, ($_.Length/1MB).ToString(), "MB"
        # Copy-Item -Path $_ -Destination $TargetPath -Force
    }
    Return
}
    if (Test-Path $TargetPath) {
        Write-Error ($TargetPath + " exist!") -Category ResourceExists
        Write-Host "To retify the above exception, please chooce another location or re-write code to allow over-write." -ForegroundColor Green
        Return
    }

    if ($Files.Count -eq 0) {
        Write-Warning "No files was received to process"
        Return
    }

    Write-Host ($Files.Count.ToString() + " files to be backed up") -ForegroundColor Yellow
    # Create a new folder
    New-Item -Path $TargetPath -ItemType Directory
    $Files | ForEach-Object {
        Write-Host -ForegroundColor Yellow $_.Name, ($_.Length/1MB).ToString(), "MB"
        # Copy-Item -Path $_ -Destination $TargetPath -Force
    }
}

function Tees {
    param(
        [int]$i=1)
    Write-Host -ForegroundColor Cyan $i
}