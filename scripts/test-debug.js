// CDP - Debug: verificar estado antes de enviar
const puppeteer = require('puppeteer-core');

async function main() {
  const browser = await puppeteer.connect({
    browserURL: 'http://localhost:9000',
    defaultViewport: null
  });
  
  const pages = await browser.pages();
  const page = pages[0];
  
  // Verificar estado atual
  const state = await page.evaluate(() => {
    const ta = document.querySelector('textarea');
    if (!ta) return 'Nenhum textarea';
    return {
      value: ta.value,
      visible: ta.offsetParent !== null,
      placeholder: ta.placeholder
    };
  });
  
  console.log('[STATE] Textarea:', state);
  
  // Tentar focar e digitar
  await page.focus('textarea');
  await new Promise(r => setTimeout(r, 500));
  
  const before = await page.$eval('textarea', el => el.value);
  console.log('[BEFORE] value:', before);
  
  // Usar keyboard para digitar
  await page.keyboard.type('TESTE', { delay: 20 });
  await new Promise(r => setTimeout(r, 500));
  
  const after = await page.$eval('textarea', el => el.value);
  console.log('[AFTER] value:', after);
  
  // Enter
  await page.keyboard.press('Enter');
  console.log('[OK] Enter pressionado');
  
  await browser.disconnect();
}

main().catch(console.error);