# Trechos de Pesquisa - Antigravity Integration
# Guardados temporariamente para inspiração

---

## Script send-to-antigravity.ps1 Corrigido

param(
 [Parameter(Mandatory=$true)]
 [string]$PromptText
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName Microsoft.VisualBasic

# 1. Acha a janela do Antigravity pelo processo (não pelo título exato)
$proc = Get-Process -Name "Antigravity" -ErrorAction SilentlyContinue |
 Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero } |
 Select-Object -First 1

if (-not $proc) {
 Write-Error "[ERRO] Janela do Antigravity nao encontrada. Abra a IDE antes."
 exit 1
}

Write-Host "[OK] Antigravity encontrado: PID $($proc.Id)"

# 2. Traz a janela para frente
[Microsoft.VisualBasic.Interaction]::AppActivate($proc.Id)
Start-Sleep -Milliseconds 600

# 3. Copia o prompt para o clipboard e cola (evita corrompimento de caracteres especiais)
[System.Windows.Forms.Clipboard]::SetText($PromptText)
Start-Sleep -Milliseconds 300

# 4. Foca o campo de input (ESC para sair de qualquer modal, depois clica na caixa)
[System.Windows.Forms.SendKeys]::SendWait("{ESC}")
Start-Sleep -Milliseconds 300

# 5. Cola e envia
[System.Windows.Forms.SendKeys]::SendWait("^v")
Start-Sleep -Milliseconds 500
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")

Write-Host "[OK] Prompt enviado ao Antigravity ($($PromptText.Length) chars)"

---

## Sequência Correta de Foco

Add-Type -AssemblyName Microsoft.VisualBasic

# 1. Ativa a janela
[Microsoft.VisualBasic.Interaction]::AppActivate($proc.Id)
Start-Sleep -Milliseconds 500

# 2. Atalho do Antigravity para focar o campo de prompt (geralmente Escape)
[System.Windows.Forms.SendKeys]::SendWait("{ESC}")
Start-Sleep -Milliseconds 200

# 3. Limpa o campo antes de digitar
[System.Windows.Forms.SendKeys]::SendWait("^a")
Start-Sleep -Milliseconds 150
[System.Windows.Forms.SendKeys]::SendWait("{DEL}")
Start-Sleep -Milliseconds 150

# 4. Cola via clipboard (mais confiável que digitar caractere a caractere)
[System.Windows.Forms.Clipboard]::SetText($PromptToSend)
[System.Windows.Forms.SendKeys]::SendWait("^v")
Start-Sleep -Milliseconds 400

# 5. Envia
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")

---

## Bugs Identificados e Correções

# Bug #1 — execute.ps1: Prefixo telegram indesejado no prompt
# CORRETO: $PromptToSend = $PromptText

# Bug #2 — bidirectional.ps1: $clip.NotContains() não existe
# CORRETO: $clip -notlike "*$snippetToAvoid*"

# Bug #3 — Ctrl+A/C captura área errada
# CORREÇÃO: ANTES do Ctrl+A/C no loop de polling:
[System.Windows.Forms.SendKeys]::SendWait("{END}")
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::SendWait("^a")
Start-Sleep -Milliseconds 200
[System.Windows.Forms.SendKeys]::SendWait("^c")

# Bug #5 — monitor-response.ps1: Race condition no clipboard
# CORREÇÃO: Substitua Start-Sleep -Seconds 8 por 12
# E adicione filtro de tamanho mínimo: $currentClipboard.Length -gt 50

# Bug #7 — FindWindow com título exato pode falhar
# CORREÇÃO: Use Get-Process como método primário

---

## Arquitetura Correta

[OpenClaw] → [execute.ps1] → [Antigravity IDE]
                                   ↓
                              [clipboard capture]
                                   ↓
[OpenClaw] ← GET /response ← [webhook-server.js :3101]

- Telegram NÃO deve estar no meio
- OpenClaw é o orquestrador, não o index.js node
- POST /antigravity ← scripts depositam resposta
- GET /response ← OpenClaw busca resposta

---

## webhook-server.js v2 (sem Telegram)

const express = require('express');
const app = express();
app.use(express.json());
app.use(express.text());

const PORT = 3101;
let pendingResponse = null;
let responseReady = false;

app.post('/antigravity', (req, res) => {
 const text = typeof req.body === 'object' ? req.body.text : req.body;
 if (!text) return res.status(400).json({ error: 'Missing text' });

 pendingResponse = text;
 responseReady = true;
 console.log(`[webhook] Resposta recebida: ${text.length} chars`);
 res.json({ status: 'received' });
});

app.get('/response', (req, res) => {
 if (responseReady && pendingResponse) {
 const result = pendingResponse;
 pendingResponse = null;
 responseReady = false;
 res.json({ status: 'ready', text: result });
 } else {
 res.json({ status: 'pending' });
 }
});

app.get('/status', (req, res) => {
 res.json({ running: true, hasResponse: responseReady });
});

app.listen(PORT, () => {
 console.log(`[OpenClaw-Antigravity Bridge] http://localhost:${PORT}`);
});

---

## Recomendação Principal

O maior problema de confiabilidade é o scraping por clipboard.
Se o agy tem alguma opção de output para arquivo ou stdout via CLI,
vale investigar: agy chat --output /tmp/response.txt
como alternativa mais robusta ao clipboard.