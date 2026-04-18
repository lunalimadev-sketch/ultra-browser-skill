# reply-telegram.ps1
# Helper script to send a message back to the Telegram User via the local bridge

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Message
)

$ErrorActionPreference = "Stop"

$uri = "http://127.0.0.1:18789/v1/responses"
$token = "a8df8a4b175b67679f67c4796223c09d6cd6b2c93f5b0bbf"
$headers = @{ "Authorization" = "Bearer $token" }
$bodyJson = @{ model = "openclaw:main"; input = $Message } | ConvertTo-Json
$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyJson)

try {
    Write-Host "[>] Sending reply to OpenClaw..." -ForegroundColor Cyan
    Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $bodyBytes -ContentType "application/json; charset=utf-8" | Out-Null
    Write-Host "[+] Message sent!" -ForegroundColor Green
} catch {
    Write-Error "Failed to reach OpenClaw endpoint."
    Write-Error $_
}
