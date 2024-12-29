@echo off
setlocal enabledelayedexpansion
set "green=[1;32m"
set "red=[1;31m"
set "reset_color=[0m"

:: Ensure the script runs as Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo %red%This script requires administrative privileges.%reset_color%
    echo Right-click the .BAT and select "Run as Administrator."
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

echo %green%Administrative privileges confirmed.%reset_color%
echo Searching for Bloxstrap.exe and RobloxPlayerBeta.exe across all drives. This might take a while...

:: Initialize variables
set "bloxstrap_path="
set "roblox_path="
set "search_drives=C D E F G H I J K L M N O P Q R S T U V W X Y Z"
set "temp_log=%temp%\roblox_search"
if exist "%temp_log%" rd /s /q "%temp_log%"
mkdir "%temp_log%"

:: Search for the files
for %%d in (%search_drives%) do (
    if exist %%d:\ (
        echo Searching in drive %%d...
        dir /s /b /a "%%d:\Bloxstrap.exe" >> "%temp_log%\bloxstrap.log" 2>nul
        dir /s /b /a "%%d:\RobloxPlayerBeta.exe" >> "%temp_log%\roblox.log" 2>nul
    )
)

:: Wait for search results to populate
timeout /t 10 >nul

:: Debug: Check log file content
echo Checking bloxstrap.log...
type "%temp_log%\bloxstrap.log"

:: Check if Bloxstrap was found
for /f "delims=" %%f in ('type "%temp_log%\bloxstrap.log" 2^>nul') do (
    set "bloxstrap_path=%%f"
    goto bloxstrap_found
)

if not defined bloxstrap_path (
    echo %red%Bloxstrap.exe not found on any drive. THIS COULD BE FALSE, TRY TO RUN SWIFT%reset_color%
    echo Would you like to install Bloxstrap? (Y/N)
    set /p "install_choice=Enter your choice: "
    if /i "%install_choice%"=="Y" (
        echo Redirecting you to the download page...
        start "" "https://github.com/bloxstraplabs/bloxstrap/releases/download/v2.8.1/Bloxstrap-v2.8.1.exe"
        echo Download the installer from your browser and run it.
        echo Press any key to exit...
        pause >nul
        exit /b 1
    ) else (
        echo %red%You chose not to install Bloxstrap. Exiting...%reset_color%
        echo Press any key to exit...
        pause >nul
        exit /b 1
    )
)

:bloxstrap_found
echo %green%Bloxstrap.exe found at: !bloxstrap_path!%reset_color%

:: Check if RobloxPlayerBeta was found
for /f "delims=" %%f in ('type "%temp_log%\roblox.log" 2^>nul') do (
    set "roblox_path=%%f"
    goto roblox_found
)

if not defined roblox_path (
    echo %red%RobloxPlayerBeta.exe not found on any drive.%reset_color%
    echo Make sure Roblox is installed and try again.
    echo Press any key to exit...
    pause >nul
    exit /b 2
)

:roblox_found
echo %green%RobloxPlayerBeta.exe found at: !roblox_path!%reset_color%

:: Apply registry changes
echo Applying registry changes...
reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "!bloxstrap_path!" /t REG_SZ /d "~ DISABLEDXMAXIMIZEDWINDOWEDMODE" /f >nul 2>&1
if %errorlevel% neq 0 (
    echo %red%Failed to add registry entry for Bloxstrap.exe.%reset_color%
    goto cleanup
)

reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "!roblox_path!" /t REG_SZ /d "~ DISABLEDXMAXIMIZEDWINDOWEDMODE" /f >nul 2>&1
if %errorlevel% neq 0 (
    echo %red%Failed to add registry entry for RobloxPlayerBeta.exe.%reset_color%
    goto cleanup
)

:cleanup
rd /s /q "%temp_log%"
cls
echo %green%All done! Registry changes applied successfully.%reset_color%
echo This was made by S^Z losers! GRH said Swift can use it! Revamps and updates by Hollo/Ajvaxs
echo %red%Black screen hopefully fixed, try injecting Swift.%reset_color%
echo Press any key to exit...
pause >nul
exit /b 0