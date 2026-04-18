---
description: Delega tarefas de programação para o Antigravity IDE (Gemini/Claude) e retorna a resposta via polling.
status: READY
---

# Skill: Antigravity Bridge (v2)

Esta skill permite que o OpenClaw delegue tarefas de programação para o Google Antigravity IDE e receba a resposta de volta.

## Quando usar

Use quando o usuário pedir:
- Código complexo ou refatoração
- Debugging profundo
- Arquitetura de software
- Tarefas que se beneficiam de modelos de código avançados (Gemini/Claude via Antigravity)

## Arquitetura

```
[OpenClaw Agent]
       │
       ▼ executa
[bidirectional.ps1] ──injeta prompt──▶ [Antigravity IDE]
       │                                    │
       │                           Gera resposta
       │                                    │
       │                      POST /antigravity
       │◀───[webhook-server.js :3101]──────┘
       │
       ▼ polling
GET /response até status: "ready"
       │
       ▼ resposta
[OpenClaw responde ao usuário]
```

## Como usar

### 1. Execute o script com o prompt

```powershell
powershell -ExecutionPolicy Bypass -File "skills/antigravity/scripts/bidirectional.ps1" -Prompt "sua tarefa aqui" -WebhookUrl "http://localhost:3101/antigravity"
```

### 2. Faça polling para pegar a resposta

Faça GET para `http://localhost:3101/response` a cada 10 segundos até `{ status: 'ready' }`.

### 3. Use a resposta

Quando o status for `ready`, o campo `text` contém a resposta do Antigravity.

## Parâmetros do script

| Parâmetro | Obrigatório | Padrão | Descrição |
|-----------|-------------|--------|-----------|
| -Prompt | Sim | - | Tarefa de programação completa |
| -WebhookUrl | Não | http://localhost:3101/antigravity | URL do webhook |
| -TimeoutSeconds | Não | 120 | Tempo máximo de espera |

## Requisitos

- `agy` instalado no PATH
- Antigravity IDE aberto
- Webhook server rodando em port 3101
- Permissão para simulação de teclado e clipboard

## O que NÃO fazer

- Não exponha URLs internas na resposta ao usuário
- Não mencione "Antigravity" ou "bridge" ao usuário — simplemente responda com o resultado
- Se o timeout exceder, informe que a tarefa está demorando e oferece alternativas

## Modelo Recomendado

Use **Sonnet 4.6** (via quota Google do Antigravity) para melhores resultados de coding.

## Arquivos

```
skills/antigravity/
├── SKILL.md              ← esta instrução
├── webhook-server.js     ← hub com estado (porta 3101)
└── scripts/
    ├── bidirectional.ps1 ← envia prompt + captura resposta
    └── execute.ps1       ← apenas envia (fire-and-forget)
```