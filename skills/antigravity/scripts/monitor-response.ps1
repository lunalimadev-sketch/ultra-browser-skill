# monitor-response.ps1
# Envia prompt ao Antigravity e aguarda a resposta via clipboard.
# Estrategia: foca a janela, faz Ctrl+A+C e verifica estabilidade do conteudo.
# Quando o clipboard para de crescer por dois ciclos seguidos, considera geracao concluida.

param(
    [Parameter(Mandatory=$true)]
    [string]$Prompt,

    [int]$WaitSeconds          = 180,
    [int]$CheckIntervalSeconds = 5,
    [int]$StabilityCount       = 2
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Windows.Forms

# --- helpers -------------------------------------------------------------------

function Get-AntigravityHandle {
    $proc = Get-Process -ErrorAction SilentlyContinue |
            Where-Object { $_.ProcessName -match 'antigravity|agy' -and $_.MainWindowHandle -ne [IntPtr]::Zero } |
            Select-Object -First 1
    if ($proc) { return $proc.MainWindowHandle }
    return [IntPtr]::Zero
}

function Focus-Antigravity {
    param([IntPtr]$Handle)
    if ($Handle -and $Handle -ne [IntPtr]::Zero) {
        Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinFocusMon {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int cmd);
}
"@ -ErrorAction SilentlyContinue
        [WinFocusMon]::ShowWindow($Handle, 9)   # SW_RESTORE
        [WinFocusMon]::SetForegroundWindow($Handle)
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

function Send-ToOpenClaw {
    param([string]$Text)
    $uri     = "http://localhost:18789/v1/responses"
    $token   = "a8df8a4b175b67679f67c4796223c09d6cd6b2c93f5b0bbf"
    $headers = @{ "Authorization" = "Bearer $token" }
    $body    = [System.Text.Encoding]::UTF8.GetBytes((@{ model = "openclaw:main"; input = $Text } | ConvertTo-Json))
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body -ContentType "application/json; charset=utf-8" | Out-Null
        Write-Host "[+] Resposta enviada ao OpenClaw." -ForegroundColor Green
        return $true
    } catch {
        Write-Warning "Falha ao contatar OpenClaw API: $_"
        return $false
    }
}

# --- execucao principal --------------------------------------------------------

Write-Host "[>] Enviando prompt ao Antigravity..." -ForegroundColor Cyan

$executeScript = Join-Path $PSScriptRoot "execute.ps1"
& $executeScript -Prompt $Prompt

Write-Host "[~] Aguardando inicio da geracao (10 s)..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

$hwnd     = Get-AntigravityHandle
$baseline = Copy-AntigravityContent -Handle $hwnd
Write-Host "[i] Baseline capturado: $($baseline.Length) chars" -ForegroundColor Gray

# --- loop de polling com deteccao de estabilidade ------------------------------

$elapsed       = 0
$lastClip      = ""
$sameCount     = 0
$responseFound = $false

Write-Host "[~] Monitorando resposta (timeout: $WaitSeconds s)..." -ForegroundColor Yellow

while ($elapsed -lt $WaitSeconds) {
    Start-Sleep -Seconds $CheckIntervalSeconds
    $elapsed += $CheckIntervalSeconds

    if (-not $hwnd -or $hwnd -eq [IntPtr]::Zero) {
        $hwnd = Get-AntigravityHandle
    }

    $clip   = Copy-AntigravityContent -Handle $hwnd
    $minLen = [Math]::Max($baseline.Length + 50, 100)

    if (-not $clip -or $clip.Length -lt $minLen) {
        Write-Host "[.] Aguardando... ($elapsed/$WaitSeconds s - $($clip.Length) chars)" -ForegroundColor Gray
        $sameCount = 0
        continue
    }

    if ($clip -eq $lastClip) {
        $sameCount++
        Write-Host "[~] Conteudo estavel ($sameCount/$StabilityCount)..." -ForegroundColor Yellow
        if ($sameCount -ge $StabilityCount) {
            Write-Host "[+] Resposta estavel detectada! ($($clip.Length) chars)" -ForegroundColor Green
            $responseFound = $true
            break
        }
    } else {
        $sameCount = 0
        Write-Host "[~] Conteudo crescendo... ($($clip.Length) chars)" -ForegroundColor Gray
    }

    $lastClip = $clip
}

# --- resultado -----------------------------------------------------------------

if ($responseFound) {
    $response = $lastClip
    if ($baseline -and $response.StartsWith($baseline.Substring(0, [Math]::Min(50, $baseline.Length)))) {
        $response = $response.Substring($baseline.Length).Trim()
    }
    if ($response.Length -lt 10) { $response = $lastClip }
    Send-ToOpenClaw -Text $response | Out-Null
} else {
    Write-Host "[!] Timeout sem resposta estavel." -ForegroundColor Red
    Send-ToOpenClaw -Text "Timeout ($WaitSeconds s). Antigravity nao respondeu a tempo." | Out-Null
}

exit 0
