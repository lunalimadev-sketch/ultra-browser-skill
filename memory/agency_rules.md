# Agency Rules - Luna Agency

Este arquivo define as regras de conduta, fluxos de trabalho e diretrizes operacionais da agência.

## 🌐 Regras de Execução do Browser Tool
- **Perfil `user`:** Utilizado exclusivamente quando o usuário pede EXPRESSAMENTE para realizar uma ação na web.
- **Perfil `openclaw`:** Utilizado OBRIGATORIAMENTE para pesquisas autônomas, validações de info ou etapas intermediárias de tasks.
- **Login:** No perfil `user`, assume-se que o usuário já está logado. No perfil `openclaw`, assume-se que é um visitante anônimo.

## 🦾 Skill: Consulta Arena AI
O fluxo completo foi movido para a skill: `workspace/skills/query-arena-ai/SKILL.md`.

**Nota:** A skill recomenda o perfil `user` (não `openclaw`) por causa do Cloudflare, e inclui fallback inteligente de modelos e tratamento de CAPTCHA.
