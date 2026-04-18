$token = (Get-Content 'C:\Users\Luna\.openclaw\openclaw.json' | ConvertFrom-Json).gateway.auth.token
$body = @{
    model = "openclaw:main"
    input = "teste"
} | ConvertTo-Json

$headers = @{}
$headers["Authorization"] = "Bearer $token"

try {
    $response = Invoke-RestMethod -Uri 'http://localhost:18789/v1/responses' -Method Post -Body $body -ContentType 'application/json' -Headers $headers
    $response | ConvertTo-Json
} catch {
    $_.Exception.Response
}