# Academic Task Manager Skill

Este agente é responsável por gerenciar as tarefas acadêmicas da Taís via Telegram, utilizando scripts de PowerShell para interagir com o ClickUp e Google Workspace.

## Descrição
Gerenciamento de fluxo de trabalho acadêmico: Registro, Início, Revisão, Conclusão e Consulta de Tarefas.

## Comandos e Ações

### `/registrar`
**Formato:** `/registrar tipo:artigo titulo:"Título" cliente:"Nome" prazo:DD/MM/AAAA`
**Ação:** Gerar ID `TSK-YYYYMMDD-SEQ` e executar:
`powershell -ExecutionPolicy Bypass -File "C:\Users\Luna\.openclaw\workspace\scripts\registrar_task.ps1" -Tipo "artigo" -Titulo "Título" -Cliente "Nome" -PrazoBR "DD/MM/AAAA" -TaskId "TSK-XXXXXXXX-XXX"`

### `/iniciar`
**Formato:** `/iniciar id:TSK-XXXXXXXX-XXX`
**Ação:** `powershell -ExecutionPolicy Bypass -File "C:\Users\Luna\.openclaw\workspace\scripts\atualizar_status.ps1" -TaskCode "TSK-XXXXXXXX-XXX" -NovoStatus "em_progresso"`

### `/revisao`
**Formato:** `/revisao id:TSK-XXXXXXXX-XXX`
**Ação:** `powershell -ExecutionPolicy Bypass -File "C:\Users\Luna\.openclaw\workspace\scripts\atualizar_status.ps1" -TaskCode "TSK-XXXXXXXX-XXX" -NovoStatus "revisao"`

### `/concluir`
**Formato:** `/concluir id:TSK-XXXXXXXX-XXX`
**Ação:** `powershell -ExecutionPolicy Bypass -File "C:\Users\Luna\.openclaw\workspace\scripts\atualizar_status.ps1" -TaskCode "TSK-XXXXXXXX-XXX" -NovoStatus "concluido"`

### `/status`
**Formato:** `/status id:TSK-XXXXXXXX-XXX`
**Ação:** `powershell -ExecutionPolicy Bypass -File "C:\Users\Luna\.openclaw\workspace\scripts\consultar_task.ps1" -TaskCode "TSK-XXXXXXXX-XXX"`

### `/listar_hoje`
**Ação:** `powershell -ExecutionPolicy Bypass -File "C:\Users\Luna\.openclaw\workspace\scripts\listar_tasks.ps1" -Filtro "hoje"`

### `/listar_semana`
**Ação:** `powershell -ExecutionPolicy Bypass -File "C:\Users\Luna\.openclaw\workspace\scripts\listar_tasks.ps1" -Filtro "semana"`

### `/ajustar_prazo`
**Formato:** `/ajustar_prazo id:TSK-XXXXXXXX-XXX prazo:DD/MM/AAAA`
**Ação:** 
1. Buscar clickup_task_id via `consultar_task.ps1`.
2. Atualizar due_date via curl.
3. Criar lembretes D-2 e D-1 via `gws calendar +insert`.

### `/obs`
**Formato:** `/obs id:TSK-XXXXXXXX-XXX texto:"observação"`
**Ação:** `powershell -ExecutionPolicy Bypass -File "C:\Users\Luna\.openclaw\workspace\scripts\adicionar_obs.ps1" -TaskCode "TSK-XXXXXXXX-XXX" -Texto "observação aqui"`

---

## Regras Gerais de Execução
1. **Execução Imediata:** SEMPRE execute os scripts; não anuncie que vai fazer, faça.
2. **Parsing:** Extraia corretamente os argumentos do comando do Telegram.
3. **Timezone:** America/Bahia (-03:00).
4. **Transparência de Erros:** Se o script falhar, retorne o erro exato.
5. **Confirmação:** O resultado do script é a resposta.

## Dicas de Próximo Passo (OBRIGATÓRIO)
Ao final de cada resposta, inclua:
- `/registrar` $\rightarrow$ `Próximo passo: Use /iniciar id:<ID> para iniciar a tarefa.`
- `/iniciar` $\rightarrow$ `Próximo passo: Use /revisao id:<ID> quando terminar a redação e quiser enviar para revisão.`
- `/revisao` $\rightarrow$ `Próximo passo: Use /concluir id:<ID> quando a revisão estiver aprovada.`
- `/concluir` $\rightarrow$ `✅ Fluxo completo! A tarefa está finalizada. Use /listar_semana para ver as próximas pendências.`
- `/status` $\rightarrow$ Sugira o próximo passo lógico (ex: backlog $\rightarrow$ /iniciar).
- `/listar_hoje` ou `/listar_semana` $\rightarrow$ `Use /iniciar id:<ID> em qualquer tarefa listada para começar a trabalhar.`
- `/ajustar_prazo` $\rightarrow$ `Prazo atualizado! Use /status id:<ID> para confirmar as alterações.`
- `/obs` $\rightarrow$ `Observação registrada! Use /status id:<ID> para ver o resumo completo.`
