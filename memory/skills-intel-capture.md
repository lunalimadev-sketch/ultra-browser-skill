# Skills Intel Capture — Referência de Melhorias

**Data de criação:** 2026-07-07
**Objetivo:** Rastrear padrões, insights e melhorias capturados de skills externas (ECC, etc.) para refinar nossas skills do MidiasNew/OpenClaw Agency.

---

## ⚡ Regra Permanente: Projetar e Atualizar Skills do GitHub

**DR Roger — 2026-07-07:** "Lembre-se de ir projetando novas ou atualizando sempre as nossas skills do github."

**Sempre que analisar uma skill externa:**
1. Capturar insights no documento acima
2. **Projetar** quais skills novas criar no repo da empresa
3. **Atualizar** skills existentes com os padrões capturados
4. Documentar as mudanças projetadas na seção "Skills Projetadas/Atualizadas"

---

## 📋 Skills ECC Analisadas (25 total)

### 1. `article-writing` — Escrita de Artigos ✅
- 5 Regras Core + Banned Patterns + Quality Gate
- **Aplicação:** `seo-content-writer`, `hook-generator`, `ad-copy-generator`, pipeline artigos

### 2. `brand-voice` — Perfil de Voz Reutilizável ✅
- VOICE PROFILE reusável, fontes por prioridade, banned patterns
- **Aplicação:** Criar skill `brand-voice` propia, integrar no briefing

### 3. `exa-search` — Busca Neural via Exa ✅
- 7 ferramentas (web, advanced, code, company, people, crawling, deep_researcher)
- Due diligence pattern: `company_research` + `web_search_advanced`
- **Aplicação:** `research-agent`, `multi-query-search`, competitive intelligence

### 4. `deep-research` — Pesquisa Profunda Multi-Fonte ✅
- 6-pass workflow, 10 regras de qualidade, paralelização com subagentes
- "Se só uma fonte diz, marcar unverified"
- **Aplicação:** `research-agent`, pipeline de artigos (Dwight), `insights`

### 5. `brand-discovery` — Descobria de Marca ✅
- 8 módulos, técnicas de entrevista (laddering, 5 Whys, projetivas)
- State protocol pra retomar sessão, multi-founder mode
- **Aplicação:** Criar skill `brand-discovery`, usar no onboarding de clientes

### 6. `competitive-platform-analysis` — Análise Competitiva (1/3) ✅
- 8 eixos, 3 tiers, scoring matrix, positioning brief obrigatório
- **Aplicação:** Criar pipeline competitivo, usar no `insights`

### 7. `competitive-report-structure` — Relatório Competitivo (3/3) ✅
- 8 seções, decision-first, trigger questions, heatmap
- **Aplicação:** Template de relatório competitivo

### 8. `market-research` — Pesquisa de Mercado ✅
- 4 modos: Investor Diligence, Competitive Analysis, Market Sizing, Technology Research
- 5 regras: fonte obrigatória, dados recentes, contrarian evidence, decisão > resumo
- Quality gate: números sourced, dados velhos flagged, recomendação segue evidência
- **Aplicação:** Criar skill `market-research`, integrar no pipeline de clientes

### 9. `x-api` — X/Twitter API ✅
- OAuth 2.0 (read) + OAuth 1.0a (write), rate limits, error handling
- Pull posts pra voice modeling, upload media, threads
- **Aplicação:** `agente-redes-sociais`, padrão de integração X API

### 10. `dynamic-workflow-mode` — Workflows Adaptativos ✅
- Task-local harnesses, eval gates, shared skill extraction
- Decision tree: one-shot → harness → shared skill → control pane
- Anti-patterns: scripts escondendo lógica, pular testes
- **Aplicação:** Metodologia pra criar e evoluir skills da agência

### 11. `council` — Conselho de 4 Vozes ✅
- 4 vozes: Architect, Skeptic, Pragmatist, Critic
- Anti-anchoring: subagentes com contexto isolado, sem histórico completo
- Output compacto: posição, raciocínio, risco, surpresa + veredicto
- **Aplicação:** Tomar decisões estratégicas quando há múltiplos caminhos

### 12. `agent-architecture-audit` — Auditoria de Agentes ✅
- 12 camadas do stack de agentes, 5 failure patterns
- Audit workflow: Scope → Evidence → Failure Mapping → Fix Strategy
- Severity model: critical/high/medium/low
- **Aplicação:** Auditar nossos agentes Paperclip, diagnosticar problemas

### 13. `social-publisher` — Publicação Multi-Canal ✅
- SocialClaw: 13 plataformas via API única
- Upload media → schedule.json → validate → publish → monitor
- **Aplicação:** Automatizar distribuição de conteúdo multi-plataforma

### 14. `autonomous-loops` — Loops Autônomos ✅
- 6 patterns: Sequential → NanoClaw REPL → Infinite Agentic Loop → Continuous PR → De-Sloppify → RFC-Driven DAG
- De-Sloppify Pattern: passo separado de cleanup > instruções negativas
- **Aplicação:** Pipelines de produção automatizada

### 15. `continuous-agent-loop` — Loop Contínuo ✅
- Selection flow: CI/PR → RFC decomposition → exploratory → sequential
- Failure modes: churn, retries sem progresso, cost drift
- Recovery: freeze → harness-audit → reduzir escopo → replay
- **Aplicação:** Monitorar e recuperar pipelines com problemas

### 16. `continuous-learning-v2` — Aprendizado Contínuo ✅
- Instinct-based: observação → padrões atômicos → confiança → evolução
- Project-scoped instincts (evita contaminação cross-project)
- Confidence scoring: 0.3 (tentative) → 0.9 (near-certain)
- Promotion: mesmo instinto em 2+ projetos com confiança ≥ 0.8
- **Aplicação:** Extrair padrões das nossas operações e evoluir skills

### 17. `architecture-decision-records` — ADRs ✅
- Formato Nygard adaptado: Context → Decision → Alternatives → Consequences
- Lifecycle: proposed → accepted → deprecated/superseded
- Categories: tech, architecture, API, data, infra, security, testing, process
- **Aplicação:** Documentar decisões técnicas da agência

### 18. `openclaw-persona-forge` — Forja de Persona (OpenClaw) ✅
- Gacha engine (8M combinações), 10 tipos de "shrimp life direction"
- Identity tension: backstory × situação atual × contradição interna
- 6 steps: Direction → Identity Tension → Boundary Rules → Name → Avatar → Output
- **Aplicação:** Criar personas de agentes OpenClaw com personalidade forte

### 19. `parallel-execution-optimizer` — Otimizador Paralelo ✅
- Lane matrix: definir paralelo/sequencial/gated antes de agir
- Verification table no final, não claims vagos de velocidade
- Rules: não paralelizar destructive commands
- **Aplicação:** Acelerar pipelines com tarefas independentes

### 20. `team-agent-orchestration` — Orquestração de Equipe ✅
- Agent Kanban: Backlog → Ready → Running → Review → Blocked → Merged → Archived
- Work items com owner, scope, state, evidence, merge gate
- Control pane: visibility antes de mais automação
- **Aplicação:** Gerenciar nossos agentes Paperclip como equipe

### 21. `social-graph-ranker` — Ranking de Grafo Social ✅
- Bridge score: B(m) = Σ w(t) · λ^(d(m,t)-1)
- Second-order expansion + engagement adjustment
- 3 tiers: warm intro → conditional → direct outreach
- **Aplicação:** Descobrir intros quentes pra networking/outreach

### 22. `marketing-campaign` — Campanha de Marketing ✅
- 4 fases: Research → Positioning → Content Production → Review
- 9 deliverables: positioning brief, landing page, emails, social, video scripts, ads, calendar
- Hard bans consistentes com article-writing
- Quality gate: 5-second test, CTA audit, tone consistency, claim audit
- **Aplicação:** Criar skill `marketing-campaign` pra launches

### 23. `literature-review` — Revisão Bibliográfica ✅
- 4 tipos: narrative, scoping, systematic, meta-analysis
- PICO framework (clinical) ou SMAR (technical)
- Search log reproduzível, dedup por DOI/PMID/título
- Extração estruturada + síntese temática com confidence levels
- **Aplicação:** Pipeline de artigos acadêmicos (Dwight)

### 24. `scholar-evaluation` — Avaliação Acadêmica ✅
- 9 dimensões: Problem, Literature, Method, Data, Analysis, Results, Limitations, Writing, Citations
- Scoring 1-5 + evidence + revision priority
- **Aplicação:** QA de artigos acadêmicos antes de entregar

### 25. `data-scraper-agent` — Coleta de Dados Automatizada ✅
- 3 camadas: COLLECT → ENRICH → STORE
- Stack gratuito: Python + BeautifulSoup + Gemini Flash (free) + GitHub Actions + Notion
- Batch API calls (nunca 1 call por item)
- AI fallback chain entre modelos Gemini
- Feedback learning system (user decisions → improve scoring)
- Directory structure completa e templates prontos
- **Aplicação:** Monitoramento de concorrentes, coleta de conteúdo, competitive intelligence

### 26. Skills não analisadas (dev-focused, baixa prioridade)
- `scientific-db-pubmed-database`, `scientific-db-uspto-database`, `scientific-pkg-gget` — APIs científicas específicas

### 27. `kimi-code` — Arquitetura de Provedor de Coding Agent (Kimi) ✅
- **Dual protocol compatível:** OpenAI (`/coding/v1`) E Anthropic (`/coding/v1/messages`) — mesmo Base URL, mesmo API Key
- **Integração via protocolo:** pluga em Claude Code, Roo Code, OpenCode, OpenClaw, Hermes — só setar Base URL + API Key + Model ID
- **Model ID estável:** `kimi-for-coding` (Standard) e `kimi-for-coding-highspeed` (HighSpeed). Backend troca o modelo real sem mudar config
- **Tier Standard/HighSpeed:** mesmo modelo, HighSpeed = ~5–6× velocidade de output, ~3× custo de quota, mesmo Base URL/Key
- **Fallback silencioso PERIGOSO:** HighSpeed com ID errado cai SILENCIOSAMENTE pro Standard (sem erro, sem aceleração)
- **Dois limites independentes:** (1) quota semanal que NÃO acumula + (2) janela móvel de 5h com rate-limit que se recupera sozinho
- **Regra anti-abuse:** manter identidade real do client (User-Agent); spoofar é violação → suspensão
- **Web search + comandos + edição de arquivos** nativos no CLI
- **Aplicação:** (1) `ultra-models-skill` — adicionar Kimi como 6º provedor; (2) `team-agent-orchestration` — knob de tier + overhead de tool-call + integração por protocolo; (3) `agent-security-super-skill` — não spoofar client identifier

---

## 🎯 Padrões Gerais Capturados (Acumulativos)

### Anti-Patterns de IA (universais)
1. "In today's rapidly evolving landscape"
2. "game-changer" / "cutting-edge" / "revolutionary"
3. "here's why this matters" como ponte
4. Vulnerabilidade forçada
5. Pergunta final só pra engajamento
6. Preenchimento genérico que não move argumento
7. "no fluff" (ironicamente é fluff)
8. "Excited to share"
9. Cadência LinkedIn thought-leader
10. Hooks de curiosidade falsa
11. Lowercase forçado
12. "world-class", "In today's competitive landscape"
13. Fake urgency sem deadline real
14. Social proof hollow ("thousands trust us")
15. CTAs genéricos ("learn more", "click here")

### Princípios de Escrita (universais)
1. Concreto antes de abstração
2. Explicar DEPOIS do exemplo
3. Prova > adjetivos
4. Nunca inventar fatos/credibilidade
5. Cada seção acrescenta algo novo
6. Cortar o genérico/templated
7. Toda afirmação precisa de fonte
8. Cross-reference — se só uma fonte diz, marcar unverified
9. Separar fato de inferência
10. Sem alucinação — dizer "não sei" quando não sabe
11. Mesma voz em todos os canais
12. CTA específico e "earned" (não pedido)

### Processo de Pesquisa (adaptável)
1. Entender objetivo (learning/decision/writing)
2. Planejar 3-5 sub-questões
3. Buscar 15-30 fontes, 2-3 variações por sub-questão
4. Ler 3-5 fontes-chave em profundidade
5. Sintetizar com citações
6. Entregar (completo ou resumo + arquivo)

### Técnicas de Entrevista (aplicáveis)
1. Uma pergunta por vez
2. Laddering — "Por que isso importa?" até valor nuclear
3. 5 Whys pra crenças/positioning
4. Detectar respostas genéricas → pedir exemplo concreto
5. Técnicas projetivas pra quebrar platô
6. Sinal de saturação — 2 probes sem info nova → fechar

### Competitive Intelligence (framework)
1. Positioning brief obrigatório antes de qualquer análise
2. 8 eixos de análise por concorrente
3. 3 tiers: Direct / Adjacent / Aspirational
4. Scoring matrix com 4 categorias de ação
5. Relatório deve responder: quem, como, onde
6. Mapa 2×2 como headline, não tabela
7. Trigger questions pra alinhamento

### Decisão Estratégica (council)
1. 4 vozes: Architect, Skeptic, Pragmatist, Critic
2. Subagentes isolados (anti-anchoring)
3. Posição inicial antes de ler vozes externas
4. Síntese com bias guardrails
5. Maior dissidência sempre visível

### Aprendizado Contínuo (instincts)
1. Observar via hooks (100% reliable, não skills)
2. Padrões atômicos com confidence scoring
3. Project-scoped (evitar contaminação)
4. Promover quando mesmo padrão aparece em 2+ projetos
5. Evoluir: instinct → cluster → skill/command/agent

### Orquestração de Equipe
1. Agent Kanban com exit criteria por coluna
2. Work items: owner, scope, state, evidence, merge gate
3. Visibility antes de automação
4. Evidence + handoff notes, não só código

### Campanha de Marketing
1. Posição ANTES de copy
2. Audience research antes de assumir linguagem
3. Cada deliverable com 1 propósito claro
4. Especificidade > adjetivos
5. Mesma voz cross-channel
6. Quality gate: 5-second test, CTA audit, claim audit

---

## 📊 Skills Projetadas/Atualizadas

| Skill | Ação | Status | Prioridade |
|-------|------|--------|------------|
| `brand-voice` (nova) | VOICE PROFILE reusável | 🟡 Planejada | 🔥 Alta |
| `brand-discovery` (nova) | 8 módulos adaptados | 🟡 Planejada | 🔥 Alta |
| `competitive-intelligence` (nova) | Pipeline 3 etapas | 🟡 Planejada | 🔥 Alta |
| `deep-research` (nova) | 6-pass workflow | 🟡 Planejada | 🔥 Alta |
| `market-research` (nova) | 4 modos + quality gate | 🟡 Planejada | 🔥 Alta |
| `marketing-campaign` (nova) | 4 fases, 9 deliverables | 🟡 Planejada | 🔥 Alta |
| `literature-review` (nova) | Revisão sistemática | 🟡 Planejada | 🟡 Média |
| `scholar-evaluation` (nova) | Avaliação com rubrica 1-5 | 🟡 Planejada | 🟡 Média |
| `council` (nova) | Conselho 4 vozes | 🟡 Planejada | 🟡 Média |
| `team-agent-orchestration` (nova) | Agent Kanban | 🟡 Planejada | 🟡 Média |
| `continuous-learning` (nova) | Instinct-based learning | 🟡 Planejada | 🟡 Média |
| `seo-content-writer` (atualizar) | Banned patterns + regras | 🟡 Planejada | 🔥 Alta |
| `hook-generator` (atualizar) | Banned patterns | 🟡 Planejada | 🔥 Alta |
| `agente-redes-sociais` (atualizar) | Banned patterns + quality gate | 🟡 Planejada | 🔥 Alta |
| `research-agent` (atualizar) | Workflow 6 passos | 🟡 Planejada | 🔥 Alta |
| `data-scraper-agent` (nova) | Coleta automatizada de dados | 🟡 Planejada | 🟡 Média |
| Pipeline artigos/TOOLS.md | Quality gate + banned patterns | 🟡 Planejada | 🔥 Alta |

---

*Última atualização: 2026-07-07 19:27 — 25 skills ECC analisadas*
| `kimi-code` (integração) | Provedor dual-protocolo p/ OpenCode/OpenClaw | 🟡 Planejada | 🟡 Média |

*Atualizado: 2026-07-12 — +1 skill externa (Kimi Code) capturada; 3 skills internas marcadas p/ update (ultra-models, team-agent-orchestration, agent-security)*

### 28. Captura de `chrome_stealth` (Dr. Roger, 2026-07-12) — filtrada p/ uso licito
- **Recebido:** script `ChromeStealth` (Playwright+CDP) + skill `chrome-stealth-navigator` via Telegram.
- **Contexto:** ambos tinham objetivo explicito de derrotar anti-bot de terceiros (Cloudflare/Akismet/PerimeterX/DataDome). Tratados como UNTRUSTED — nao executados, nao criados como skill de evasao.
- **Padroes APROVEITADOS (legitimos) ja aplicados em `ultra-browser-skill`:**
  1. CDP attach ao Chrome real (connect_over_cdp localhost:9222) — reusa sessao logada, evita login repetido.
  2. Humanized input (curva nao-linear + jitter no mouse; type char-a-char com pausas) — estabilidade em formularios reais.
  3. Challenge-wait graceful (aguardar Turnstile sem interagir, fallback) — notificar usuario se nao resolver.
- **Padroes REJEITADOS:** patch de fingerprint `navigator.webdriver -> undefined` e qualquer spoofing de identidade. Viola regra 5.7 (Client-Spoofing Defense) da `agent-security-super-skill` e ToS de plataformas.
- **Aplicacao:** secao "Real-Browser CDP Mode" adicionada a `ultra-browser-skill` (SKILL.md), com fronteira de seguranca explicita.
