// Teste Antigravity SDK
import { AntigravitySDK } from 'antigravity-sdk';

async function main() {
  console.log('[TESTE] Iniciando SDK...');
  
  try {
    const sdk = new AntigravitySDK({} as any);
    await sdk.initialize();
    
    console.log('[OK] SDK inicializado!');
    
    // Teste 1: Listar sessões
    const sessions = await sdk.cascade.getSessions();
    console.log(`[OK] ${sessions.length} conversas encontradas`);
    
    // Teste 2: Enviar prompt simples
    console.log('[TESTE] Enviando prompt...');
    await sdk.cascade.sendPrompt('Responda apenas: TESTE OK');
    console.log('[OK] Prompt enviado!');
    
  } catch (e) {
    console.error('[ERRO]', e.message);
  }
}

main();