Add-Type -AssemblyName System.Windows.Forms

# Executar agy chat
Write-Host "Abrindo agy chat..."
Start-Process "agy" -ArgumentList "chat", "--reuse-window"

Start-Sleep -Seconds 2

$prompt = "Testando injecao de teclado!"
Write-Host "Enviando teclas..."
[System.Windows.Forms.SendKeys]::SendWait($prompt)
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
Write-Host "Feito!"
