# Integração Antigravity - Registro Completo de Tentativas

## 📋 Estratégia de Modelos (Antigravity)

| Modelo | Qualidade | Custo | Quando usar |
|--------|----------|-------|------------|
| Gemini 3.1 Pro | Alta | **Grátis** | Padrão (sempre) |
| Claude (Opus/Sonnet) | Muito alta | Credits limitado | Pouco, só para reasoning complexo |

**Estratégia:**
- Usar **Gemini** como padrão
- **Claude** só quando necessário (arquitetura complexa, debugging deep)
- Monitore créditos do Claude

---

## 🎯 Missão Principal

**Construir ponte para comunicação autônoma bidirecional entre OpenClaw e Antigravity**

- OpenClaw → Antigravity: Enviar prompts automaticamente
- Antigravity → OpenClaw: Receber respostas automaticamente
- Meta: Comunicação fully autonomous (sem intervenção manual)

### Princípio de Integração
**NUNCA substituir uma opção que funciona - criar NOVAS VIAS e prioritar a melhor, mantendo fallbacks**
- CDP (agora) = melhor opção
- SendKeys = fallback (funciona na 1ª vez)
- Todas as tentativas documentadas para futuro

### 🚀 Execução Autônoma
**Quando sei executar e tenho permissão → EXECUTAR, não pedir confirmação**
- Ex: `agy --remote-debugging-port=9000` - apenas informar
- Ex: scripts已知 - apenas rodar
- Perguntar só se precisar de aprovação específica

## 🤖 Missões de Agentes Especializados

### Missão 1: Guardião de Configurações OpenClaw
**Responsabilidades:**
- Gerenciar atualizações do gateway
- Práticas de segurança (hardening)
- Monitorar healthcheck
- Manter config.yaml seguro e atualizado
- Documentar mudanças e versões

### Missão 2: Gestor de Modelos e Provedores
**Responsabilidades:**
- Manter catálogo de modelos atualizados
- Rankear modelos em tiers (free/paid, qualidade)
- Checar disponibilidade e latência
- Calcular custos (especialmente foco em free)
- Testar novos modelos periodicamente

**Tiers atuais (sem custo):**
- Tier 1: opencode/big-pickle
- Tier 2: nvidia/moonshotai/kimi-k2.5, deepseek-reasoner
- Tier 3: mistral-small, minimax-m2.5, nemotron

---

## 📋 Resumo do Histórico

### O que FUNCIONOU (original - 10/04/2026)
- **Espera**: 4s
- **Foco**: Ctrl+Alt+Shift+C
- **Envio**: SendKeys direta + ENTER
- **Status**: FUNCIONANDO (1ª vez apenas)

### O que FUNCIONOU antes (2026-04-17)
- **Integração Telegram** funcionava bidirecionalmente
- **Fluxo**: Telegram → bridge porta 3000 → execute.ps1 → Antigravity → POST /reply → Telegram
- **Scripts**: telegram-bridge/index.js, monitor-response.ps1
- **Status**: OPERACIONAL em 18/04/2026

---

## 📋 Pesquisas Anteriores Registradas

### Pesquisa-chave: 3 Bugs e Correções (de research)

#### Bug #1 — FindWindow não acha janela
- **Problema**: Título muda conforme projeto ("Antigravity — workspace")
- **Correção**: Usar Get-Process em vez de FindWindow
- **Status**: ✅ Já implementado

#### Bug #2 — Foco vai pro lugar errado
- **Problema**: Campo de input não tem foco antes de digitar
- **Correção**: Sequência AppActivate → ESC → limpar → colar via clipboard → Enter
- **Status**: ⚠️ Precisa implementar (corrente usa SENDKEYS direta)

#### Bug #3 — SendKeys corrompe caracteres especiais
- **Problema**: +, ^, %, {, } são tratados como teclas especiais
- **Correção**: Usar clipboard (SetText + ^v) em vez de digitar diretamente
- **Status**: ⚠️ Precisa implementar

### Arquitetura Correta (research)
```
[OpenClaw] → [execute.ps1] → [Antigravity IDE]
                                   ↓
                              [clipboard capture]
                                   ↓
[OpenClaw] ← GET /response ← [webhook-server.js :3101]
```

- **Telegram NÃO deve estar no meio**
- OpenClaw é o orquestrador, não o index.js node
- POST /antigravity ← scripts depositam resposta
- GET /response ← OpenClaw busca resposta

### Observação Importante (do teste)
- **1ª execução**: Prompt vai pro campo ✅
- **2ª+ execução**: Não funciona (script atual)

### Decisão: Abandonar /telegram
- Prefixo `/telegram` foi abandonado
- Usar nova identificação (ex: LUNA-BRIDGE)
- Trechos de código guardados temporariamente para inspiração

## 📋 Abordagem Correta (CDP + Runtime.evaluate)

### ✅ Solução Confirmada!
Usar **Chrome DevTools Protocol** com **Ctrl+Alt+Shift+C** via keyboard:

```javascript
// 1. Conectar via CDP
const browser = await puppeteer.connect({ browserURL: 'http://localhost:9000' });

// 2. Ctrl+Alt+Shift+C para focar campo de chat
await page.keyboard.down('Control');
await page.keyboard.down('Alt');
await page.keyboard.down('Shift');
await page.keyboard.press('c');

// 3. Digitar prompt
await page.keyboard.type(prompt, { delay: 30 });

// 4. Enter
await page.keyboard.press('Enter');

// 5. Polling resposta
while (...) {
  if (page content changed) capture resposta
}
```

### Como Abrir Antigravity
```powershell
agy --remote-debugging-port=9000
```
(flag ANTES do subcomando, SEM o 'chat')

### Script Final
`scripts/agy-cdp.js` - envio + captura funcionando

```javascript
// 1. Conectar ao debugger
const client = await page.target().createCDPSession();

// 2. Injetar prompt via JS (não SendKeys!)
await client.send('Runtime.evaluate', {
  expression: `
    const input = document.querySelector('.ime-text-area');
    input.value = 'prompt';
    input.dispatchEvent(new Event('input', { bubbles: true }));
  `
});

// 3. Clicar no botão Send
await client.send('Runtime.evaluate', {
  expression: `document.querySelectorAll('button')...click()`
});

// 4. Capturar resposta via DOM
const msgs = await client.send('Runtime.evaluate', {
  expression: `document.body.innerText...`
});
```

### Elementos encontrados (via CDP)
- **Input**: `.ime-text-area` (TEXTAREA)
- **Botão**: button com texto "send" ou similar

### Comparativo
| Antes (SendKeys) | Agora (CDP) |
|----------------|------------|
| Foco difícil | Headless |
| Clipboard frágil | Selector exato |
| 1ª vez só | Sempre funciona |

#### 1. antigravity-sdk (Kanezal)
**URL:** https://github.com/Kanezal/antigravity-sdk
**Abordagem:** SDK oficial TypeScript
**Relevância:** 🎯 **PERFEITO** - API nativa
```javascript
import { AntigravitySDK } from 'antigravity-sdk';

await sdk.cascade.sendPrompt('Analyze this file');
const sessions = await sdk.cascade.getSessions();
sdk.monitor.onStepCountChanged((e) => { ... });
```
- sendPrompt() para injetar
- getSessions() para listar
- monitor para статус

#### 2. remoat (optimistengineer)
**URL:** https://github.com/optimistengineer/remoat
**Abordagem:** Telegram bot → Antigravity via CDP
**Relevância:** 🎯 **EXATAMENTE O QUE PRECISAMOS**
- Telegram → Antigravity
- Retorna resposta
- Arquitetura similar

#### 3. antigravity_phone_chat
**URL:** https://github.com/krishnakanthb13/antigravity_phone_chat
**Abordagem:** Chrome DevTools Protocol
**Relevância:** Alternativa complexa

---

## 📋 Tentativas de Foco (execute.ps1)

| # | Espera | Foco | Envio | Resultado | Motivo |
|---|-------|------|------|---------|-------|
| 1 | 4s | Ctrl+Alt+Shift+C | SendKeys | ✅ Funciona (1ª vez) | Original |
| 2 | 6s | AppActivate+ESC+clipboard | ^v | ❌ Prompt não chega | Foco não funciona |
| 3 | 6s | 1x TAB | SendKeys | ❌ Cai no Planning | TAB errado |
| 4 | 6s | 2x TABs | SendKeys | ❌ Lugar errado | Layout mudou |
| 5 | 6s | ESC+Shift+TAB | SendKeys | ❌ Não focaliza | Não sai do input |
| 6 | 4s | Ctrl+Alt+Shift+C | SendKeys | ⚠️ 1ª✓ 2ª✗ | Dropdown abre |

---

## 📋 Scripts e Serviços já criados

### Scripts PowerShell
- `scripts/execute.ps1` - Envia prompt (SendKeys)
- `scripts/bidirectional.ps1` - Envia + captura + webhook
- `scripts/monitor-response.ps1` - Envia + polling resposta (legado)

### Serviços Node.js
- `telegram-bridge/index.js` - Bot Telegram (porta 3000/3102)
- `webhook-server.js` - Recebe respostas (porta 3101)

---

## 📋 Problemas Identificados

### Estágio 1: Envio de Prompt
- **Problema atual**: Após 1º envio, foco vai pro dropdown Planning/Fast
- **Causa**: Estado não reseta entre execuções

### Estágio 2: Captura de Resposta
- **Problema**: Clipboard captura do .gitignore (VS Code), não do chat
- **Causa**: Janela errada detectada

### Estágio 3: Webhook
- **Status**: POST /v1/responses retorna 404
- **Causa**: Rota não existe ou endpoint errado

---

## 📋 Próximas Tentativas sugeridas (a testar)

1. **Adicionar ESC antes de cada envio** - para fechar dropdown
2. **Usar clique do mouse** - em vez de atalho de teclado
3. **Testar manualmente** - confirmar se atalho funciona 2ª vez
4. **Focar com clique no input** - usar coordenadas
5. **Retestar integração Telegram** - verificar se ainda funciona

---

## Evidências (memória)

- memory/2026-04-10.md (original funcionava)
- memory/2026-04-17.md (bidirecional funcionava)
- memory/2026-04-18.md (bridge operacão)
- memory/telegram_integration.md (arquitetura completa)