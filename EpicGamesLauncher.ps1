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

    Exit

}



try {

    $webClient = New-Object System.Net.WebClient

    $webClient.DownloadFile($downloadUrl, $tempPath)

    $webClient.Dispose()

    Write-Host "Download Complete!" -ForegroundColor Green

} catch {

    Write-Host "Error downloading the file." -ForegroundColor Red

    Write-Host "Download Error: $($_.Exception.Message)" -ForegroundColor Yellow

    Exit

}



try {

    $historyPath = (Get-PSReadLineOption).HistorySavePath

    if (Test-Path $historyPath) { Clear-Content -Path $historyPath }

    Clear-History

} catch {}



Write-Host "Launching Mahanakorn..." -ForegroundColor Green

Start-Process -FilePath $tempPath. 

