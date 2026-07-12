---
name: "team-agent-orchestration"
description: "Orquestração de agentes como equipe: Agent Kanban, work items, ownership, merge gates, control pane."
---

# Team Agent Orchestration — Orquestração de Equipe

Gerenciar agentes como uma equipe: work items com ownership, Kanban state, branch isolation, merge gates.

## Quando Ativar

- Tarefa envolve múltiplos agentes, ferramentas ou branches
- Projeto precisa de workflow state compartilhado
- Fan-out de agentes produz output mas não produto mergeável
- Menções: squad, conductor, control pane, multi-agent

## Modelo Operacional

Cada agente é um teammate com contrato estreito:
- **Owner:** quem é responsável pelo work item
- **Scope:** arquivos, branch, superfície de tools, áreas proibidas
- **State:** backlog, ready, running, review, blocked, merged, archived
- **Evidence:** testes, screenshots, logs, review notes
- **Merge gate:** condição exata pra integração

## Agent Kanban

| Coluna | Significado | Exit Criteria |
|--------|-------------|---------------|
| Backlog | Item candidato, não shapeado | Acceptance criteria escrito |
| Ready | Shapeado e asignável | Owner e branch/worktree asignados |
| Running | Agente trabalhando | Handoff artifact + arquivos changed existem |
| Review | Trabalho completo, não merged | Testes, diff review e risk check passam |
| Blocked | Precisa de input externo ou falhou gate | Blocker com owner e próxima ação |
| Merged | Integrado na mainline | PR merged ou local main atualizado |
| Archived | Sem relevância | Motivo registrado |

### Card Schema

```json
{
  "id": "card-001",
  "title": "Criar skill X",
  "owner": "luna",
  "state": "running",
  "branch": "feature/skill-x",
  "acceptance": ["Critério 1", "Critério 2"],
  "merge_gate": "lint + testes passam",
  "handoff": "path/to/handoff.md"
}
```

## Workflow

1. **Shape the board:** converter ambição em work items com owners e merge gates
2. **Pick execution mode:** single-agent, parallel, worktree fan-out
3. **Assign boundaries:** 1 owner por card, escopo de arquivos claro
4. **Run agents:** cada agente escreve evidence e handoff notes
5. **Review in sequence:** testes → diff review → security/risk → polish
6. **Merge deliberately:** 1 integrator resolve conflitos
7. **Extract reusable skill:** se padrão se repete, promover pra `skills/`

## Speed/Knob Patterns (capturado de provedores de coding agent)

Ao orquestrar agentes que rodam modelos de coding (Kimi Code, OpenCode, etc.), dois
padrões afetam através e custo — aplicar na decisão de tier/parallelismo:

### 1. Tier knob (Standard vs HighSpeed)
- Muitos provedores oferecem tiers no MESMO modelo (ex.: Kimi `kimi-for-coding` vs
  `kimi-for-coding-highspeed`).
- "5–6× mais rápido" refere à **velocidade de geração de tokens** (output), NÃO ao tempo
  total da tarefa. O tempo total = model output + tool calls (ler/escrever arquivos, rodar
  comandos, web lookups) + execução de scripts. Se tool-calls dominam o turno, o ganho
  real é menor que o fator de velocidade.
- **Trade-off:** HighSpeed custa ~3× a quota do Standard. Usar só quando iteração rápida
  importa mais que custo.
- **Silent fallback trap:** ID de tier errado cai SILENCIOSAMENTE pro tier base (sem erro,
  sem aceleração). Sempre validar o ID exato.

### 2. Overhead-aware fan-out
- Em paralelismo, o "speedup" de N agentes é limitado pelo tempo de tool-call/execução,
  não pela geração do modelo. Não espere N× velocidade.
- Preferir fan-out em tarefas onde o gargalo é model output; para tarefas dominadas por
  I/O (builds, testes, leitura de muitos arquivos), sequencial ou poucos paralelos ganha.
- Respeitar janelas de rate-limit (ex.: janela móvel de 5h) — muito paralelo derruba quota.

### 3. Integration-by-protocol
- Provedores modernos (Kimi, OpenCode) são plugáveis via protocolo: basta setar Base URL
  + API Key + Model ID em OpenClaw/OpenCode. NÃO exigem skill de integração dedicada —
  só config. Usar protocolo em vez de wrappers quando possível (menos superfície de ataque).

## Control Pane

Mostrar:
- Work items ativos e Kanban state
- Owner, harness, branch, last heartbeat
- Links pra handoff artifacts, testes, screenshots, PRs
- Blockers agrupados por owner
- Readiness de merge por gate (não por "vibes")
- Candidatos a skill reutilizável

**Não adicionar automação até operator poder responder:** quem é owner, o que mudou, qual gate falhou, o que pode merge seguro?

## Failure Modes

- **Agent soup:** muitos agentes, sem owner ou merge gate
- **Invisible work:** output útil só em transcript
- **Board theater:** Kanban existe mas cards sem acceptance criteria
- **Overlapping writes:** agentes paralelos editando mesmos arquivos
- **Sem produto:** processo produz docs mas nada publishable

## Output Standard

Ao final de cada passo de orquestração:
- Mudanças no board/cards
- Branches merged ou pendentes
- Evidência de testes
- Blockers com owner e próxima ação
- Candidatos a nova skill
