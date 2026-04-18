---
description: Fazer um prompt customizável em um modelo do arena.ai aberto no navegador e extrair o texto
---

Use esta skill apenas quando o usuário pedir expressamente para interrogar um modelo específico via **arena.ai** (`https://arena.ai/text/direct`).

## Passo a Passo

1. **Inicie o Browser Tool** usando o perfil `user` para herdar sessão e cookies (o Cloudflare pode bloquear sessões anônimas do `openclaw`).
2. Navegue para `https://arena.ai/text/direct`. Aguarde o carregamento completo.
3. **Seleção de Modelo:**
   - Localize o seletor de modelos no canto superior esquerdo (ao lado de "Direct").
   - Escolha o modelo solicitado pelo usuário (ex: `claude-opus-4-6-thinking`).
   - **Fallback:** Se o modelo não for encontrado, vá em "Top Text Models", selecione os top 10 e pergunte ao usuário qual deseja usar.
4. Foque na **caixa de input** (textarea principal do chat).
5. Digite o prompt **exato** fornecido pelo usuário. Não modifique nem resuma.
6. Clique em **Enviar/Submit**.
7. **Aguarde Pacientemente:**
   - Use delays de 10 a 20 segundos para verificar se a geração começou e **terminou** (cursor invisível).
   - **CAPTCHA:** Se aparecer um CAPTCHA insolúvel, pare e informe imediatamente ao usuário. Aguarde **pelo menos 45s** para ele resolver (Human-in-the-Loop).
8. **Extração:** Quando a resposta estiver completa, extraia todo o texto do último balão da conversa.
9. **Retorne** o texto integral ao usuário, indicando qual modelo foi acessado.
