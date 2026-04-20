// Teste CDP - Conectar no Antigravity via Chrome DevTools Protocol
const puppeteer = require('puppeteer-core');

async function main() {
  console.log('[TESTE] Conectando via CDP na porta 9000...');
  
  try {
    const browser = await puppeteer.connect({
      browserURL: 'http://localhost:9000',
      defaultViewport: null
    });
    
    console.log('[OK] Conectado!');
    
    const pages = await browser.pages();
    console.log(`[OK] ${pages.length} páginas`);
    
    if (pages.length > 0) {
      const page = pages[0];
      console.log('[TESTE] Avaliando prompt na página...');
      
      // Nota: Antigravity não expose diretamente via JS normal
      // Precisa usar a API interna
    }
    
    await browser.disconnect();
    console.log('[OK] Desconectado');
    
  } catch (e) {
    console.error('[ERRO]', e.message);
  }
}

main();