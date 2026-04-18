@echo off
echo Encerrando o Daemon do Antigravity Telegram Bridge...
WMIC PROCESS WHERE "Name='node.exe' AND CommandLine LIKE '%%telegram-bridge%%'" CALL Terminate 2>nul
WMIC PROCESS WHERE "Name='node.exe' AND CommandLine LIKE '%%index.js%%'" CALL Terminate 2>nul
echo Daemon encerrado com seguranca.
pause
