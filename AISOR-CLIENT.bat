@echo off
setlocal enabledelayedexpansion

:: Check if the ssh directory exists, create it if it doesn't
if not exist "C:\Users\Public\Music\ssh" (
    mkdir "C:\Users\Public\Music\ssh"
    echo Created directory C:\Users\Public\Music\ssh
)

:: Welcome message
echo Welcome to AISOR - auto install ssh over rdp

:: Prompt for account
set "user="
set /p "user=account (default user): "
if "%user%"=="" set "user=user"
echo User: %user%

:: Prompt for IP address
set "ip="
set /p "ip=ip address (default example.com): "
if "%ip%"=="" set "ip=example.com"
echo IP Address: %ip%

:: Prompt for port
set "port="
set /p "port=port (default 22): "
if "%port%"=="" set "port=22"
echo Port: %port%

:: Prompt for localport
set "localport="
set /p "localport=localport (default 17556): "
if "%localport%"=="" set "localport=17556"
echo Localport: %localport%

:: Confirm values
echo.
echo Installed user: %user%
echo Installed IP address: %ip%
echo Installed port: %port%
echo Installed localport: %localport%
echo.

:: Create or overwrite ssh3.bat in the ssh directory
(
echo @echo off
echo ssh %user%@%ip% -p %port% -L localhost:3389:localhost:%localport% -N
echo exit
) > "C:\Users\Public\Music\ssh\ssh3.bat"
echo Created ssh3.bat

:: Create or overwrite ssh-rdp5.bat in the ssh directory
echo @echo off > "C:\Users\Public\Music\ssh\ssh-rdp5.bat"
echo start "" "C:\Users\Public\Music\ssh\ssh3.bat" >> "C:\Users\Public\Music\ssh\ssh-rdp5.bat"
echo timeout /t 1 ^>nul >> "C:\Users\Public\Music\ssh\ssh-rdp5.bat"
echo start "" "C:\Windows\System32\mstsc.exe" /v:localhost >> "C:\Users\Public\Music\ssh\ssh-rdp5.bat"
echo. >> "C:\Users\Public\Music\ssh\ssh-rdp5.bat"
echo :loop >> "C:\Users\Public\Music\ssh\ssh-rdp5.bat"
echo tasklist /fi "imagename eq mstsc.exe" ^| find /i "mstsc.exe" ^>nul >> "C:\Users\Public\Music\ssh\ssh-rdp5.bat"
echo set MSTSC_RUNNING=%%errorlevel%% >> "C:\Users\Public\Music\ssh\ssh-rdp5.bat"
echo. >> "C:\Users\Public\Music\ssh\ssh-rdp5.bat"
echo tasklist /fi "imagename eq ssh.exe" ^| find /i "ssh.exe" ^>nul >> "C:\Users\Public\Music\ssh\ssh-rdp5.bat"
echo set SSH_RUNNING=%%errorlevel%% >> "C:\Users\Public\Music\ssh\ssh-rdp5.bat"
echo. >> "C:\Users\Public\Music\ssh\ssh-rdp5.bat"
echo if %%MSTSC_RUNNING%% neq 0 ( >> "C:\Users\Public\Music\ssh\ssh-rdp5.bat"
echo     taskkill /im ssh.exe /f >> "C:\Users\Public\Music\ssh\ssh-rdp5.bat"
echo     exit >> "C:\Users\Public\Music\ssh\ssh-rdp5.bat"
echo ) else if %%SSH_RUNNING%% neq 0 ( >> "C:\Users\Public\Music\ssh\ssh-rdp5.bat"
echo     taskkill /im mstsc.exe /f >> "C:\Users\Public\Music\ssh\ssh-rdp5.bat"
echo     exit >> "C:\Users\Public\Music\ssh\ssh-rdp5.bat"
echo ) else ( >> "C:\Users\Public\Music\ssh\ssh-rdp5.bat"
echo     timeout /t 2 ^>nul >> "C:\Users\Public\Music\ssh\ssh-rdp5.bat"
echo     goto loop >> "C:\Users\Public\Music\ssh\ssh-rdp5.bat"
echo ) >> "C:\Users\Public\Music\ssh\ssh-rdp5.bat"

:: Create a shortcut alo.lnk to ssh-rdp5.bat with a tree icon
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%TEMP%\CreateShortcut.vbs"
echo sLinkFile = "C:\Users\Public\Music\ssh\alo.lnk" >> "%TEMP%\CreateShortcut.vbs"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%TEMP%\CreateShortcut.vbs"
echo oLink.TargetPath = "C:\Users\Public\Music\ssh\ssh-rdp5.bat" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.IconLocation = "%systemroot%\system32\shell32.dll, 41" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.Save >> "%TEMP%\CreateShortcut.vbs"

cscript /nologo "%TEMP%\CreateShortcut.vbs"
del "%TEMP%\CreateShortcut.vbs"


echo Script executed successfully.
start "" "C:\Users\Public\Music\ssh\ssh-rdp5.bat"
echo Script open.
pause
