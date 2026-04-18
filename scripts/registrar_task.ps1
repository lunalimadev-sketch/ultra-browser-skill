param(
    [Parameter(Mandatory=$true)][string]$Tipo,
    [Parameter(Mandatory=$true)][string]$Titulo,
    [Parameter(Mandatory=$true)][string]$Cliente,
    [Parameter(Mandatory=$true)][string]$PrazoBR,
    [Parameter(Mandatory=$true)][string]$TaskId,
    [string]$ChatId = "6863590559"
)

$token = "pk_290472060_LM1EOKKZVM2OIR6OQLMX4BB3QQ393KHD"
$listId = "901712201328"
$userId = 290472060

# Tipo option IDs
$tipoOptions = @{
    "relatorio" = "8c4a198a-5eb8-4850-92c1-41e6d05c1070"
    "artigo"    = "4649aaf7-fa0a-4b5c-9d70-fa5ca1ce1c19"
    "resenha"   = "cecbafe5-1cba-4900-b4ec-df84d5d6aaf9"
}

# Prioridade option IDs
$prioridadeOptions = @{
    "verde"    = "255592e1-353d-44d2-9e4c-0d0703291f3a"
    "amarelo"  = "41011133-a4f7-483f-b114-46dea3905b2f"
    "vermelho" = "91c49be2-8b8c-4528-a043-c416a71327d8"
}

# Prefixos
$prefixos = @{
    "relatorio" = "RELATORIO"
    "artigo"    = "ARTIGO"
    "resenha"   = "RESENHA"
}

# Subtarefas
$subtarefas = @{
    "relatorio" = @("Redigir introducao", "Redigir metodologia", "Analisar resultados", "Fazer conclusao")
    "artigo"    = @("Pesquisa bibliografica", "Consultar estrutura da revista", "Redigir introducao", "Redigir desenvolvimento", "Escrever conclusao")
    "resenha"   = @("Ler artigo", "Identificar tese central", "Redigir resumo", "Escrever a critica")
}

# Parse data BR -> ISO e Unix MS
$parts = $PrazoBR -split "/"
$prazoISO = "$($parts[2])-$($parts[1])-$($parts[0])T23:59:59-03:00"
$prazoDate = [DateTime]::ParseExact($PrazoBR, "dd/MM/yyyy", $null)
$epoch = [DateTime]::new(1970, 1, 1, 0, 0, 0, [DateTimeKind]::Utc)
$prazoUnixMs = [long](($prazoDate.ToUniversalTime() - $epoch).TotalMilliseconds)
$criacaoUnixMs = [long](([DateTime]::UtcNow - $epoch).TotalMilliseconds)
$hoje = Get-Date

# Calcular prioridade
$diasRestantes = ($prazoDate - $hoje).Days
if ($diasRestantes -le 3) { $prioridade = "vermelho" }
elseif ($diasRestantes -le 7) { $prioridade = "amarelo" }
else { $prioridade = "verde" }

# Montar subtarefas markdown
$subMd = ($subtarefas[$Tipo] | ForEach-Object { "- [ ] $_" }) -join "`n"

# Montar prefixo
$prefix = $prefixos[$Tipo]
if (-not $prefix) { $prefix = $Tipo.ToUpper() }

$taskName = "$prefix | $Titulo"
$description = "ID Interno: $TaskId`nTipo: $Tipo`nCliente: $Cliente`nPrazo: $PrazoBR`nData de criacao: $(Get-Date -Format 'dd/MM/yyyy')`nResponsavel: Eu`nStatus: backlog`nPrioridade: $prioridade`n`nSubtarefas:`n$subMd`n`nOrigem Telegram:`nchat_id=$ChatId"

# Montar body
$body = @{
    name = $taskName
    description = $description
    status = "backlog"
    assignees = @($userId)
    due_date = $prazoUnixMs
    due_date_time = $false
    notify_all = $false
    tags = @($Tipo, $prioridade)
    custom_fields = @(
        @{ id = "31fd70e1-41c5-4485-9708-622e195b1aa8"; value = $TaskId }
        @{ id = "22dd088a-14d4-452f-8283-7db3dcba975c"; value_options = @($tipoOptions[$Tipo]) }
        @{ id = "94c3fd13-d2d4-4910-9688-a69d15e1ad26"; value = $Cliente }
        @{ id = "8a0ae6cd-ae14-460e-81a2-edc1b0976ea7"; value = $criacaoUnixMs }
        @{ id = "68c3ef24-cf88-49c2-af3f-e24d07a77e2d"; value_options = @($prioridadeOptions[$prioridade]) }
        @{ id = "b1602694-8484-4a60-bd5d-b61f3a565e7d"; value = $ChatId }
    )
} | ConvertTo-Json -Depth 5

# Salvar JSON em arquivo temp (evita problemas de encoding)
$tempFile = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($tempFile, $body, [System.Text.Encoding]::UTF8)

# Criar task no ClickUp
$result = curl.exe -s -X POST "https://api.clickup.com/api/v2/list/$listId/task" -H "Authorization: $token" -H "Content-Type: application/json" -d "@$tempFile"
Remove-Item $tempFile -Force

$resultObj = $result | ConvertFrom-Json
$clickupId = $resultObj.id

if (-not $clickupId) {
    Write-Output "ERRO ao criar task: $result"
    exit 1
}

# Criar lembretes no Google Agenda
$d2Date = $prazoDate.AddDays(-2).ToString("yyyy-MM-dd")
$d1Date = $prazoDate.AddDays(-1).ToString("yyyy-MM-dd")

$summaryPrefix = "$prefix | $Titulo"
$calDesc = "Tipo: $Tipo - Cliente: $Cliente - Prazo: $PrazoBR - ID: $TaskId"

& gws calendar +insert --summary "Prazo D-2 | $summaryPrefix" --description $calDesc --start "${d2Date}T09:00:00-03:00" --end "${d2Date}T09:30:00-03:00" 2>$null | Out-Null
& gws calendar +insert --summary "Prazo D-1 | $summaryPrefix" --description $calDesc --start "${d1Date}T09:00:00-03:00" --end "${d1Date}T09:30:00-03:00" 2>$null | Out-Null

# Output resultado
Write-Output @"
SUCESSO
task_id_interno=$TaskId
clickup_id=$clickupId
tipo=$Tipo
titulo=$Titulo
cliente=$Cliente
prazo=$PrazoBR
prioridade=$prioridade
status=backlog
lembretes=D-2 ($d2Date) e D-1 ($d1Date)

Proximo passo: Use /iniciar id:$TaskId para iniciar a tarefa.
"@
