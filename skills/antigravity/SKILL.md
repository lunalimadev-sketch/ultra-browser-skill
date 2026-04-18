---
name: antigravity-bridge
description: >
  Delega tarefas complexas de programação para o Antigravity IDE (Gemini / Claude Sonnet)
  e retorna a resposta diretamente para o agente OpenClaw via REST API.
status: READY
trigger: >
  Ative esta skill sempre que a tarefa de programação exigir raciocínio de alta fidelidade
  ou quando o contexto de código for grande demais para o modelo atual do OpenClaw.
---

# Skill: Antigravity Bridge (Evolved)

Esta skill permite que o OpenClaw delegue tarefas ao Antigravity IDE e receba a resposta de volta de forma direta, sem intermediários.

## Como funciona (Fluxo Direto)

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
[OpenClaw Agent recebe e processa]
```

## Passos de uso

1. **Construa um prompt completo** com todo o contexto (código, erro, objetivo).
2. **Execute o script**:
   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts/bidirectional.ps1 `
       -Prompt "<prompt completo>"
   ```
3. **Ficou pronto?** O OpenClaw receberá a resposta via POST da própria execução do script. Você não precisa fazer polling manual pois a resposta será injetada no seu fluxo de entrada.

## Parâmetros do script

| Parâmetro         | Obrigatório | Padrão                                  | Descrição                        |
|-------------------|-------------|-----------------------------------------|----------------------------------|
| `-Prompt`         | ✅          | —                                       | Tarefa completa para o Antigravity |
| `-WebhookUrl`     | ❌          | `http://localhost:18789/v1/responses`   | API REST do OpenClaw             |
| `-Token`          | ❌          | (Token estático configurado)            | Bearer Token para autenticação   |
| `-TimeoutSeconds` | ❌          | `180`                                   | Tempo máximo de espera           |

## Pré-requisitos

- `agy` instalado e disponível no PATH.
- Antigravity IDE aberto.
- OpenClaw REST API habilitada na porta 18789.

## Notas

- **Evolução**: Esta versão elimina o `webhook-server.js` externo e o Telegram da rota de retorno.
- **Robustez**: O script detecta automaticamente janelas nomeadas como "Antigravity" ou "agy".
- **Limpeza**: Prompts não levam mais o prefixo `/telegram` para evitar loops de resposta automática.
