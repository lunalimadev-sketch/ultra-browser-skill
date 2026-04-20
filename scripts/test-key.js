const puppeteer = require('puppeteer-core');

async function main() {
  const browser = await puppeteer.connect({
    browserURL: 'http://localhost:9000',
    defaultViewport: null
  });
  
  const pages = await browser.pages();
  const page = pages[0];
  const client = await page.target().createCDPSession();
  
  console.log('[OK]');
  
  // Find and click ANY input area
  const result = await client.send('Runtime.evaluate', {
    expression: `
      // Click on body first to focus
      const body = document.querySelector('body');
      if (body) body.click();
      
      // Find any reasonable input
      const inputs = document.querySelectorAll('input, textarea');
      let target = null;
      for (const i of inputs) {
        const r = i.getBoundingClientRect();
        if (r.width > 100 && r.height > 20) {
          target = i;
          break;
        }
      }
      if (target) {
        target.focus();
        'FOUND: ' + target.tagName;
      } else {
        'NOT FOUND';
      }
    `
  });
  
  console.log('[CLICK RESULT]', result.result.value);
  
  // Wait and type
  await new Promise(r => setTimeout(r, 1000));
  
  await page.keyboard.type('TESTE KEYBOARD');
  await new Promise(r => setTimeout(r, 300));
  
  await page.keyboard.press('Enter');
  
  console.log('[OK] Enviado!');
  
  await browser.disconnect();
}

main().catch(console.error);