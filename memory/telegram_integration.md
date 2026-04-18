# Integração Telegram + Antigravity

A integração foi desenvolvida como uma via de mão dupla (two-way bridge) para permitir o controle do Antigravity IDE diretamente a partir do Telegram, permitindo injeção remota de prompts e retorno de respostas processadas pelo agente.

## 1. Fluxo de Injeção de Prompts (Telegram ➡️ Antigravity)
- **Serviço de Escuta (Bot Node.js):** Um serviço rodando localmente (`skills/antigravity/telegram-bridge/index.js`) usa `node-telegram-bot-api` com polling ativo para ouvir mensagens na conta do bot.
- **Segurança (Whitelist):** O bot valida rigorosamente o ID de quem envia a mensagem consultando a variável `TELEGRAM_USER_ID` do `.env`. Qualquer mensagem de remetentes não autorizados é ignorada com avisos no modelo [Security] log.
- **Feedback Imediato:** Quando o prompt autorizado chega, o bot imediatamente responde no Telegram: *"✅ Aviso de Recebimento: Prompt injetado com sucesso! ⏳ O Antigravity IDE assumiu o controle..."*
- **Acionamento:** O Node.js chama de forma "fire-and-forget" (`child_process.spawn`) o script `skills/antigravity/scripts/execute.ps1` enviando o prompt recebido como o parâmetro `-Prompt`.
- **Injeção (Agente):** O script `execute.ps1` (junto de `test_sendkeys.ps1`) injeta dinamicamente as strings de texto na janela do Antigravity IDE por meio de automação e envia os strokes da interface simulando digitação, dando continuidade ao loop de processamento.

## 2. Fluxo de Resposta (Antigravity ➡️ Telegram)
- **Servidor Express (API Local):** O script em Node.js também levanta um servidor HTTP Express que aguarda chamadas locais na porta `3000`.
- **Endpoint Webhook:** A rota `POST /reply` com o formato `{"text": "<Sua mensagem aqui>"}` funciona para coletar a resposta retornada do modelo/IDE.
- **Retorno Ativo:** Quando o agente do Antigravity quer fornecer o output ao usuário do lado de fora, ele é livre para executar uma simples requisição cURL/Fetch ao localhost disparando o webhook.
- **Envio no Telegram:** O bot recebe o Payload do `POST /reply` e transmite os dados usando `bot.sendMessage` para o chat whitelist original e id seguro.

## Componentes Chaves criados:
- `skills/antigravity/telegram-bridge/index.js`: O código mestre da ponte.
- `skills/antigravity/telegram-bridge/.env`: Tokens de ambiente e IDs seguras.
- `skills/antigravity/telegram-bridge/boot-daemon.vbs`: Inicializador invisível (silencioso).
- `skills/antigravity/telegram-bridge/stop-daemon.cmd`: Mata o processo node da porta configurada a qualquer instante para restarts.
- `skills/antigravity/scripts/execute.ps1`: Ponto de contato de injeção na aplicação do Antigravity.
