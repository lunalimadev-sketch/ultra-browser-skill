// CDP - Enviar prompt via type e capturar resposta
const puppeteer = require('puppeteer-core');

async function main() {
  const browser = await puppeteer.connect({
    browserURL: 'http://localhost:9000',
    defaultViewport: null
  });
  
  const pages = await browser.pages();
  const page = pages[0];
  
  console.log('[TESTE] Digitando no textarea...');
  
  // Focar e digitar
  await page.type('textarea', 'Responda apenas: TESTE CDP', { delay: 50 });
  
  console.log('[OK] Digitado. Press Enter...');
  
  // Press Enter
  await page.keyboard.press('Enter');
  
  // Esperar resposta (5s)
  await new Promise(r => setTimeout(r, 5000));
  
  // Capture o conteúdo da página
  const content = await page.content();
  console.log('[OK] Conteúdo capturado:', content.length, 'chars');
  
  // Verificar se tem resposta
  if (content.includes('TESTE') || content.includes('OK')) {
    console.log('[OK] Resposta encontrada!');
  }
  
  await browser.disconnect();
}

main().catch(console.error);