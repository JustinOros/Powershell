# Compare-FileHash.ps1 (PowerShell)
# Description: Compare a file hash value to validate authenticity.
# Usage: Compare-FileHash -File <filename> -Hash <hash>
# Author: Justin Oros
# Source: https://github.com/JustinOros

function Compare-FileHash {
    param (
        [string]$File,
        [string]$Hash
    )

    # Ensure the file exists
    if (-not (Test-Path $File)) {
        Write-Host "File does not exist: $File"
        return
    }

    # Get file details
    $fileInfo = Get-Item $File
    $fileCreatedDate = $fileInfo.CreationTime
    $fileModifiedDate = $fileInfo.LastWriteTime
    $filePath = $fileInfo.FullName
    $fileName = $fileInfo.Name

    # Get system information
    $currentDate = Get-Date -Format "yyyy-MM-dd"
    $currentTime = Get-Date -Format "HH:mm:ss"
    $hostname = $env:COMPUTERNAME
    $username = $env:USERNAME

    # Function to detect hash type based on the provided hash length
    function Get-HashType {
        param (
            [string]$hash
        )
        
        switch ($hash.Length) {
            32 { return "MD5" }
            40 { return "SHA1" }
            64 { return "SHA256" }
            128 { return "SHA512" }
            default { return "Unknown" }
        }
    }

    # Get the hash type for the provided hash
    $givenHashType = Get-HashType -hash $Hash

    # Get actual file hash using Get-FileHash
    $actualHash = (Get-FileHash -Path $File -Algorithm $givenHashType).Hash
    $actualHashType = Get-HashType -hash $actualHash

    # Compare hashes
    $hashMatch = if ($actualHash -eq $Hash) { "Yes (Verified)" } else { "No (Not Verified)" }

    # Output the result
    Write-Host "Date: $currentDate"
    Write-Host "Time: $currentTime"
    Write-Host "Hostname: $hostname"
    Write-Host "Username: $username"
    Write-Host "File Name: $fileName"
    Write-Host "File Path: $filePath"
    Write-Host "File Created Date: $fileCreatedDate"
    Write-Host "File Modified Date: $fileModifiedDate"
    Write-Host "Actual File Hash: $actualHash"
    Write-Host "Actual File Hash Type: $actualHashType"
    Write-Host "Given File Hash: $Hash"
    Write-Host "Given File Hash Type: $givenHashType"
    Write-Host "Hash Match: $hashMatch"
}

# Example usage
Compare-FileHash -File "C:\path\to\your\file.txt" -Hash "your_provided_hash_here"

