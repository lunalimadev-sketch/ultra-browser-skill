# Agency Rules - Luna Agency

Este arquivo define as regras de conduta, fluxos de trabalho e diretrizes operacionais da agência.

## 🌐 Regras de Execução do Browser Tool
- **Perfil `user`:** Utilizado exclusivamente quando o usuário pede EXPRESSAMENTE para realizar uma ação na web.
- **Perfil `openclaw`:** Utilizado OBRIGATORIAMENTE para pesquisas autônomas, validações de info ou etapas intermediárias de tasks.
- **Login:** No perfil `user`, assume-se que o usuário já está logado. No perfil `openclaw`, assume-se que é um visitante anônimo.

## 🦾 Skill: Consulta Arena AI
O fluxo completo foi movido para a skill: `workspace/skills/query-arena-ai/SKILL.md`.

**Nota:** A skill recomenda o perfil `user` (não `openclaw`) por causa do Cloudflare, e inclui fallback inteligente de modelos e tratamento de CAPTCHA.

## ⚠️ REGRA CRÍTICA: Sessões Técnicas com Perplexity Sonnet

**OBRIGATÓRIO:** Para decisões técnicas importantes e planejamento estratégico de tarefas, EU (Luna) DEVO:

1. **Iniciar sessão com Perplexity Sonnet** ANTES de tomar decisões complexas
2. **Consultar via API/perplexity** quando encontrar erros desconhecidos ou bloqueios
3. **Não insistir em resolver sozinha** quando o debugging exige pesquisa avançada

**Ferramentas disponíveis:**
- `perplexity.ai` (modelos premium) - para decisões técnicas complexas
- `clawhub.ai/find-skills` - para descobrir skills de integração
- `context7` - para documentação de libraries/SDKs

**Quando USAR Perplexity Sonnet:**
- Erros de API desconhecidos ou ambiguos
- Decisões de arquitetura ou stack
- Integrações com serviços externos
- Problemas de network/rede complexos
- Planejamento estratégico de tarefas

**Quando NÃO USAR:**
- Tarefas triviais (ler arquivos, comandos simples)
- Pesquisas rápidas que web_search resolve
- Execução direta de tarefas já definidas
