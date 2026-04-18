param(
    [Parameter(Mandatory=$true)][string]$TaskCode,
    [Parameter(Mandatory=$true)][string]$NovoStatus
)

$token = "pk_290472060_LM1EOKKZVM2OIR6OQLMX4BB3QQ393KHD"
$listId = "901712201328"

# Buscar tasks na lista
$tasksJson = curl.exe -s "https://api.clickup.com/api/v2/list/$listId/task?include_closed=true" -H "Authorization: $token"
$tasks = ($tasksJson | ConvertFrom-Json).tasks

# Encontrar task pelo task_code
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
    Write-Output "ERRO: Task com ID $TaskCode nao encontrada no ClickUp."
    exit 1
}

$clickupId = $targetTask.id

# Mapear status
$statusMap = @{
    "em_progresso" = "em_progresso"
    "revisao"      = "revisao"
    "concluido"    = "concluido"
    "backlog"      = "backlog"
}

$statusClickup = $statusMap[$NovoStatus]
if (-not $statusClickup) {
    Write-Output "ERRO: Status invalido '$NovoStatus'. Use: backlog, em_progresso, revisao, concluido"
    exit 1
}

# Atualizar status
$body = "{`"status`":`"$statusClickup`"}"
$tempFile = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($tempFile, $body, [System.Text.Encoding]::UTF8)
$result = curl.exe -s -X PUT "https://api.clickup.com/api/v2/task/$clickupId" -H "Authorization: $token" -H "Content-Type: application/json" -d "@$tempFile"
Remove-Item $tempFile -Force

$proxPasso = ""
switch ($NovoStatus) {
    "em_progresso" { $proxPasso = "Proximo passo: Use /revisao id:$TaskCode quando terminar a redacao e quiser enviar para revisao." }
    "revisao"      { $proxPasso = "Proximo passo: Use /concluir id:$TaskCode quando a revisao estiver aprovada." }
    "concluido"    { $proxPasso = "✅ Fluxo completo! A tarefa esta finalizada. Use /listar_semana para ver as proximas pendencias." }
}

Write-Output "SUCESSO: Task $TaskCode (ClickUp $clickupId) movida para $NovoStatus`n`n$proxPasso"
