---
name: antigravity-bridge
description: >
  Delega tarefas complexas de programação para o Antigravity IDE (Gemini / Claude Sonnet)
  e retorna a resposta para o agente OpenClaw. Use quando o usuário pedir código complexo,
  refatoração profunda, debugging avançado, arquitetura de software ou geração de testes.
status: READY
trigger: >
  Ative esta skill sempre que a tarefa de programação exigir raciocínio de alta fidelidade
  ou quando o contexto de código for grande demais para o modelo atual do OpenClaw.
---

## Como funciona

```
[OpenClaw Agent]
      │
      ▼  executa
[scripts/bidirectional.ps1 -Prompt "..." -WebhookUrl http://localhost:3101/antigravity]
      │
      ▼  abre + injeta prompt via GUI
[Antigravity IDE  (Gemini 2.5 Pro / Claude Sonnet)]
      │
      ▼  bidirectional.ps1 captura resposta via clipboard
POST http://localhost:3101/antigravity  { "text": "<resposta>" }
      │
      ▼  webhook-server.js armazena
[GET  http://localhost:3101/response]
      │
      ▼  OpenClaw lê e responde ao usuário
```

## Passos de uso

1. **Construa um prompt completo** com todo o contexto da tarefa (código, erro, objetivo).
2. **Execute o script**:
   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts/bidirectional.ps1 `
       -Prompt "<prompt completo>" `
       -WebhookUrl "http://localhost:3101/antigravity" `
       -TimeoutSeconds 180
   ```
3. **Faça polling** em `GET http://localhost:3101/response` a cada 10 segundos.
   - Resposta `{ "status": "pending" }` → ainda processando, aguarde.
   - Resposta `{ "status": "ready", "text": "..." }` → resposta disponível, use-a.
4. **Use a resposta** como contexto e responda ao usuário normalmente.

## Parâmetros do script

| Parâmetro         | Obrigatório | Padrão                                  | Descrição                        |
|-------------------|-------------|-----------------------------------------|----------------------------------|
| `-Prompt`         | ✅          | —                                       | Tarefa completa para o Antigravity |
| `-WebhookUrl`     | ❌          | `http://localhost:3101/antigravity`     | Endpoint para depositar resposta |
| `-TimeoutSeconds` | ❌          | `180`                                   | Tempo máximo de espera (segundos)|

## Pré-requisitos

- `agy` instalado e disponível no PATH do Windows
- Antigravity IDE aberto (pelo menos uma vez antes de usar)
- `webhook-server.js` rodando: `node webhook-server.js`
- PowerShell com permissão para simulação de teclado e acesso ao clipboard

## Verificação de saúde

```
GET http://localhost:3101/status
→ { "running": true, "hasResponse": false, "lastReceivedAt": null }
```

## Notas

- O servidor armazena **uma resposta por vez** (one-shot). Após o OpenClaw fazer GET,
  a fila é limpa automaticamente.
- Para tarefas longas (geração de arquivos grandes, análise de repositório), aumente
  `-TimeoutSeconds` para 300 ou mais.
- O Telegram **não faz parte desta skill**. O OpenClaw cuida de notificar o usuário
  pelo canal que já estiver configurado (Telegram, GUI, etc.).
- Modelo recomendado no Antigravity: **Gemini 2.5 Pro** ou **Claude Sonnet 4.x**.
