@echo off
echo [*] Encerrando TODAS as instancias do Telegram Bridge...

REM Mata por porta 3102 (nossa porta)
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3102 ^| findstr LISTENING') do (
    echo [*] Matando PID %%a na porta 3102
    taskkill /F /PID %%a 2>nul
)

REM Mata instancias pelo caminho do arquivo
WMIC PROCESS WHERE "Name='node.exe' AND CommandLine LIKE '%%telegram-bridge%%'" CALL Terminate 2>nul
WMIC PROCESS WHERE "Name='node.exe' AND CommandLine LIKE '%%index.js%%'" CALL Terminate 2>nul

timeout /t 2 /nobreak >nul
echo [+] Done. Aguarde 2 segundos antes de reiniciar o bridge.
