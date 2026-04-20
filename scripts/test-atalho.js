const puppeteer = require('puppeteer-core');

async function main() {
  const browser = await puppeteer.connect({
    browserURL: 'http://localhost:9000',
    defaultViewport: null
  });
  
  const pages = await browser.pages();
  const page = pages[0];
  
  console.log('[OK]');
  
  // Sequência: Ctrl+Alt+Shift+C (atalho do Antigravity para focar chat)
  await page.keyboard.down('Control');
  await page.keyboard.down('Alt');
  await page.keyboard.down('Shift');
  await page.keyboard.press('c');
  await page.keyboard.up('Shift');
  await page.keyboard.up('Alt');
  await page.keyboard.up('Control');
  
  console.log('[OK] Ctrl+Alt+Shift+C');
  
  await new Promise(r => setTimeout(r, 500));
  
  // Agora digita
  await page.keyboard.type('TESTE ATALHO', { delay: 50 });
  await new Promise(r => setTimeout(r, 300));
  
  // Enter
  await page.keyboard.press('Enter');
  
  console.log('[OK] Enviado!');
  
  await browser.disconnect();
}

main().catch(console.error);