# Integração Antigravity - Abordagens Testadas

## Estágio 1: Abrir Antigravity e Enviar Prompt

### ✅ Abordagem Original Funcional (10/04/2026)
- `agy chat --reuse-window` abre o painel
- Espera **4s** para UI carregar (original, não 6s)
- **Ctrl+Alt+Shift+C** para focar no input
- SendKeys digita o prompt
- ENTER envia

### ❌ Abordagens Testadas que NÃO funcionaram
1. TAB único - cai no botão Planning
2. Dois TABs - vai para lugar errado
3. ESC + Shift+TAB - não focaliza corretamente
4. AppActivate - não é suficiente para focar o input
5. 6s de espera - muito tempo, UI pode estar pronta antes

### Abordagem Atual (ajustada para 4s + Ctrl+Alt+Shift+C + digitação direta)
- Espera 4s (não 6s)
- Ctrl+Alt+Shift+C para focar
- SendKeys direta (não clipboard)

### Teste em andamento
- Testar se o prompt chega ao Antigravity
- Se não chegar, verificar se o atalho mudou no VS Code
- **execute.ps1 funcionou** (enviou prompt com sucesso)
- bidirectional.ps1 ainda tem timeout na captura

---

## Estágio 2: Capturar Resposta (pendente)
- Ainda não iniciado

---

## Estágio 3: Enviar via API (pendente)
- POST para /v1/responses