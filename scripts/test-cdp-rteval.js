// CDP - Enviar prompt via Runtime.evaluate (como remoat/antigravity_phone_chat)
const puppeteer = require('puppeteer-core');

async function main() {
  const browser = await puppeteer.connect({
    browserURL: 'http://localhost:9000',
    defaultViewport: null
  });
  
  const pages = await browser.pages();
  const page = pages[0];
  const client = await page.target().createCDPSession();
  
  const prompt = 'Responda apenas TESTE';
  
  console.log('[TESTE] Enviando via Runtime.evaluate...');
  
  // Etapa 1: Preencher o campo via JS
  await client.send('Runtime.evaluate', {
    expression: `
      const input = document.querySelector('.ime-text-area');
      if (input) {
        input.value = '${prompt.replace(/'/g, "\\'")}';
        input.dispatchEvent(new Event('input', { bubbles: true }));
        input.dispatchEvent(new Event('change', { bubbles: true }));
        'OK - input preenchido';
      } else {
        'ERRO - input não encontrado';
      }
    `
  });
  
  await new Promise(r => setTimeout(r, 1000));
  
  // Etapa 2: Clicar no botão de enviar
  // Procurar botão de Send no DOM
  const sendResult = await client.send('Runtime.evaluate', {
    expression: `
      const btns = document.querySelectorAll('button');
      let sendBtn = null;
      for (const b of btns) {
        const t = b.innerText?.toLowerCase();
        if (t && (t.includes('send') || t.includes('⏎') || t === '↩')) {
          sendBtn = b;
          break;
        }
      }
      if (sendBtn) {
        sendBtn.click();
        'OK - botão clicado';
      } else {
        'ERRO - botão não encontrado';
      }
    `
  });
  
  console.log('[RESULT]', sendResult.result);
  
  // Etapa 3: Esperar e capturar resposta
  await new Promise(r => setTimeout(r, 5000));
  
  const msgs = await client.send('Runtime.evaluate', {
    expression: `
      const all = document.body.innerText;
      // Pegar as últimas linhas relevantes
      const lines = all.split('\\n').filter(l => l.trim() && l.length > 20);
      JSON.stringify(lines.slice(-5));
    `
  });
  
  console.log('[CHAT]', JSON.parse(msgs.result.value || '[]'));
  
  await browser.disconnect();
}

main().catch(console.error);