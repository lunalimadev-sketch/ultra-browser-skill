# TOOLS.md - Local Notes

## CLI & Scripts
- **Google Workspace CLI:** `gws` v0.18.1 (instalado globalmente)
- **Scripts de Tarefas:** `C:\Users\Luna\.openclaw\workspace\scripts\`
  - `registrar_task.ps1`
  - `atualizar_status.ps1`
  - `consultar_task.ps1`
  - `listar_tasks.ps1`
  - `adicionar_obs.ps1`

## Paths
- **Workspace:** `C:\Users\Luna\.openclaw\workspace\`
- **Skills:** `C:\Users\Luna\.openclaw\workspace\skills\`
- **Scripts:** `C:\Users\Luna\.openclaw\workspace\scripts\`
- **Memória:** `C:\Users\Luna\.openclaw\workspace\memory\`

## Ambiente
- **OS:** Windows (PowerShell)
- **Shell:** PowerShell
- **Node:** node=v24.13.0

## 🐦 Fluxo X/Twitter — INSTRUÇÕES OBRIGATÓRIAS

Quando Dr. Roger enviar um tweet/link do X:

1. **LER** o tweet completo
2. **VERIFICAR** se a informação é verdadeira (web_search, fontes)
3. **RACIOCINAR** sobre o contexto e implicações
4. **ENGAJAR** nos comentários (reply com take pertinente)
5. **CRIAR THREAD** propria se identificar algo interessante na pesquisa

**Nunca** postar sem verificar. **Sempre** incluir fontes quando disponível.

**Formato de entrega:** NÃO enviar prints/screenshot. Enviar APENAS resumo formatado com links dos posts publicados.

**⚠️ Cuidado com ortografia:** SEMPRE revisar textos antes de postar. Exemplo de erro: "despensa" em vez de "despenca".

### 🔍 Checklist Red Flags (Posts Financeiros)
Antes de reply em posts de "gurus" ou stock picks:
1. **Fonte da receita:** Renda verificável? LinkedIn, registros?
2. **"Não cobro":** Clássica jogada de confiança — audiência pra monetizar
3. **Preços vs. real:** Níveis de compra perto do preço atual? (pump signal)
4. **Análise:** Tem fundamento/técnico ou só tickers e níveis?
5. **Bookmarks altos:** Fase de distribuição — galera salva pra copiar
6. **Padrão:** Picks "grátis" → acumula antes → distribui depois

### Browser Automation
- Perfil: openclaw (headless)
- Login: lunalimadev@gmail.com via Google
- Sessão: cookies ativos (verificar periodicamente)
- Se login expirar: re-logar via Google OAuth
- Limite: 280 chars/post sem Premium

---

## 📝 Fluxo de Briefing de Artigos (Paperclip) — INSTRUÇÕES OBRIGATÓRIAS

**Quando Taís pedir um briefing de artigo, EU INICIO o fluxo completo:**

### Passo a Passo:
1. **Coletar informações** → tema,ângulo, público-alvo, referências
2. **Criar issue no Paperclip** → empresa: MidiasNew (`e1ff4df4-ea3b-4b2b-ab0a-bd3e55cc5371`)
3. **Gerenciar pipeline completo** → até PDF gerado no GitHub
4. **Enviar URL do PDF** → Taís para review

### Pipeline de Agentes (pronto no Paperclip):
| Etapa | Agente | Função |
|-------|--------|--------|
| Research | **Dwight** (Intel & Research Specialist) | Pesquisa bibliográfica, fontes, dados |
| Redação | **Pam** (Narrative & Content Writer) | Escrita do artigo |
| PR/LinkedIn | **Rachel** (LinkedIn & PR Specialist) | Distribuição, PR |
| Engineering | **Ross** (Engineering & Code Specialist) | Formatação, PDF, GitHub |
| Social Media | **AgenteRedesSociais** | Divulgação |
| Manager | **Luna** (eu) | Orquestração, coordenação, QA |
| CEO | **Monica** | Oversight |

### Ao Criar Issue no Paperclip:
- **Título:** `Artigo: [tema]`
- **Descrição:** Briefing completo (tema, ângulo, público, referências, tom)
- **Projeto:** Usar projeto existente ou criar novo
- **Atribuir:** Dwight para research inicial
- **Dependências:** Criar subtasks para cada etapa do pipeline

### Regras:
- SEMPRE verificar no Paperclip se há infos adicionais antes de criar issue
- SEMPRE enviar URL do PDF para Taís quando gerado
- NÃO pular etapas — pipeline é sequencial
- Em caso de erro, reportar para Taís imediatamente
- **REPO FINAL:** Salvar artigo em `https://github.com/lunalimadev-sketch/openclaw-papers/tree/main/papers/` (subpasta por ano: `papers/2026/`)

---

## 🐙 GitHub
- **Repo:** `https://github.com/lunalimadev-sketch/`
- **Conta:** lunalimadev (autenticação via Gmail no navegador)
- **API Key:** `GITHUB_TOKEN` no `.env` (`~/.openclaw/.env`)
- **Uso:** `gh auth login` com token, ou `git remote add origin` + push
- **Repo de Papers:** `https://github.com/lunalimadev-sketch/openclaw-papers/`

---

## Skills Ativas
- **Academic Task Manager:** `workspace/skills/academic-task-manager/SKILL.md`
- **Find Skills:** `~/.agents/skills/find-skills/SKILL.md`
- **Context7:** `~/.openclaw/workspace/skills/context7/SKILL.md`
- **ClawFlow:** `~/AppData\Roaming\npm\node_modules\openclaw\skills\clawflow\SKILL.md`
- **ClawHub:** `~/AppData\Roaming\npm\node_modules\openclaw\skills\clawhub\SKILL.md`
- **Node Connect:** `~/AppData\Roaming\npm\node_modules\openclaw\skills\node-connect\SKILL.md`
- **Healthcheck:** `~/AppData\Roaming\npm\node_modules\openclaw\skills\healthcheck\SKILL.md`
- **Weather:** `~/AppData\Roaming\npm\node_modules\openclaw\skills\weather\SKILL.md`
- **Coding Agent:** `~/AppData\Roaming\npm\node_modules\openclaw\skills\coding-agent\SKILL.md`
- **Skill Creator:** `~/AppData\Roaming\npm\node_modules\openclaw\skills\skill-creator\SKILL.md`
- **Gemini:** `~/AppData\Roaming\npm\node_modules\openclaw\skills\gemini\SKILL.md`
- **Antigravity Bridge:** `workspace/skills/antigravity/SKILL.md` ✅ READY
- **Query Perplexity:** `workspace/skills/query-perplexity/SKILL.md`
