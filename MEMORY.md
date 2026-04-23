# OpenClaw Memory - Central Hub

Este é o hub central de memória. Para detalhes específicos, consulte os módulos abaixo:

## 📂 Módulos de Memória
- **[Tech Stack](memory/tech_stack.md):** Modelos, ambiente e integrações.
- **[Agency Rules](memory/agency_rules.md):** Diretrizes de browser, Arena AI e fluxos de agência.
- **[Clients & Projects](memory/clients.md):** Base de dados de clientes e projetos.
- **[Startup Optimization](docs/openclaw-startup-optimization-tutorial.md):** Guia de performance do Gateway.
- **[2026-04-16](memory/2026-04-16.md):** Registro da sessão de construção da empresa de marketing com Paperclip

## 🎓 Academic Task Manager
As instruções de execução e comandos para a gestão de tarefas acadêmicas foram movidas para a Skill: `workspace/skills/academic-task-manager/SKILL.md`.

---

## 🏢 Empresa: OpenClaw Agency
- **Foco:** Marketing e produção de conteúdo para IA para negócios
- **Pipeline:** Monitoramento de concorrentes → Writer → Editor → Publisher
- **Stack:** OpenClaw Gateway + Paperclip
- **Status:** ✅ CONECTADO!

### Configuração Paperclip (2026-04-21)
- **Company ID:** `a7e262a8-29b2-4dd3-ac7b-ee5d5e1e6b10`
- **Agents:** 4 (OpenClaw CEO, OpenClaw 2, OpenClaw 3, OpenClaw Gateway)
- **API Key:** `pcp_811885a117d80a1d2996f379f7930ab62ec6085d801c64fb`
- **API URL:** `http://localhost:3100`
- **Skill:** `~/.openclaw/skills/paperclip/SKILL.md`
- **Credentials:** `~/.openclaw/workspace/paperclip-claimed-api-key.json`

### IPs e Conectividade
- Gateway OpenClaw: `192.168.1.5:18789` (bind: lan)
- Paperclip: `localhost:3100`
- **Nota:** Gateway precisa usar IP `192.168.1.5` (não `127.0.0.1`) para Paperclip acessar

### Bug Conhecido
- O adapter `@paperclipai/adapter-openclaw-gateway` NPM está quebrado (sem manifest)
- Solução: criar agente via API com `role: "ceo"` (minúsculo) antes de fazer join request

---

*Última atualização: 21/04/2026*
