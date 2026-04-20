const puppeteer = require('puppeteer-core');

async function main() {
  const browser = await puppeteer.connect({
    browserURL: 'http://localhost:9000',
    defaultViewport: null
  });
  
  const pages = await browser.pages();
  const page = pages[0];
  const client = await page.target().createCDPSession();
  
  console.log('[OK] Conectado');
  
  // List ALL inputs
  const inputs = await client.send('Runtime.evaluate', {
    expression: `
      const results = [];
      const els = document.querySelectorAll('input, textarea, [contenteditable]');
      for (const el of els) {
        const rect = el.getBoundingClientRect();
        if (rect.width > 50 && rect.height > 10) {
          results.push({
            tag: el.tagName,
            id: el.id,
            class: el.className?.substring(0,30),
            name: el.name,
            placeholder: el.placeholder,
            value: el.value?.substring(0,30)
          });
        }
      }
      JSON.stringify(results.slice(0,10));
    `
  });
  
  console.log('[INPUTS]', JSON.parse(inputs.result.value));
  
  await browser.disconnect();
}

main().catch(console.error);