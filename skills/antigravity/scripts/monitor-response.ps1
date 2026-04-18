# monitor-response.ps1
# Envia prompt ao Antigravity e aguarda a resposta via clipboard.
# Estratégia: foca a janela, faz Ctrl+A+C e verifica estabilidade do conteúdo.
# Quando o clipboard para de crescer por dois ciclos seguidos, considera geração concluída.

param(
    [Parameter(Mandatory=$true)]
    [string]$Prompt,

    [int]$WaitSeconds        = 180,
    [int]$CheckIntervalSeconds = 5,
    [int]$StabilityCount     = 2      # quantas verificações iguais = resposta estável
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Windows.Forms

# ─── helpers ───────────────────────────────────────────────────────────────────

function Get-AntigravityHandle {
    $proc = Get-Process -ErrorAction SilentlyContinue |
            Where-Object { $_.ProcessName -match 'antigravity|agy' -and $_.MainWindowHandle -ne [IntPtr]::Zero } |
            Select-Object -First 1
    return $proc?.MainWindowHandle
}

function Focus-Antigravity {
    param([IntPtr]$Handle)
    if ($Handle -and $Handle -ne [IntPtr]::Zero) {
        Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinFocus {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int cmd);
}
"@ -ErrorAction SilentlyContinue
        [WinFocus]::ShowWindow($Handle, 9)   # SW_RESTORE
        [WinFocus]::SetForegroundWindow($Handle)
        Start-Sleep -Milliseconds 400
        return $true
    }
    return $false
}

function Get-ClipboardSafe {
    try { return [System.Windows.Forms.Clipboard]::GetText() }
    catch { return "" }
}

function Copy-AntigravityContent {
    param([IntPtr]$Handle)
    if (-not (Focus-Antigravity -Handle $Handle)) { return "" }
    [System.Windows.Forms.SendKeys]::SendWait("^a")
    Start-Sleep -Milliseconds 300
    [System.Windows.Forms.SendKeys]::SendWait("^c")
    Start-Sleep -Milliseconds 500
    return Get-ClipboardSafe
}

function Send-ToTelegram {
    param([string]$Text)
    # Envia via Telegram bridge (porta 3000) que repassa ao Telegram
    $uri  = "http://localhost:3102/reply"
    $body = [System.Text.Encoding]::UTF8.GetBytes((@{ text = $Text } | ConvertTo-Json))
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json; charset=utf-8" | Out-Null
        Write-Host "[+] Mensagem enviada ao Telegram." -ForegroundColor Green
        return $true
    } catch {
        Write-Warning "Falha ao contatar Telegram bridge: $_"
        return $false
    }
}

# ─── execução principal ─────────────────────────────────────────────────────────

Write-Host "[>] Enviando prompt ao Antigravity..." -ForegroundColor Cyan

$executeScript = Join-Path $PSScriptRoot "execute.ps1"
& $executeScript -Prompt $Prompt        # ← parâmetro correto: -Prompt (não -PromptText)

Write-Host "[~] Aguardando início da geração (10 s)..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Captura baseline logo após o envio (contém o prompt mas ainda não a resposta)
$hwnd     = Get-AntigravityHandle
$baseline = Copy-AntigravityContent -Handle $hwnd
Write-Host "[i] Baseline capturado: $($baseline.Length) chars" -ForegroundColor Gray

# ─── loop de polling com detecção de estabilidade ──────────────────────────────

$elapsed      = 0
$lastClip     = ""
$sameCount    = 0
$responseFound = $false

Write-Host "[~] Monitorando resposta (timeout: $WaitSeconds s)..." -ForegroundColor Yellow

while ($elapsed -lt $WaitSeconds) {
    Start-Sleep -Seconds $CheckIntervalSeconds
    $elapsed += $CheckIntervalSeconds

    # Atualiza handle caso a janela tenha sido fechada/reaberta
    if (-not $hwnd -or $hwnd -eq [IntPtr]::Zero) {
        $hwnd = Get-AntigravityHandle
    }

    $clip = Copy-AntigravityContent -Handle $hwnd

    # Ignora conteúdo vazio, muito curto ou idêntico ao baseline (ainda sem resposta)
    $minLen = [Math]::Max($baseline.Length + 50, 100)
    if (-not $clip -or $clip.Length -lt $minLen) {
        Write-Host "[.] Aguardando... ($elapsed/$WaitSeconds s — $($clip.Length) chars)" -ForegroundColor Gray
        $sameCount = 0
        continue
    }

    # Detecção de estabilidade: mesmo conteúdo por $StabilityCount ciclos = geração concluída
    if ($clip -eq $lastClip) {
        $sameCount++
        Write-Host "[~] Conteúdo estável ($sameCount/$StabilityCount)..." -ForegroundColor Yellow
        if ($sameCount -ge $StabilityCount) {
            Write-Host "[+] Resposta estável detectada! ($($clip.Length) chars)" -ForegroundColor Green
            $responseFound = $true
            break
        }
    } else {
        $sameCount = 0
        Write-Host "[~] Conteúdo crescendo... ($($clip.Length) chars)" -ForegroundColor Gray
    }

    $lastClip = $clip
}

# ─── resultado ─────────────────────────────────────────────────────────────────

if ($responseFound) {
    # Remove o baseline (prompt) do início, mantém apenas a resposta nova
    $response = $lastClip
    if ($baseline -and $response.StartsWith($baseline.Substring(0, [Math]::Min(50, $baseline.Length)))) {
        $response = $response.Substring($baseline.Length).Trim()
    }
    if ($response.Length -lt 10) { $response = $lastClip }   # fallback: envia tudo
    Send-ToTelegram -Text $response | Out-Null
} else {
    Write-Host "[!] Timeout sem resposta estável." -ForegroundColor Red
    Send-ToTelegram -Text "⏱️ Tempo limite atingido. Verifique a resposta diretamente no Antigravity." | Out-Null
}

exit 0
