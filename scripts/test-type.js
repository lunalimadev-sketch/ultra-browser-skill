const puppeteer = require('puppeteer-core');

async function main() {
  const browser = await puppeteer.connect({
    browserURL: 'http://localhost:9000',
    defaultViewport: null
  });
  
  const pages = await browser.pages();
  const page = pages[0];
  
  console.log('[OK]');
  
  // Try clicking on textarea first
  await page.click('textarea');
  await new Promise(r => setTimeout(r, 500));
  
  // Then type
  await page.type('textarea', 'TESTE DIRETO', { delay: 50 });
  await new Promise(r => setTimeout(r, 300));
  
  // Press enter
  await page.keyboard.press('Enter');
  
  console.log('[OK] Enviado com type()');
  
  await browser.disconnect();
}

main().catch(console.error);