---
description: Envia prompts ao Antigravity IDE e captura a resposta via clipboard, entregando ao OpenClaw via REST API.
status: WIP
---

# Skill: Antigravity Bridge

Permite ao OpenClaw delegar tarefas ao Antigravity IDE e receber a resposta de volta.

## Fluxo

```
OpenClaw
   │
   ▼ execute.ps1 (digita prompt via SendKeys)
Antigravity IDE
   │
   ▼ monitor-response.ps1 (polling via clipboard)
POST http://localhost:18789/v1/responses
   │
   ▼
OpenClaw recebe a resposta
```

## Scripts

| Script | Funcao |
|--------|--------|
| `scripts/execute.ps1` | Foca a janela do Antigravity e injeta o prompt via teclado |
| `scripts/monitor-response.ps1` | Aguarda estabilizacao do clipboard e envia resposta ao OpenClaw |

## Requisitos

- `agy` instalado no PATH
- Antigravity IDE aberto
- OpenClaw rodando em http://localhost:18789

## Como invocar

```powershell
# Apenas envia o prompt (fire-and-forget)
.\scripts\execute.ps1 -Prompt "sua tarefa aqui"

# Envia e aguarda resposta (bidirecional)
.\scripts\monitor-response.ps1 -Prompt "sua tarefa aqui"
```

## Notas

- O token Bearer esta em C:\Users\Luna\.openclaw\openclaw.json
- Nao usar prefixo /telegram nos prompts
- O Antigravity deve estar visivel (nao minimizado) para o SendKeys funcionar
