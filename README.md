# AdobePDQ_Connect
Documentation for Adobe Software 2025 Deployment Using PowerShell and PDQ Connect
 
Overview
This document provides detailed instructions for deploying Adobe Software 2025 silently using a PowerShell script through PDQ Connect. The process includes downloading a prepared .zip file, verifying its availability, extracting its contents, executing a silent install, and cleaning up temporary files.

Intended Audience
•	IT Administrators
•	System Deployment Engineers
•	Support Technicians using PDQ Connect for software distribution

Requirements
•	PDQ Connect Agent installed on target devices
•	Administrative access to PDQ Connect portal
•	Adobe2025.zip package prepared with a Build\setup.exe structure
•	PowerShell 5.1 or newer installed on target devices

Deployment Components
1. Files Needed Ex Adobe2025.zip: Must contain at least the Build folder with setup.exe and related installation files. This zip file is download after create an Adobe Package using the admin console. 

2. Script Purpose

This script automates the following tasks:
•	Ensures the .zip archive is available and unlocked.
•	Extracts the archive to a temporary directory.
•	Searches for setup.exe in case folder structures differ.
•	Runs the Photoshop installer silently.
•	Cleans up extracted temporary files.

Script Breakdown

Configuration Variables
$ZipPath = "C:\\Temp\\PDQ_AdobeInstall\\Adobe2025.zip"
$UnzipPath = "$env:TEMP\\Adobe2025"
$InstallerPath = "$UnzipPath\\Build\\setup.exe"

Defines paths for:
•	ZIP file location after copying
•	Temporary extraction location
•	Default installer location
 
# Function: wait for file to be ready (unlocked)
function Wait-ForFileUnlock {
    param (
        [string]$FilePath,
        [int]$MaxAttempts = 30,
        [int]$DelaySeconds = 2
    )
    $attempt = 0
    while ($attempt -lt $MaxAttempts) {
        try {
            $stream = [System.IO.File]::Open($FilePath, 'Open', 'Read', 'None')
            if ($stream) {
                $stream.Close()
                return $true
            }
        } catch {
            Start-Sleep -Seconds $DelaySeconds
            $attempt++
        }
    }
    throw "File is still locked after $($MaxAttempts * $DelaySeconds) seconds: $FilePath"
}

Purpose:
•	Repeatedly attempts to open the file to verify it is not locked by another process (e.g., antivirus or copy operation).
•	Retries up to 30 times, waiting 2 seconds between tries.
 
Step-by-Step Script Execution

Step 1: Ensure ZIP File Exists
if (-Not (Test-Path $ZipPath)) {
    throw "ZIP file not found at: $ZipPath"
}
If the zip file is missing, the script halts.

Step 2: Wait Until ZIP is Unlocked

Write-Output "Waiting for ZIP file to unlock..."
Wait-ForFileUnlock -FilePath $ZipPath
Prevents extraction failures caused by incomplete downloads or copy operations.

Step 3: Extract the ZIP File

Write-Output "Unzipping Photoshop package..."
Expand-Archive -Path $ZipPath -DestinationPath $UnzipPath -Force
Extracts all files into a clean temporary folder. -Force overwrites if a previous attempt left remnants.

Step 4: Validate Setup.exe Existence

if (-Not (Test-Path $InstallerPath)) {
    Write-Output "Expected installer not found at $InstallerPath — scanning..."
    $foundSetup = Get-ChildItem -Path $UnzipPath -Recurse -Filter "setup.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -eq $foundSetup) {
        throw "Extraction failed and installer could not be found anywhere under $UnzipPath"
    } else {
        $InstallerPath = $foundSetup.FullName
        Write-Output "Found installer at $InstallerPath"
    }
}
Guarantees the installer is found, even if an unexpected folder structure is present inside the zip.

Step 5: Launch Photoshop Installer Silently

Write-Output "Running Photoshop installer..."
Start-Process -FilePath $InstallerPath -ArgumentList "--silent" -Wait
Executes setup.exe silently (--silent) and waits for the process to finish.

Step 6: Cleanup Temporary Files

Write-Output "Cleaning up..."
Remove-Item -Path $UnzipPath -Recurse -Force
Deletes the temporary extracted folder to conserve disk space.
 
Uploading to PDQ Connect

1.	Create New App in PDQ Connect.
2.	**Upload **Adobe2025.zip to C:\Temp\PDQ_AdobeInstall using an Install Step or File Copy Step.
3.	Add a PowerShell Step with the script above.
4.	Set Run As to Local System.
5.	Save and Deploy to the appropriate device collections.

Troubleshooting Tips

Symptom	Possible Cause	Resolution

Script fails at file check	Incorrect ZIP path	Confirm $ZipPath matches deployment folder
Setup.exe not found	Wrong ZIP structure	Update script to locate setup.exe dynamically (already included)
Installer launches UI	Incorrect or missing silent argument	Ensure --silent is supported in your Photoshop package
Timeout waiting for ZIP	Copy/upload incomplete	Increase copy time or validate source integrity

Notes

•	Ensure that the PhotoShop2025.zip package includes the complete installer.
•	Photoshop packages created with Adobe Admin Console (Shared Device Licensing) typically support silent installs.
•	Test on a small batch of devices before large-scale deployment.

Conclusion

This script is designed to robustly handle various real-world scenarios encountered during automated deployment, minimizing errors and manual intervention.
 
End of Documentation
