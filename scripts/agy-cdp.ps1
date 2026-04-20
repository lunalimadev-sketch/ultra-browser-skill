<#
.SYNOPSIS
    Envia prompt ao Antigravity via CDP (Chrome DevTools Protocol)
    
.DESCRIPTION
    - Usa Runtime.evaluate para injetar prompt (mais robusto que SendKeys)
    - Suporta seleção de modo (Planning/Fast) e modelo
    - Captura resposta via polling do DOM
    
.PARAMETER Prompt
    Texto a ser enviado
    
.PARAMETER Mode
    Modo: Planning (padrão) ou Fast
    
.PARAMETER Model
    Modelo: Gemini 3.1 Pro High (padrão), ou outro disponível
    
.PARAMETER TimeoutSeconds
    Tempo máximo de espera (padrão: 120s)
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$Prompt,
    
    [Parameter()]
    [string]$Mode = "Planning",
    
    [Parameter()]
    [string]$Model = "",
    
    [Parameter()]
    [int]$TimeoutSeconds = 120
)

$ErrorActionPreference = "Stop"

# Install puppeteer-core if needed
$pkg = Get-PackageJSON "C:\Users\Luna\.openclaw\workspace\package.json"
if (-not $pkg.dependencies.puppeteer-core) {
    Write-Host "[SETUP] Installing puppeteer-core..."
    npm install puppeteer-core --no-save --prefix "C:\Users\Luna\.openclaw\workspace" | Out-Null
}

$cdpScript = @"
const puppeteer = require('puppeteer-core');

async function agyCDP(prompt, mode, model, timeout) {
  const browser = await puppeteer.connect({
    browserURL: 'http://localhost:9000',
    defaultViewport: null
  });
  
  const pages = await browser.pages();
  const page = pages[0];
  const client = await page.target().createCDPSession();
  
  console.log('[OK] Conectado via CDP');
  
  // ========== SELECIONAR MODO ==========
  if (mode) {
    console.log('[MODE] Selecionando:', mode);
    await client.send('Runtime.evaluate', {
      expression: \`
        const btns = document.querySelectorAll('button');
        for (const b of btns) {
          if (b.innerText.includes('${mode}')) {
            b.click();
            break;
          }
        }
      \`
    });
    await new Promise(r => setTimeout(r, 500));
  }
  
  // ========== SELECIONAR MODELO ==========
  if (model) {
    console.log('[MODEL] Selecionando:', model);
    await client.send('Runtime.evaluate', {
      expression: \`
        const btns = document.querySelectorAll('button');
        for (const b of btns) {
          if (b.innerText.includes('${model}')) {
            b.click();
            break;
          }
        }
      \`
    });
    await new Promise(r => setTimeout(r, 500));
  }
  
  // ========== ENVIAR PROMPT ==========
  console.log('[SEND] Enviando prompt...');
  await client.send('Runtime.evaluate', {
    expression: \`
      const input = document.querySelector('.ime-text-area');
      if (input) {
        input.value = '${Prompt.Replace("'", "''")}';
        input.dispatchEvent(new Event('input', { bubbles: true }));
        'OK';
      } else {
        'ERRO: input não encontrado';
      }
    \`
  });
  
  // Clicar no botão de enviar
  await client.send('Runtime.evaluate', {
    expression: \`
      const btns = document.querySelectorAll('button');
      let sendBtn = null;
      for (const b of btns) {
        const t = b.innerText?.toLowerCase();
        if (t && (t.includes('send') || t.includes('⏎') || t === '↩' || t.trim() === '')) {
          sendBtn = b;
          break;
        }
      }
      if (sendBtn) { sendBtn.click(); 'OK'; }
      else { 'ERRO: botão não encontrado'; }
    \`
  });
  
  console.log('[WAIT] Aguardando resposta...');
  
  // ========== ESPERAR RESPOSTA (polling) ==========
  const startTime = Date.now();
  let lastLength = 0;
  
  while (Date.now() - startTime < timeout * 1000) {
    await new Promise(r => setTimeout(r, 3000));
    
    const state = await client.send('Runtime.evaluate', {
      expression: \`
        const all = document.body.innerText;
        const lines = all.split('\\n').filter(l => l.trim() && l.length > 30);
        const lastMsgs = lines.slice(-5);
        JSON.stringify({ total: all.length, last: lastMsgs });
      \`
    });
    
    const data = JSON.parse(state.result.value);
    
    if (data.total > lastLength + 50) {
      console.log('[OK] Nova atividade detectada!');
      
      // Detectar resposta completa
      const final = await client.send('Runtime.evaluate', {
        expression: \`
          const lines = document.body.innerText.split('\\n');
          const msgs = lines.filter(l => l.trim() && l.length > 50 && !l.includes('Info:'));
          JSON.stringify(msgs.slice(-3));
        \`
      });
      
      console.log('[RESPONSE]');
      console.log(JSON.parse(final.result.value));
      break;
    }
    
    lastLength = data.total;
  }
  
  await browser.disconnect();
  console.log('[DONE]');
}

process.argv.slice(2).forEach(a => console.log(a));
"@

$scriptPath = "C:\Users\Luna\.openclaw\workspace\scripts\agy-cdp.js"

# Salvar script Node.js
$nodeScript = @"
const puppeteer = require('puppeteer-core');

const args = process.argv.slice(2);
const prompt = args[0];
const mode = args[1] || 'Planning';
const model = args[2] || '';
const timeout = parseInt(args[3]) || 120;

async function main() {
  const browser = await puppeteer.connect({
    browserURL: 'http://localhost:9000',
    defaultViewport: null
  });
  
  const pages = await browser.pages();
  const page = pages[0];
  const client = await page.target().createCDPSession();
  
  console.log('[OK] Conectado via CDP');

  // Selecionar modo
  if (mode) {
    console.log('[MODE] Selecionando:', mode);
    await client.send('Runtime.evaluate', {
      expression: `const btns = document.querySelectorAll('button'); for (const b of btns) { if (b.innerText && b.innerText.includes('${mode}')) { b.click(); break; } }`
    });
    await new Promise(r => setTimeout(r, 500));
  }

  // Selecionar modelo
  if (model) {
    console.log('[MODEL] Selecionando:', model);
    await client.send('Runtime.evaluate', {
      expression: `const btns = document.querySelectorAll('button'); for (const b of btns) { if (b.innerText && b.innerText.includes('${model}')) { b.click(); break; } }`
    });
    await new Promise(r => setTimeout(r, 500));
  }

  // Enviar prompt
  console.log('[SEND] Enviando prompt...');
  await client.send('Runtime.evaluate', {
    expression: `const input = document.querySelector('.ime-text-area'); if(input){input.value='${prompt.replace(/'/g, "''")}';input.dispatchEvent(new Event('input',{bubbles:true}));'OK'}else{'ERRO'}`
  });

  // Clicar send
  const sendResult = await client.send('Runtime.evaluate', {
    expression: `const btns=document.querySelectorAll('button');let s=null;for(const b of btns){const t=b.innerText?.toLowerCase();if(t&&(t.includes('send')||t.includes('⏎')||t==='')){s=b;break;}}s?s.click():'NERRO'`
  });
  console.log('[SEND]', sendResult.result.value);

  // Aguardar resposta
  console.log('[WAIT] Aguardando resposta...');
  const startTime = Date.now();
  let lastLen = 0;

  while (Date.now() - startTime < timeout * 1000) {
    await new Promise(r => setTimeout(r, 3000));
    
    const state = await client.send('Runtime.evaluate', {
      expression: `document.body.innerText.length`
    });
    
    const len = parseInt(state.result.value);
    if (len > lastLen + 100) {
      console.log('[OK] Resposta recebida!');
      
      const resp = await client.send('Runtime.evaluate', {
        expression: `JSON.stringify(document.body.innerText.split('\\n').filter(l=>l.trim()&&l.length>50).slice(-3))`
      });
      console.log('[RESPONSE]', JSON.parse(resp.result.value));
      break;
    }
    lastLen = len;
  }

  await browser.disconnect();
  console.log('[DONE]');
}

main().catch(e => console.error('[ERRO]', e.message));
"@

# Converter para UTF-8 e salvar
[System.IO.File]::WriteAllText($scriptPath, $nodeScript, [System.Text.UTF8Encoding]::new($true))

# Executar
Write-Host "[EXECUTANDO] Script CDP..."
node $scriptPath $Prompt $Mode $Model $TimeoutSeconds