require('dotenv').config({ path: __dirname + '/.env' });
const TelegramBot = require('node-telegram-bot-api');
const express    = require('express');
const { spawn }  = require('child_process');
const path       = require('path');

const token         = process.env.TELEGRAM_BOT_TOKEN;
const allowedUserId = process.env.TELEGRAM_USER_ID;
const port          = parseInt(process.env.PORT || '3000', 10);

if (!token || !allowedUserId) {
  console.error('[Erro] Variáveis TELEGRAM_BOT_TOKEN ou TELEGRAM_USER_ID não encontradas no .env');
  process.exit(1);
}

// ─── Express (endpoint /reply recebe a resposta do Antigravity) ──────────────

const app = express();
app.use(express.json());
app.use(express.text());
app.use(express.urlencoded({ extended: true }));

let bot;

app.post('/reply', (req, res) => {
  let text = '';
  if (req.body && typeof req.body === 'object' && req.body.text) {
    text = req.body.text;
  } else if (typeof req.body === 'string') {
    text = req.body;
  }

  if (!text) {
    return res.status(400).json({ error: "Campo 'text' ausente no body" });
  }

  if (!bot) {
    return res.status(500).json({ error: 'Bot ainda não inicializado' });
  }

  // Telegram limita mensagens a 4096 chars; divide se necessário
  const chunks = chunkText(text, 4000);
  Promise.all(chunks.map(chunk => bot.sendMessage(allowedUserId, chunk)))
    .then(() => {
      console.log(`[Antigravity -> Telegram] ${chunks.length} parte(s) enviada(s)`);
      res.json({ success: true });
    })
    .catch(err => {
      console.error(`[Erro] Falha ao enviar ao Telegram: ${err.message}`);
      res.status(500).json({ error: 'Falha ao enviar mensagem' });
    });
});

function chunkText(text, size) {
  const chunks = [];
  for (let i = 0; i < text.length; i += size) {
    chunks.push(text.slice(i, i + size));
  }
  return chunks.length ? chunks : [''];
}

// ─── Handlers globais de erro ────────────────────────────────────────────────

process.on('uncaughtException', err => {
  console.error('[Erro fatal] Exceção não capturada:', err);
  if (err.code === 'EADDRINUSE') {
    console.error(`[Erro] Porta ${port} já em uso — outra instância rodando?`);
    process.exit(1);
  }
});

process.on('unhandledRejection', (reason) => {
  console.error('[Erro fatal] Promise rejeitada:', reason);
});

// ─── Inicialização ───────────────────────────────────────────────────────────

app.listen(port, () => {
  console.log(`[API] Bridge escutando em http://localhost:${port}/reply`);

  bot = new TelegramBot(token, { polling: true });
  console.log(`[Telegram] Bot iniciado. Aguardando mensagens do User ID: ${allowedUserId}`);

  bot.on('message', (msg) => {
    const chatId   = msg.chat.id;
    const senderId = msg.from.id.toString();

    if (senderId !== allowedUserId) {
      console.log(`[Segurança] Mensagem rejeitada de ${msg.from.username} (ID: ${senderId})`);
      return;
    }

    if (!msg.text) return;

    console.log(`[Telegram] Prompt recebido: ${msg.text}`);

    bot.sendMessage(chatId,
      '✅ *Prompt recebido!*\n\n⏳ Delegando ao Antigravity — aguarde a resposta.',
      { parse_mode: 'Markdown' }
    ).catch(err => console.error(`[Erro] Confirmação não enviada: ${err.message}`));

    bot.sendChatAction(chatId, 'typing').catch(() => {});

    // ↓ CORRIGIDO: chama monitor-response.ps1 (que envia o prompt E aguarda retorno)
    // em vez de execute.ps1 (fire-and-forget sem retorno ao Telegram).
    const scriptPath = path.resolve(__dirname, '..', 'scripts', 'monitor-response.ps1');

    const ps = spawn(
      'powershell.exe',
      ['-ExecutionPolicy', 'Bypass', '-File', scriptPath, '-Prompt', msg.text],
      {
        detached: true,
        stdio:    ['ignore', 'pipe', 'pipe']   // captura stdout/stderr para log
      }
    );

    ps.stdout.on('data', d => console.log(`[PS stdout] ${d.toString().trim()}`));
    ps.stderr.on('data', d => console.error(`[PS stderr] ${d.toString().trim()}`));

    ps.on('exit', code => {
      console.log(`[PS] monitor-response.ps1 encerrado (código ${code})`);
      if (code !== 0) {
        bot.sendMessage(chatId, '❌ Antigravity retornou erro. Verifique os logs do servidor.')
           .catch(() => {});
      }
    });

    ps.unref();
  });

}).on('error', err => {
  if (err.code === 'EADDRINUSE') {
    console.error(`[Erro crítico] Porta ${port} ocupada. Bridge já rodando.`);
    process.exit(1);
  }
  throw err;
});
