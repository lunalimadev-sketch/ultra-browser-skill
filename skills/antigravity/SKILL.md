---
name: antigravity-bridge
description: >
  Delega tarefas de programação complexas para o Antigravity IDE (Gemini / Claude Sonnet)
  e retorna a resposta diretamente para o agente OpenClaw via API REST.
status: READY
trigger: >
  Ative esta skill quando precisar de código avançado, refatoração profunda ou
  quando o contexto for grande demais para o modelo local.
---

# Skill: Antigravity Bridge (Evolved)

Esta skill permite ao OpenClaw delegar tarefas ao Antigravity IDE e receber a resposta de volta de forma direta, sem intermediários.

## Arquitetura (Fluxo Direto)

```
[OpenClaw Agent]
      │
      ▼  executa
[scripts/bidirectional.ps1 -Prompt "..."]
      │
      ▼  abre + injeta prompt via GUI
[Antigravity IDE (Gemini / Claude)]
      │
      ▼  bidirectional.ps1 monitora clipboard
[POST http://localhost:18789/v1/responses]
      │
      ▼
[OpenClaw Agent recebe a resposta]
```

## Benefícios da Evolução
- **Sem conflitos**: O Telegram não é mais usado na rota de retorno, eliminando o erro "409 Conflict".
- **Sem middlemen**: Não é mais necessário rodar o `webhook-server.js`.
- **Rapidez**: A resposta é injetada diretamente na API do OpenClaw assim que capturada.

## Como usar

1. **Prompt**: Construa o prompt com todo o contexto necessário.
2. **Execução**:
   ```powershell
   powershell -ExecutionPolicy Bypass -File skills/antigravity/scripts/bidirectional.ps1 -Prompt "<seu prompt>"
   ```
3. **Resultado**: O resultado será postado automaticamente na sua API REST.

## Pré-requisitos
- `agy` no PATH.
- Antigravity IDE aberto.
- OpenClaw API ativa na porta 18789 com o token Bearer configurado.

## Notas de Segurança
- Esta versão desativa automaticamente quaisquer bridges antigas que usem o Token do Telegram para evitar loops de resposta automática.
