// CDP - Capturar resposta do chat
const puppeteer = require('puppeteer-core');

async function main() {
  const browser = await puppeteer.connect({
    browserURL: 'http://localhost:9000',
    defaultViewport: null
  });
  
  const pages = await browser.pages();
  const page = pages[0];
  
  // Pegar todo o texto da conversa
  const chatText = await page.evaluate(() => {
    // Tentar encontrar elementos de mensagem
    const msgs = document.querySelectorAll('[data-role="message"], .message, .chat-message, [class*="message"]');
    const texts = [];
    for (const m of msgs) {
      texts.push(m.innerText.substring(0, 200));
    }
    return texts.slice(-5); // Última 5 mensagens
  });
  
  console.log('[CHAT] Mensagens:', chatText);
  
  await browser.disconnect();
}

main().catch(console.error);