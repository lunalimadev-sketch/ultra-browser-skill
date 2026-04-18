param(
    [Parameter(Mandatory=$true)][string]$TaskCode,
    [Parameter(Mandatory=$true)][string]$Texto
)

$token = "pk_290472060_LM1EOKKZVM2OIR6OQLMX4BB3QQ393KHD"
$listId = "901712201328"

$tasksJson = curl.exe -s "https://api.clickup.com/api/v2/list/$listId/task?include_closed=true" -H "Authorization: $token"
$tasks = ($tasksJson | ConvertFrom-Json).tasks

$targetTask = $null
foreach ($t in $tasks) {
    foreach ($cf in $t.custom_fields) {
        if ($cf.id -eq "31fd70e1-41c5-4485-9708-622e195b1aa8" -and $cf.value -eq $TaskCode) {
            $targetTask = $t
            break
        }
    }
    if ($targetTask) { break }
}

if (-not $targetTask) {
    Write-Output "ERRO: Task $TaskCode nao encontrada."
    exit 1
}

$body = "{`"value`":`"$Texto`"}"
$tempFile = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($tempFile, $body, [System.Text.Encoding]::UTF8)
curl.exe -s -X POST "https://api.clickup.com/api/v2/task/$($targetTask.id)/field/969ad872-edb1-4cc0-ba3a-f2b5074d65ce" -H "Authorization: $token" -H "Content-Type: application/json" -d "@$tempFile" | Out-Null
Remove-Item $tempFile -Force

Write-Output "SUCESSO: Observacao salva na task $TaskCode.`n`nProximo passo: Use /status id:$TaskCode para ver o resumo completo."
