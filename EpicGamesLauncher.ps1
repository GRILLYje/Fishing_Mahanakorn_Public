$ErrorActionPreference = "SilentlyContinue"

[console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host "Checking for updates (Mahanakorn)..." -ForegroundColor Cyan

$apiUrl = "https://api.github.com/repos/GRILLYje/Fishing_Mahanakorn_Public/releases/latest"

try {
    $releaseInfo = Invoke-RestMethod -Uri $apiUrl -Method Get
    
    $version = $releaseInfo.tag_name
    $publishedAt = [datetime]$releaseInfo.published_at
    $localTime = $publishedAt.ToLocalTime().ToString("dd/MM/yyyy HH:mm:ss")

    $downloadUrl = ($releaseInfo.assets | Where-Object { $_.name -eq "EpicGamesLauncher.exe" }).browser_download_url

    if (-not $downloadUrl) {
        Write-Host "Error: Could not find 'EpicGamesLauncher.exe' in the latest release!" -ForegroundColor Red
        Read-Host "Press Enter to exit..."
        Exit
    }

    Write-Host "==========================================" -ForegroundColor Yellow
    Write-Host "New Update Available!" -ForegroundColor Green
    Write-Host "Version: $version" -ForegroundColor White
    Write-Host "Date & Time: $localTime" -ForegroundColor White
    Write-Host "==========================================" -ForegroundColor Yellow
    Write-Host "Downloading file... Please wait." -ForegroundColor White

} catch {
    Write-Host "Failed to fetch update info from GitHub." -ForegroundColor Red
    Write-Host "API Error: $($_.Exception.Message)" -ForegroundColor Yellow
    Read-Host "Press Enter to exit..."
    Exit
}

$folderPath = "$env:TEMP\Mahanakorn"
if (-not (Test-Path $folderPath)) {
    New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
}

$tempPath = "$folderPath\EpicGamesLauncher.exe"

# ลองลบไฟล์เก่าดูก่อน
try {
    if (Test-Path $tempPath) {
        Remove-Item $tempPath -Force -ErrorAction Stop
    }
} catch {
    Write-Host "Error: Cannot delete old file. Please make sure the bot is closed." -ForegroundColor Red
    Write-Host "Details: $($_.Exception.Message)" -ForegroundColor Yellow
    Read-Host "Press Enter to exit..."
    Exit
}

try {
    # ลบ WebClient ทิ้งทั้งหมด และใช้ Invoke-WebRequest แทน
    $headers = @{ "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" }
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath -UseBasicParsing -Headers $headers
    
    Write-Host "Download Complete!" -ForegroundColor Green
} catch {
    Write-Host "Error downloading the file." -ForegroundColor Red
    # เปลี่ยนมาแสดงรายละเอียด Error ที่ลึกขึ้น
    Write-Host "Download Error: $($_.Exception.Message)" -ForegroundColor Yellow
    if ($_.Exception.InnerException) {
        Write-Host "Detail: $($_.Exception.InnerException.Message)" -ForegroundColor Yellow
    }
    Read-Host "Press Enter to exit..."
    Exit
}

try {
    $historyPath = (Get-PSReadLineOption).HistorySavePath
    if (Test-Path $historyPath) { Clear-Content -Path $historyPath }
    Clear-History
} catch {}

Write-Host "Launching Mahanakorn..." -ForegroundColor Green
Start-Process -FilePath $tempPath.
