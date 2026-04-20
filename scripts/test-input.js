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
  
  // Find chat input more broadly
  const inputs = await client.send('Runtime.evaluate', {
    expression: `
      // Try multiple selectors
      let el = null;
      
      // Try IME textarea
      el = document.querySelector('.ime-text-area');
      if (el) console.log('FOUND: .ime-text-area');
      
      // Try any textarea in main area
      if (!el) {
        const tas = document.querySelectorAll('textarea');
        for (const t of tas) {
          if (t.offsetHeight > 20 && t.offsetWidth > 100) {
            console.log('FOUND: textarea', t.className?.substring(0,30));
            el = t;
            break;
          }
        }
      }
      
      // Try contenteditable
      if (!el) {
        const eds = document.querySelectorAll('[contenteditable]');
        for (const e of eds) {
          if (e.offsetHeight > 20 && e.offsetWidth > 100) {
            console.log('FOUND: contenteditable', e.className?.substring(0,30));
            el = e;
            break;
          }
        }
      }
      
      if (el) {
        el.value = 'TESTE CDP 123';
        el.dispatchEvent(new Event('input', { bubbles: true }));
        el.dispatchEvent(new Event('change', { bubbles: true }));
        'OK - value set';
      } else {
        'NOT FOUND';
      }
    `
  });
  
  console.log('[RESULT]', inputs.result.value);
  
  await browser.disconnect();
}

main().catch(console.error);