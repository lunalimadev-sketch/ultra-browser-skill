const http = require('http');

const data = JSON.stringify({
  model: 'sonnet',
  messages: [{
    role: 'user',
    content: `Problema com Paperclip + OpenCode no Windows 11:

Erro: "EPERM: operation not permitted, symlink" ao materializar skills do Paperclip no cache do npm (_npx).

O que já tentei:
- npm cache clean --force
- Limpar pasta _npx manualmente  
- Rodar Paperclip como Administrador
- Mudar cache npm

Erro exato: EPERM: operation not permitted, symlink 'C:/Users/Luna/AppData/Local/npm-cache/_npx/43414d9b790239bb/node_modules/@paperclipai/server/skills/paperclip' -> 'C:/Users/Luna/.paperclip/.../claude-prompt-cache/.../.claude/skills/paperclip'

Os agentes usam o adapter "claude_local" com comando "opencode" mas falham ao tentar materializar as skills do Paperclip (paperclipai/paperclip/paperclip).

Soluções possíveis?`
  }]
});

const req = http.request({
  hostname: '127.0.0.1',
  port: 3100,
  path: '/api/llm/chat',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': data.length
  }
}, (res) => {
  let body = '';
  res.on('data', c => body += c);
  res.on('end', () => {
    console.log('Status:', res.statusCode);
    console.log('Response:', body.slice(0, 3000));
  });
});

req.on('error', console.error);
req.write(data);
req.end();