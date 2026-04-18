// webhook-server.js - OpenClaw Antigravity Bridge v2
// Hub central com estado: OpenClaw pergunta → scripts depositam resposta → OpenClaw busca

const http = require('http');

const PORT = 3101;
const TELEGRAM_WEBHOOK_URL = 'http://localhost:3101/telegram-sim';
const TELEGRAM_CHAT_ID = '6863590559';

let pendingResponse = null;
let responseReady = false;

const server = http.createServer((req, res) => {
  const url = req.url.replace(/\?.*/, '');
  
  // POST /antigravity - scripts PS1 depositam a resposta aqui
  if (req.method === 'POST' && url === '/antigravity') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      let text = body;
      try {
        const json = JSON.parse(body);
        text = json.text || json;
      } catch {}
      
      if (text && text.length > 0) {
        pendingResponse = text;
        responseReady = true;
        console.log(`[webhook] Resposta recebida: ${text.length} chars`);
        
        // Enviar para telegram-sim webhook
        const telegramPayload = JSON.stringify({ text: text, chat_id: TELEGRAM_CHAT_ID });
        const req = http.request(TELEGRAM_WEBHOOK_URL, { method: 'POST', headers: { 'Content-Type': 'application/json' } }, (res) => {
          console.log(`[telegram-sim] POST returned: ${res.statusCode}`);
        });
        req.on('error', (e) => console.log(`[telegram-sim] erro: ${e.message}`));
        req.write(telegramPayload);
        req.end();
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ status: 'received' }));
      } else {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Missing text' }));
      }
    });
    return;
  }
  
  // GET /response - OpenClaw faz polling para buscar resposta
  if (req.method === 'GET' && url === '/response') {
    if (responseReady && pendingResponse) {
      const result = pendingResponse;
      pendingResponse = null;
      responseReady = false;
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ status: 'ready', text: result }));
    } else {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ status: 'pending' }));
    }
    return;
  }
  
  // GET /status - Health check
  if (req.method === 'GET' && url === '/status') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ running: true, hasResponse: responseReady }));
    return;
  }
  
  res.writeHead(404);
  res.end();
});

server.listen(PORT, () => {
  console.log(`[OpenClaw-Antigravity Bridge] http://localhost:${PORT}`);
  console.log(`  POST /antigravity <- scripts PS1 depositam resposta`);
  console.log(`  GET /response     <- OpenClaw busca resposta`);
  console.log(`  GET /status       <- health check`);
});