// webhook-server.js - OpenClaw Antigravity Bridge v3 (simplificado)
// Endpoint local para polling de respostas do Antigravity

const http = require('http');
const PORT = 3101;

let pendingResponse = null;
let responseReady = false;

const server = http.createServer((req, res) => {
  const url = req.url.replace(/\?.*/, '');
  const method = req.method;
  
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }
  
  // POST /telegram-sim - Recebe resposta do Antigravity (apenas armazena local)
  if (method === 'POST' && (url === '/telegram-sim' || url === '/antigravity')) {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        const text = data.text || body;
        if (text && text.length > 0) {
          pendingResponse = text;
          responseReady = true;
          console.log(`[webhook] Resposta recebida: ${text.length} chars`);
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ status: 'ok' }));
        } else {
          res.writeHead(400, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: 'Texto vazio' }));
        }
      } catch (e) {
        if (body && body.length > 0) {
          pendingResponse = body;
          responseReady = true;
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ status: 'ok' }));
        } else {
          res.writeHead(400, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: 'Corpo inválido' }));
        }
      }
    });
    return;
  }
  
  // GET /response - Polling
  if (method === 'GET' && url === '/response') {
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
  if (method === 'GET' && url === '/status') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ running: true, hasResponse: responseReady }));
    return;
  }
  
  // GET / - Info
  if (method === 'GET' && url === '/') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      name: 'Antigravity Bridge',
      version: '3.1',
      endpoints: { '/telegram-sim': 'POST respuestas', '/response': 'GET resposta' }
    }));
    return;
  }
  
  res.writeHead(404);
  res.end();
});

server.listen(PORT, () => {
  console.log(`[Antigravity Bridge] http://localhost:${PORT}`);
});