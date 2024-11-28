# Requires two arguments:
# 1. a text file with all the names of solution to be dealt with
# 2. a folder path where the solution zip files and content will be saved.

if ($Args.Length -eq 2) {
    "Path to solution list: " + $Args[0]
    "Working dir is: " + $Args[1]
} else {
    Write-Host "Missing two required position arguments: path to solution list and dumping folder. No more no less."
}

# Set local variables from the Args
$filePath = $Args[0]
$workingDir = $Args[1]

$count = 1
$jobs = @()

# Check if the file exists
if (Test-Path $filePath) {
    # Read the content of the file line by line
    Get-Content $filePath | ForEach-Object {
        # Process each line
        $solution = $_
        
        # Example processing: Display each line with some formatting
        Write-Host "${count}: export $solution"
        pac solution export --environment https://flinders-dev.crm6.dynamics.com/ --name $solution --path $workingDir\${solution}.zip --overwrite
        # Execute the jobs in parallel
        Start-Job $ScriptBlock -ArgumentList $_
        Start-ThreadJob { pac solution unpack -z $workingDir\$($_.Name) -f $workingDir\$($_.BaseName) }
        $jobs += Start-ThreadJob -Name "unpack ${solution}.zip" -ScriptBlock {
            param($solution, $workingDir)
            pac solution unpack -z $workingDir\${solution}.zip -f $workingDir\$solution 
        } -ArgumentList $solution,$workingDir

        Write-Host
        $count++
    }
  Wait-Job -Job $jobs
  
  foreach ($job in $jobs) {
      Receive-Job -Job $job
  }    
} else {
    Write-Host "The $filePath does not exist."
}

