const puppeteer = require('puppeteer-core');

const prompt = process.argv[2] || 'responda OK';
const timeout = parseInt(process.argv[3]) || 60;

async function main() {
  console.log('[INFO] Conectando via WebSocket...');
  
  const http = require('http');
  const getWsUrl = () => new Promise((resolve, reject) => {
    http.get('http://localhost:9000/json/version', (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve(JSON.parse(data).webSocketDebuggerUrl));
    }).on('error', reject);
  });

  const browser = await puppeteer.connect({
    browserWSEndpoint: await getWsUrl(),
    defaultViewport: null
  });
  
  const pages = await browser.pages();
  console.log('[INFO] Páginas disponíveis:', pages.length);
  
  //Encontrar página do workspace (não Launchpad)
  let workspacePage = null;
  for (const p of pages) {
    const t = await p.title();
    if (!t.includes('Launchpad') && !t.includes('Nova guia')) {
      workspacePage = p;
      console.log('[OK] Workspace encontrado:', t);
      break;
    }
  }
  
  if (!workspacePage) {
    console.error('[ERRO] Workspace não encontrado!');
    await browser.disconnect();
    process.exit(1);
  }

  // Focar campo com Ctrl+Alt+Shift+C
  await workspacePage.keyboard.down('Control');
  await workspacePage.keyboard.down('Alt');
  await workspacePage.keyboard.down('Shift');
  await workspacePage.keyboard.press('c');
  await workspacePage.keyboard.up('Shift');
  await workspacePage.keyboard.up('Alt');
  await workspacePage.keyboard.up('Control');
  
  await new Promise(r => setTimeout(r, 500));

  // Digitar e enviar
  await workspacePage.keyboard.type(prompt, { delay: 30 });
  await new Promise(r => setTimeout(r, 300));
  await workspacePage.keyboard.press('Enter');
  
  console.log('[OK] Enviado:', prompt);
  console.log('[WAIT] Aguardando resposta...');

  // Polling
  const startTime = Date.now();
  let lastLen = 0;

  while (Date.now() - startTime < timeout * 1000) {
    await new Promise(r => setTimeout(r, 3000));
    
    const state = await workspacePage.evaluate(() => document.body.innerText.length);
    const len = parseInt(state);
    
    if (len > lastLen + 50) {
      console.log('[OK] Nova atividade!');
      
      const resp = await workspacePage.evaluate(() => {
        const lines = document.body.innerText.split('\n')
          .filter(l => l.trim() && l.length > 20 && !l.includes('Info:') && !l.includes('Ask anything') && !l.includes('Prioritizing'));
        return lines.slice(-3).join('\n');
      });
      
      console.log('--- RESPOSTA ---');
      console.log(resp);
      console.log('--- FIM ---');
      break;
    }
    lastLen = len;
  }

  await browser.disconnect();
  console.log('[FIM]');
}

main().catch(e => console.error('[ERRO]', e.message));