// CDP - Enviar prompt e capturar resposta
const puppeteer = require('puppeteer-core');

async function main() {
  const browser = await puppeteer.connect({
    browserURL: 'http://localhost:9000',
    defaultViewport: null
  });
  
  const pages = await browser.pages();
  const page = pages[0]; // Main page
  
  console.log('[TESTE] Enviando prompt...');
  
  // Tentar encontrar inputbox - approach via JS evaluation
  const result = await page.evaluate(() => {
    // Antigravity usa componentes React
    const inputs = document.querySelectorAll('input, textarea, [contenteditable]');
    for (const el of inputs) {
      if (el.offsetHeight > 20 && el.offsetWidth > 100) {
        return { tag: el.tagName, placeholder: el.placeholder, id: el.id };
      }
    }
    return null;
  });
  
  console.log('[OK] Input encontrado:', result);
  
  // Tentar enviar via API se disponível
  try {
    // Testar se a API do antigravity está disponível globalmente
    const agyApi = await page.evaluate(() => {
      return typeof window.__AGY__ !== 'undefined' || 
             typeof window.antigravity !== 'undefined';
    });
    console.log('[OK] API disponível:', agyApi);
  } catch(e) {
    console.log('[INFO] API não disponível');
  }
  
  await browser.disconnect();
}

main().catch(console.error);