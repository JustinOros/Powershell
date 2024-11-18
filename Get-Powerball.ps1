# Get-Powerball.ps1 (PowerShell)
# Description: CLI to https://powerball.com (prints winning Powerball results)
# Usage: .\Get-Powerball.ps1 [-List|-L]
# Author: Justin Oros
# Source: https://github.com/JustinOros

# Define URL for Powerball previous results
$powerballUrl = 'https://www.powerball.com/previous-results?gc=powerball'

# Perform an HTTP GET request to the Powerball website
$response = Invoke-WebRequest -Uri $powerballUrl

# Parse the HTML content using the HTML parser
$htmlContent = $response.Content

# Use regular expressions to find drawing dates, white balls, and power balls...

# Drawing Dates (h5.card-title)
$drawingDates = [regex]::Matches($htmlContent, '<h5 class="card-title">(.+?)</h5>')

# White Balls (div.form-control.col.white-balls.item-powerball)
$whiteballs = [regex]::Matches($htmlContent, '<div class="form-control col white-balls item-powerball">(.+?)</div>')

# Power Balls (div.form-control.col.powerball.item-powerball)
$powerballs = [regex]::Matches($htmlContent, '<div class="form-control col powerball item-powerball">(.+?)</div>')

# Initialize positions for white balls and power balls
$whiteballPos = 0
$powerballPos = 0

# Check if the -List or -L argument was passed
$printAll = $false
if ($args.Count -gt 0) {
    if ($args[0].ToLower() -in @('-list', '-l')) {
        $printAll = $true
    }
}

# Function - Print a single line of winning powerball number results
function Print-Line($date, $whiteballPos, $powerballPos) {
    # Print Date
    Write-Host -NoNewline "$($date.Groups[1].Value): "
    
    # Print White Balls
    for ($i = 0; $i -lt 5; $i++) {
        Write-Host -NoNewline "$($whiteballs[$whiteballPos].Groups[1].Value), "
        $whiteballPos++
    }

    # Print Power Ball
    Write-Host "$($powerballs[$powerballPos].Groups[1].Value)"
    $powerballPos++

    return $whiteballPos, $powerballPos
}

# Loop through and print results based on argument flag
if ($printAll) {
    # If -List or -L is present, print all lines
    for ($i = 0; $i -lt $drawingDates.Count; $i++) {
        $whiteballPos, $powerballPos = Print-Line $drawingDates[$i] $whiteballPos $powerballPos
    }
} else {
    # Print only the first line
    if ($drawingDates.Count -gt 0) {
        $whiteballPos, $powerballPos = Print-Line $drawingDates[0] $whiteballPos $powerballPos
    }
}
