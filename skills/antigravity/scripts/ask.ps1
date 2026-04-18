# ask.ps1
# Envia pergunta ao Antigravity e retorna a resposta automaticamente

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Prompt
)

$ErrorActionPreference = "Stop"

[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$executeScript = Join-Path $scriptDir "execute.ps1"
$getResponseScript = Join-Path $scriptDir "get-response.ps1"

# Limpa clipboard
[System.Windows.Forms.Clipboard]::Clear()
Start-Sleep -Milliseconds 300

# Envia pergunta
Write-Host "[->] Enviando: $Prompt"
& $executeScript $Prompt

# Captura resposta
Write-Host "[...] Capturando resposta..."

# Executa e captura só o output útil
$output = & $getResponseScript -TimeoutSeconds 90 -PollInterval 3 2>&1
$response = $output | Where-Object { $_ -is [string] -and $_.Length -gt 10 } | Select-Object -First 1

if ($response) {
    Write-Host "[OK] Resposta: $($response.Length) chars"
    $response
} else {
    Write-Host "[!] Falha na captura"
    Write-Host "Output: $output"
    Write-Error "Falha ao capturar resposta"
    exit 1
}