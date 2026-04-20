// CDP - Encontrar o elemento de input do chat
const puppeteer = require('puppeteer-core');

async function main() {
  const browser = await puppeteer.connect({
    browserURL: 'http://localhost:9000',
    defaultViewport: null
  });
  
  const pages = await browser.pages();
  const page = pages[0];
  
  // Buscar elementos de input
  const inputs = await page.evaluate(() => {
    const results = [];
    
    // Todos os inputs e textareas
    const els = document.querySelectorAll('input, textarea, [contenteditable]');
    for (const el of els) {
      const rect = el.getBoundingClientRect();
      if (rect.width > 100 && rect.height > 20) { // Visível e razoável
        results.push({
          tag: el.tagName,
          id: el.id,
          class: el.className.substring(0, 50),
          placeholder: el.placeholder,
          dataTestId: el.dataset?.testid || el.getAttribute('data-testid'),
          rect: `${rect.width}x${rect.height}`,
          position: `${rect.x},${rect.y}`
        });
      }
    }
    
    // Também procurar por elementos específicos do antigravity
    const boton = document.querySelectorAll('button, [role="button"]');
    for (const b of boton) {
      const rect = b.getBoundingClientRect();
      if (rect.width > 30 && rect.height > 20 && b.innerText.trim()) {
        results.push({
          tag: 'BUTTON',
          text: b.innerText.trim().substring(0, 30),
          id: b.id,
          class: b.className.substring(0, 50)
        });
      }
    }
    
    return results;
  });
  
  console.log('[INPUTS] Elementos encontrados:');
  console.log(JSON.stringify(inputs, null, 2));
  
  await browser.disconnect();
}

main().catch(console.error);