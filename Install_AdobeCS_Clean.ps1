# Config
$ZipPath = "C:\Temp\PDQ_AdobeInstall\AdobeZipFile.zip"
$UnzipPath = "$env:TEMP\Adobe2025"
$InstallerPath = "$UnzipPath\Build\setup.exe"

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

# Step 1: Ensure the ZIP file exists
if (-Not (Test-Path $ZipPath)) {
    throw "ZIP file not found at: $ZipPath"
}

# Step 2: Wait until it's fully unlocked
Write-Output "Waiting for ZIP file to unlock..."
Wait-ForFileUnlock -FilePath $ZipPath

# Step 3: Extract ZIP
Write-Output "Unzipping Adobe2025 package..."
Expand-Archive -Path $ZipPath -DestinationPath $UnzipPath -Force

# Step 4: Confirm setup.exe exists (handle unexpected paths)
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

# Step 5: Run installer silently
Write-Output "Running Adobe2025 installer..."
Start-Process -FilePath $InstallerPath -ArgumentList "--silent" -Wait

# Step 6: Clean up
Write-Output "Cleaning up..."
Remove-Item -Path $UnzipPath -Recurse -Force
