$token = (Get-Content 'C:\Users\Luna\.openclaw\openclaw.json' | ConvertFrom-Json).gateway.auth.token
$body = @{
    model = "openclaw:main"
    input = "Configure o Antigravity para enviar respostas para o webhook: http://localhost:3101/telegram-sim. Após receber uma resposta do modelo, faça POST para essa URL com o JSON: {`"text`": `"resposta`", `"chat_id`": `"6863590559`"}"
} | ConvertTo-Json

$headers = @{}
$headers["Authorization"] = "Bearer $token"

$response = Invoke-RestMethod -Uri 'http://localhost:18789/v1/responses' -Method Post -Body $body -ContentType 'application/json' -Headers $headers
$response | ConvertTo-Json -Depth 5