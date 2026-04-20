// CDP - Teste completo: enviar prompt + esperar resposta
const puppeteer = require('puppeteer-core');

async function waitForResponse(page, timeout = 60000) {
  console.log('[WAIT] Aguardando resposta...');
  
  const startTime = Date.now();
  let lastContent = await page.content();
  
  while (Date.now() - startTime < timeout) {
    await new Promise(r => setTimeout(r, 2000));
    
    const newContent = await page.content();
    
    if (newContent.length > lastContent.length + 100) {
      console.log('[OK] Nova atividade detectada!');
      
      const aiResponse = await page.evaluate(() => {
        const all = document.body.innerText;
        const lines = all.split('\n').filter(l => l.trim() && l.length > 50);
        return lines.slice(-3);
      });
      
      console.log('[RESPOSTA]', aiResponse);
      return;
    }
  }
  
  console.log('[TIMEOUT] Tempo esgotado');
}

async function main() {
  const browser = await puppeteer.connect({
    browserURL: 'http://localhost:9000',
    defaultViewport: null
  });
  
  const pages = await browser.pages();
  const page = pages[0];
  
  console.log('[TESTE] Enviando novo prompt...');
  
  // Clicar no textarea e digitar
  await page.click('textarea');
  await page.type('textarea', 'Responda CDP OK', { delay: 30 });
  await page.keyboard.press('Enter');
  
  // Esperar resposta
  await waitForResponse(page, 30000);
  
  await browser.disconnect();
}

main().catch(console.error);