# AdobePDQ_Connect

> ✨ A PowerShell-based automated deployment method for Adobe CC 2025 using PDQ Connect.

---

## 🔄 Overview

This guide walks you through deploying Adobe Creative Cloud 2025 software silently using PowerShell and PDQ Connect. The process includes downloading a prepared `.zip` file, verifying its readiness, extracting it, executing a silent install, and cleaning up.

### 💼 Intended Audience
- IT Administrators
- Deployment Engineers
- Support Technicians

### 📅 Requirements
- PDQ Connect Agent installed on target machines
- Admin access to PDQ Connect portal
- `Adobe2025.zip` structured as `Build\setup.exe`
- PowerShell 5.1 or later

---

## 📁 Deployment Components

### 🔍 1. Adobe2025.zip
- Must include a `Build` folder with `setup.exe` and related files.
- Generated using the Adobe Admin Console (silent package).

### 🔧 2. Script Purpose
Automates:
- ZIP file readiness check
- Extraction to temp directory
- Setup file discovery
- Silent installation
- Cleanup of temp files

---

## ⚙️ Script Breakdown

### 📄 Configuration
```powershell
$ZipPath = "C:\Temp\PDQ_AdobeInstall\Adobe2025.zip"
$UnzipPath = "$env:TEMP\Adobe2025"
$InstallerPath = "$UnzipPath\Build\setup.exe"
```

### ✅ Check ZIP Availability
```powershell
if (-Not (Test-Path $ZipPath)) {
    throw "ZIP file not found at: $ZipPath"
}
```

### ⏳ Wait for ZIP Unlock
```powershell
Write-Output "Waiting for ZIP file to unlock..."
Wait-ForFileUnlock -FilePath $ZipPath
```

### 📂 Extract ZIP
```powershell
Write-Output "Unzipping Photoshop package..."
Expand-Archive -Path $ZipPath -DestinationPath $UnzipPath -Force
```

### 📁 Locate setup.exe
```powershell
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
```

### 🚀 Launch Installer Silently
```powershell
Write-Output "Running Photoshop installer..."
Start-Process -FilePath $InstallerPath -ArgumentList "--silent" -Wait
```

### ♻️ Cleanup
```powershell
Write-Output "Cleaning up..."
Remove-Item -Path $UnzipPath -Recurse -Force
```

---

## 🚧 Uploading to PDQ Connect

1. Create new **App** in PDQ Connect.
2. **Upload** `Adobe2025.zip` to `C:\Temp\PDQ_AdobeInstall` via File Copy or Install Step.
3. Add a **PowerShell Step** using the full script.
4. Set **Run As** to Local System.
5. Save and **Deploy**.

![Prop](https://github.com/user-attachments/assets/940fad30-8834-44c0-97c9-1347aa34742c)

![Step1](https://github.com/user-attachments/assets/2ac499e7-bab5-4c6b-bd65-629c6b0476c6)

![step2](https://github.com/user-attachments/assets/5af037c3-7a3e-44ad-9cad-01dc28a2d2bb)
---

## ⚠️ Troubleshooting Tips

| Symptom               | Cause                  | Resolution                                         |
|-----------------------|------------------------|----------------------------------------------------|
| Script fails at check | Wrong ZIP path         | Confirm `$ZipPath` value                           |
| Setup.exe not found   | Folder mismatch        | Script auto-scans paths                            |
| Installer shows UI    | Silent arg not used    | Rebuild Adobe package using `--silent` option      |
| ZIP file timeout      | Copy incomplete        | Allow more time or validate file integrity         |

---

## 📗 Notes

- `Adobe2025.zip` must contain the **complete** Photoshop package.
- Adobe Admin Console (Shared Device Licensing) builds support silent install.
- Test on limited systems before full deployment.

---

## 📆 Conclusion

This automated method simplifies Adobe CC 2025 deployment using PDQ Connect and PowerShell, reducing errors and ensuring consistency across endpoints.

> For full source, see: [GitHub - AdobePDQ_Connect](https://github.com/SLCGit1/AdobePDQ_Connect)

---

_End of Documentation_

## Author
Created by Jesus Ayala from Sarah Lawrence College
