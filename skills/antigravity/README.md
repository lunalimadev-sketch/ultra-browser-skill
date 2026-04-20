# OpenClaw ↔ Antigravity Bridge (Evolved) v2.0

Bridge ultra-enxuta e direta entre o **OpenClaw** (orquestrador) e o **Antigravity IDE** (executor de código).
Esta versão foi evoluída para eliminar intermediários (Node.js/Webhooks) e falar diretamente com a API do OpenClaw.

## Arquitetura (Fluxo Direto)

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
    │  POST /v1/responses (Porta 18789)
    ▼
[OpenClaw Agent]  ← recebe e processa o resultado
```

## Por que esta versão é melhor?
- **Zero Middlemen**: Não precisa rodar `node webhook-server.js`.
- **API Nativa**: Usa a porta nativa do OpenClaw (`18789`) com autenticação Bearer.
- **Sem Conflitos**: Removeu-se completamente o suporte a Telegram paralelo para evitar o erro "409 Conflict".

## Testar manualmente

```powershell
# Enviar tarefa e aguardar resposta no stdout (terminal)
powershell -ExecutionPolicy Bypass -File scripts/ask.ps1 "Refatore esta função para ser async/await"

# Fluxo completo com entrega via API na Luna
powershell -ExecutionPolicy Bypass -File scripts/bidirectional.ps1 `
    -Prompt "Crie testes unitários para a função soma(a,b)"
```

## Estrutura de arquivos

```
antigravity/
├── SKILL.md               ← Instruções para o OpenClaw (API Direta)
├── README.md              ← Este guia
└── scripts/
    ├── execute.ps1        ← Injeta prompt na GUI do Antigravity (Robusto: detecta 'agy' ou 'Antigravity')
    ├── bidirectional.ps1  ← Fluxo completo: envia + captura + POST direto para :18789
    └── ask.ps1            ← Atalho para testes rápidos no terminal
```

## Troubleshooting
- Certifique-se de que o `agy` está no PATH do Windows.
- O OpenClaw deve estar rodando para receber a resposta via porta 18789.
- Caso o script falhe em focar a janela, certifique-se de que o Antigravity IDE não está minimizado para a bandeja.
