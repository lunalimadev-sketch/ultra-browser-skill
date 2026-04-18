# bidirectional.ps1 - simplificado
# Bridge bidirecional entre OpenClaw e Google Antigravity.

param(
    [Parameter(Mandatory=$true)]
    [string]$Prompt,
    [string]$WebhookUrl = "http://localhost:3101/telegram-sim",
    [int]$TimeoutSeconds = 120,
    [int]$CheckIntervalSecs = 5
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Windows.Forms

function Get-AgyWindow {
    $procs = Get-Process -Name "Antigravity" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero }
    if ($procs) { return $procs[0].MainWindowHandle }
    return [IntPtr]::Zero
}

function Focus-And-Copy {
    $hwnd = Get-AgyWindow
    if ($hwnd -eq [IntPtr]::Zero) { return "" }
    
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinFF {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int cmd);
}
"@
    [WinFF]::ShowWindow($hwnd, 9)
    [WinFF]::SetForegroundWindow($hwnd)
    Start-Sleep -Milliseconds 500
    
    [System.Windows.Forms.SendKeys]::SendWait("^a")
    Start-Sleep -Milliseconds 300
    [System.Windows.Forms.SendKeys]::SendWait("^c")
    Start-Sleep -Milliseconds 500
    
    try { return [System.Windows.Forms.Clipboard]::GetText() } catch { return "" }
}

function Send-Webhook {
    param([string]$Url, [string]$Content)
    if (-not $Url) { return $false }
    $body = [System.Text.Encoding]::UTF8.GetBytes($Content)
    try {
        Invoke-RestMethod -Uri $Url -Method Post -Body $body -ContentType "text/plain" | Out-Null
        Write-Host "[->] Resposta depositada no webhook" -ForegroundColor Green
        return $true
    } catch {
        Write-Warning "Webhook falhou: $_"
        return $false
    }
}

Write-Host "[>] Enviando para Antigravity..." -ForegroundColor Cyan

# Limpa e envia
[System.Windows.Forms.Clipboard]::Clear()
Start-Sleep -Milliseconds 300

$execScript = Join-Path $PSScriptRoot "execute.ps1"
& $execScript -Prompt $Prompt

Write-Host "[~] Aguardando 15s..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

$elapsed = 0
$lastClip = ""
$sameCount = 0

while ($elapsed -lt $TimeoutSeconds) {
    Start-Sleep -Seconds $CheckIntervalSecs
    $elapsed += $CheckIntervalSecs
    
    $clip = Focus-And-Copy
    
    if (-not $clip -or $clip.Length -lt 10) {
        Write-Host "[.] Aguardando... ($elapsed/$TimeoutSeconds)" -ForegroundColor Gray
        $sameCount = 0
        continue
    }
    
    # Verifica se é resposta nova (não contém o prompt)
    if ($clip.Contains($Prompt.Substring(0, [Math]::Min(15, $Prompt.Length)))) {
        Write-Host "[.] Conteudo ainda com prompt..." -ForegroundColor Gray
        $sameCount = 0
        continue
    }
    
    if ($clip -eq $lastClip -and $clip.Length -gt 20) {
        $sameCount++
        Write-Host "[~] Estavel ($sameCount/2) - $($clip.Length) chars" -ForegroundColor Yellow
        if ($sameCount -ge 2) {
            Write-Host "[+] Resposta capturada!" -ForegroundColor Green
            Send-Webhook -Url $WebhookUrl -Content $clip
            Write-Output $clip
            exit 0
        }
    } else {
        $sameCount = 0
        Write-Host "[~] Novo conteudo: $($clip.Length) chars" -ForegroundColor Gray
    }
    
    $lastClip = $clip
}

Write-Warning "Timeout"
Send-Webhook -Url $WebhookUrl -Content "Timeout apos ${TimeoutSeconds}s"
exit 1