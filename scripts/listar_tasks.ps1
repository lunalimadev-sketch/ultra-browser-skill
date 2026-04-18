param(
    [string]$Filtro = "hoje"
)

$token = "pk_290472060_LM1EOKKZVM2OIR6OQLMX4BB3QQ393KHD"
$listId = "901712201328"

$tasksJson = curl.exe -s "https://api.clickup.com/api/v2/list/$listId/task?include_closed=false" -H "Authorization: $token"
$tasks = ($tasksJson | ConvertFrom-Json).tasks

$epoch = [DateTime]::new(1970, 1, 1, 0, 0, 0, [DateTimeKind]::Utc)
$hoje = (Get-Date).Date
$resultados = @()

foreach ($t in $tasks) {
    if (-not $t.due_date) { continue }
    $prazoDate = $epoch.AddMilliseconds([long]$t.due_date).Date

    $incluir = $false
    if ($Filtro -eq "hoje" -and $prazoDate -eq $hoje) { $incluir = $true }
    if ($Filtro -eq "semana" -and $prazoDate -ge $hoje -and $prazoDate -le $hoje.AddDays(7)) { $incluir = $true }

    if ($incluir) {
        $taskCode = ""
        foreach ($cf in $t.custom_fields) {
            if ($cf.id -eq "31fd70e1-41c5-4485-9708-622e195b1aa8") { $taskCode = $cf.value }
        }
        $resultados += "- [$($t.status.status)] $taskCode | $($t.name) | Prazo: $($prazoDate.ToString('dd/MM/yyyy'))"
    }
}

if ($resultados.Count -eq 0) {
    if ($Filtro -eq "hoje") { Write-Output "Nenhuma tarefa com prazo para hoje." }
    else { Write-Output "Nenhuma tarefa com prazo nos proximos 7 dias." }
} else {
    if ($Filtro -eq "hoje") { Write-Output "Tarefas de hoje:" }
    else { Write-Output "Tarefas da semana:" }
    $resultados | ForEach-Object { Write-Output $_ }
    Write-Output "`nProximo passo: Use /iniciar id:<ID> em qualquer tarefa listada para comecar a trabalhar."
}
