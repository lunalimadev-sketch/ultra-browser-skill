---
description: Fazer uma consulta ao Perplexity AI e extrair a resposta
---

Use esta skill quando o usuário pedir expressamente para pesquisar ou perguntar algo via **Perplexity AI** (`https://www.perplexity.ai`).

O Perplexity é um mecanismo de busca com IA que fornece respostas com fontes citationadas.

## Passo a Passo

1. **Inicie o Browser Tool** usando o perfil `user` para herdar sessão e cookies.
2. Navegue para `https://www.perplexity.ai`. Aguarde o carregamento completo.
3. **Verifique o Modelo e Thinking:**
   - No canto superior esquerdo, verifique qual modelo está selecionado (ex: Sonnet 4.6, GPT-4, etc.)
   - **SEMPRE** verifique se a opção **Thinking** está marcada. Se não estiver, ative-a.
   - Se o usuário solicitar um modelo específico, clique no seletor e escolha.
4. **Localize a caixa de input** (campo principal de perguntas).
5. Digite o prompt **exato** fornecido pelo usuário. Não modifique.
6. Clique em **Enviar** (botão de seta ou Enter).
7. **Aguarde a resposta:**
   - O Perplexity mostra progresso em tempo real
   - Aguarde até que a resposta completa apareça com as **citações** (links蓝色的)
8. **Extração:**
   - Capture a resposta principal
   - Inclua as citações/fontes se disponíveis
9. **Retorne** o texto integral ao usuário, indicando qual modelo foi usado.

## Dicas

- Perplexity é óptimo para pesquisas e perguntas factuais
- Sempre inclua as fontes/links encontrados
- Se pedir para comparar informações, faça pencarian profunda