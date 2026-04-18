# bidirectional.ps1
# Bridge bidirecional entre OpenClaw e Google Antigravity.
# Envia prompt via execute.ps1, aguarda resposta via clipboard com detecÃ§Ã£o de estabilidade
# e a entrega para o webhook configurado (ou diretamente ao /reply do bridge).

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Prompt,

    [string]$WebhookUrl      = "http://localhost:3101/telegram-sim",
    [int]$TimeoutSeconds     = 180,
    [int]$CheckIntervalSecs  = 5,
    [int]$StabilityCount     = 2
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Windows.Forms

# â”€â”€â”€ helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

function Get-AntigravityHandle {
    $proc = Get-Process -ErrorAction SilentlyContinue |
            Where-Object { $_.ProcessName -match 'antigravity|agy' -and $_.MainWindowHandle -ne [IntPtr]::Zero } |
            Select-Object -First 1
    return $proc?.MainWindowHandle
}

function Focus-Window {
    param([IntPtr]$Handle)
    if (-not $Handle -or $Handle -eq [IntPtr]::Zero) { return $false }
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinFocusBi {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int cmd);
}
"@ -ErrorAction SilentlyContinue
    [WinFocusBi]::ShowWindow($Handle, 9)
    [WinFocusBi]::SetForegroundWindow($Handle)
    Start-Sleep -Milliseconds 400
    return $true
}

function Get-ClipboardSafe {
    try { return [System.Windows.Forms.Clipboard]::GetText() }
    catch { return "" }
}

function Copy-WindowContent {
    param([IntPtr]$Handle)
    if (-not (Focus-Window -Handle $Handle)) { return "" }
    [System.Windows.Forms.SendKeys]::SendWait("^a")
    Start-Sleep -Milliseconds 300
    [System.Windows.Forms.SendKeys]::SendWait("^c")
    Start-Sleep -Milliseconds 500
    return Get-ClipboardSafe
}

function Send-Webhook {
    param([string]$Url, [string]$Content)
    $body = [System.Text.Encoding]::UTF8.GetBytes((@{ text = $Content } | ConvertTo-Json))
    try {
        Invoke-RestMethod -Uri $Url -Method Post -Body $body -ContentType "application/json; charset=utf-8" | Out-Null
        Write-Host "[->] Resposta entregue ao webhook: $Url" -ForegroundColor Green
        return $true
    } catch {
        Write-Warning "Falha ao enviar para webhook '$Url': $_"
        return $false
    }
}

# â”€â”€â”€ fluxo principal â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

Write-Host "[>] Iniciando bridge bidirecional..." -ForegroundColor Cyan

# Limpa clipboard antes de enviar
[System.Windows.Forms.Clipboard]::Clear()
Start-Sleep -Milliseconds 300

# Envia o prompt via execute.ps1
$executeScript = Join-Path $PSScriptRoot "execute.ps1"
& $executeScript -Prompt $Prompt

Write-Host "[~] Aguardando inÃ­cio da geraÃ§Ã£o (10 s)..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Captura baseline
$hwnd     = Get-AntigravityHandle
$baseline = Copy-WindowContent -Handle $hwnd
Write-Host "[i] Baseline: $($baseline.Length) chars" -ForegroundColor Gray

# â”€â”€â”€ polling com estabilidade â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

$elapsed  = 0
$lastClip = ""
$sameCount = 0
$response  = $null

while ($elapsed -lt $TimeoutSeconds) {
    Start-Sleep -Seconds $CheckIntervalSecs
    $elapsed += $CheckIntervalSecs

    if (-not $hwnd -or $hwnd -eq [IntPtr]::Zero) {
        $hwnd = Get-AntigravityHandle
    }

    $clip    = Copy-WindowContent -Handle $hwnd    # â† foca Antigravity a cada iteraÃ§Ã£o
    $minLen  = [Math]::Max($baseline.Length + 50, 100)

    if (-not $clip -or $clip.Length -lt $minLen) {
        Write-Host "[.] Aguardando... ($elapsed/$TimeoutSeconds s)" -ForegroundColor Gray
        $sameCount = 0
        continue
    }

    # â†“â†“ BUG ORIGINAL CORRIGIDO: era "$clip.NotContains(...)" que nÃ£o existe em PowerShell
    $promptSnippet = $Prompt.Substring(0, [Math]::Min(20, $Prompt.Length))
    if (-not $clip.Contains($promptSnippet)) {
        Write-Host "[.] Clipboard sem contexto do prompt, ignorando..." -ForegroundColor Gray
        $sameCount = 0
        continue
    }

    if ($clip -eq $lastClip) {
        $sameCount++
        Write-Host "[~] EstÃ¡vel ($sameCount/$StabilityCount) â€” $($clip.Length) chars" -ForegroundColor Yellow
        if ($sameCount -ge $StabilityCount) {
            $response = $clip
            # Remove o baseline para isolar apenas a resposta nova
            if ($baseline.Length -gt 0) {
                $snippet = $baseline.Substring(0, [Math]::Min(50, $baseline.Length))
                if ($response.StartsWith($snippet)) {
                    $response = $response.Substring($baseline.Length).Trim()
                }
            }
            if ($response.Length -lt 10) { $response = $clip }
            Write-Host "[+] Resposta capturada: $($response.Length) chars" -ForegroundColor Green
            break
        }
    } else {
        $sameCount = 0
        Write-Host "[~] Crescendo: $($clip.Length) chars..." -ForegroundColor Gray
    }

    $lastClip = $clip
}

# â”€â”€â”€ entrega â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

if ($response) {
    Send-Webhook -Url $WebhookUrl -Content $response | Out-Null
    Write-Output $response
    exit 0
} else {
    $msg = "â±ï¸ Timeout ($TimeoutSeconds s). Verifique o Antigravity diretamente."
    Write-Warning $msg
    if ($WebhookUrl) { Send-Webhook -Url $WebhookUrl -Content $msg | Out-Null }
    exit 1
}

