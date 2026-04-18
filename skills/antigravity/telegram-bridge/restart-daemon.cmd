@echo off
echo [*] Reiniciando Telegram Bridge...
call "%~dp0stop-daemon.cmd"
timeout /t 2 /nobreak >nul
cscript //nologo "%~dp0boot-daemon.vbs"
echo [+] Bridge reiniciado!
timeout /t 3 /nobreak >nul
netstat -ano | findstr :3102
