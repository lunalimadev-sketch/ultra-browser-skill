# 2026-04-18 - Crash e Fix da Integração Telegram

## Problema
O @LunaClawDevBot estava recebendo mensagens automáticas "✅ Prompt recebido!" toda vez que alguém enviava uma mensagem.

## Root Causes Encontrados

### 1. Bridge antiga na porta 3000 (causa principal)
Um processo Node.exe (PID 9076) estava rodando o `telegram-bridge/index.js` na **porta 3000** com o mesmo token do @LunaClawDevBot. Ele interceptava todas as mensagens via getUpdates polling e enviava confirmações automáticas.

### 2. Encoding corrompido do monitor-response.ps1
O script tinha caracteres UTF-8 corrompidos (acentos) causando erros de parse no PowerShell, fazendo o monitor falhar silenciosamente.

### 3. Prefixo /telegram forçado no execute.ps1
O `execute.ps1` tinha lógica que adicionava `/telegram` na frente de todo prompt enviado ao Antigravity, fazendo a IA disparar respostas automáticas ao endpoint do bridge.

## Fixes Aplicados

1. **monitor-response.ps1** - Reescrito sem caracteres especiais, encoding ASCII puro
2. **execute.ps1** - Removida a injeção do prefixo `/telegram`
3. **monitor-response.ps1** - Send-ToTelegram substituída por Send-ToOpenClaw (porta 18789)
4. **telegram-bridge/.env** - Porta trocada de 3000 para 3102
5. **Processo PID 9076** - Encerrado via admin (era a bridge antiga causando os auto-replies)

## Arquitetura Correta (pos-fix)

@LunaClawDevBot -> OpenClaw -> execute.ps1 -> Antigravity -> monitor-response.ps1 -> POST /v1/responses -> OpenClaw

## Nao confundir
- Porta 3101 = telegram-sim do OpenClaw (NAO encerrar)
- A bridge Node.js (telegram-bridge/index.js) NAO deve estar rodando no novo fluxo
- Se voltar a aparecer auto-reply, verificar se ha instancia do index.js rodando na porta 3000 ou 3102
