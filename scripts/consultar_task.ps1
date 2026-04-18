param(
    [Parameter(Mandatory=$true)][string]$TaskCode
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
    Write-Output "ERRO: Task com ID $TaskCode nao encontrada."
    exit 1
}

# Extrair custom fields
$tipo = ""; $cliente = ""; $prioridade = ""
foreach ($cf in $targetTask.custom_fields) {
    switch ($cf.id) {
        "22dd088a-14d4-452f-8283-7db3dcba975c" {
            if ($cf.value) {
                $opcoes = $cf.type_config.options
                $sel = $opcoes | Where-Object { $_.orderindex -eq $cf.value }
                if ($sel) { $tipo = $sel.name }
            }
        }
        "94c3fd13-d2d4-4910-9688-a69d15e1ad26" { $cliente = $cf.value }
        "68c3ef24-cf88-49c2-af3f-e24d07a77e2d" {
            if ($cf.value) {
                $opcoes = $cf.type_config.options
                $sel = $opcoes | Where-Object { $_.orderindex -eq $cf.value }
                if ($sel) { $prioridade = $sel.name }
            }
        }
    }
}

$prazo = ""
if ($targetTask.due_date) {
    $epoch = [DateTime]::new(1970, 1, 1, 0, 0, 0, [DateTimeKind]::Utc)
    $prazoDate = $epoch.AddMilliseconds([long]$targetTask.due_date)
    $prazo = $prazoDate.ToString("dd/MM/yyyy")
}

Write-Output @"
ID: $TaskCode
ClickUp ID: $($targetTask.id)
Titulo: $($targetTask.name)
Tipo: $tipo
Cliente: $cliente
Status: $($targetTask.status.status)
Prioridade: $prioridade
Prazo: $prazo
"@
