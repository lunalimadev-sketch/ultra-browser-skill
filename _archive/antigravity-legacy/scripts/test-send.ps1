# test-send.ps1
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
}
"@

# Encontra a janela correta pelo titulo
$procs = Get-Process -Name "Antigravity" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -match "AGENTS" } | Select-Object -First 1

Write-Host "Processo: $($procs.ProcessName) - $($procs.MainWindowTitle)"
Write-Host "Handle: $($procs.MainWindowHandle)"

if ($procs.MainWindowHandle) {
    Write-Host "Focando janela..."
    [Win32]::SetForegroundWindow($procs.MainWindowHandle)
    Start-Sleep -Milliseconds 1000
    [System.Windows.Forms.SendKeys]::SendWait("Qual o modelo mais poderoso entre qwen3.5, minimax2.5 ou kimi-k2.5?")
    Start-Sleep -Milliseconds 300
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
    Write-Host "Enviado!"
} else {
    Write-Host "Handle invalido"
}