# OpenClaw ↔ Antigravity Bridge  v2.0

Bridge limpa entre o **OpenClaw** (orquestrador) e o **Antigravity IDE** (executor de código).
O Telegram **não faz parte deste projeto** — o OpenClaw já cuida de qualquer canal de comunicação.

## Arquitetura

```
[OpenClaw Agent]
    │  executa script PS1
    ▼
[bidirectional.ps1]
    │  abre GUI + injeta prompt via SendKeys
    ▼
[Antigravity IDE]  ← Gemini 2.5 Pro / Claude Sonnet
    │  resposta gerada
    ▼
[bidirectional.ps1]  ← captura via clipboard
    │  POST /antigravity
    ▼
[webhook-server.js :3101]  ← armazena resposta
    │  GET /response (polling pelo OpenClaw)
    ▼
[OpenClaw Agent]  → responde ao usuário
```

## Instalação

```bash
npm install
```

## Iniciar o servidor

```bash
node webhook-server.js
# ou
npm start
```

## Testar manualmente

```powershell
# Enviar tarefa e aguardar resposta no stdout
powershell -ExecutionPolicy Bypass -File scripts/ask.ps1 "Refatore esta função para ser async/await"

# Usar o modo bidirecional com webhook
powershell -ExecutionPolicy Bypass -File scripts/bidirectional.ps1 `
    -Prompt "Crie testes unitários para a função soma(a,b)" `
    -WebhookUrl "http://localhost:3101/antigravity"

# Verificar se há resposta disponível
curl http://localhost:3101/response

# Health check
curl http://localhost:3101/status
```

## Estrutura de arquivos

```
antigravity-bridge/
├── webhook-server.js      ← Hub central (Node.js + Express)
├── package.json
├── SKILL.md               ← Instruções para o OpenClaw
├── README.md
└── scripts/
    ├── execute.ps1        ← Injeta prompt na GUI do Antigravity
    ├── bidirectional.ps1  ← Fluxo completo: envia + captura + POST webhook
    └── ask.ps1            ← Atalho para testes manuais (stdout direto)
```

## Arquivos removidos (não são mais necessários)

| Arquivo              | Motivo da remoção                                      |
|----------------------|--------------------------------------------------------|
| `index.js`           | Era um proxy Telegram que bypassava o OpenClaw         |
| `monitor-response.ps1` | Responsabilidade movida para `bidirectional.ps1`     |
| `get-response.ps1`   | Lógica consolidada em `bidirectional.ps1`              |
| `reply-telegram.ps1` | Telegram é responsabilidade do OpenClaw, não da bridge |
| `test-send.ps1`      | Substituído por `ask.ps1` (mais robusto)               |
