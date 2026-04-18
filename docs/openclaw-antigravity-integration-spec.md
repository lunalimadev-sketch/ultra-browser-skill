# Especificação de Integração: OpenClaw ↔ Antigravity IDE

## 1. Visão Geral (A Ideia)
A integração entre o **OpenClaw** (plataforma de agentes autônomos) e a **Antigravity IDE** (ambiente de desenvolvimento focado em IA baseado no Gemini) tem como objetivo unir o melhor dos dois mundos:
- **OpenClaw:** Excelente em orquestração, automação de tarefas em background, gestão de estado (memory) e tomada constante de decisões.
- **Antigravity:** Excelente em compreensão profunda de código, edição de arquivos no contexto do projeto e interação via modelos de ponta (como Gemini 3 Pro e Claude Opus).

Para unir os dois sistemas, foram desenhadas duas pontes (skills) complementares:
1. Uma **ponte de sincronização de conhecimento** (One-way Sync) que leva o contexto da IDE para os agentes OpenClaw.
2. Uma **ponte de execução** (Task Execution / Webhook Bridge) que permite ao OpenClaw acionar a Antigravity IDE remotamente e aguardar resultados.

---

## 2. Componentes e Fluxos

### 2.1. Ponte de Conhecimento (Antigravity Bridge)
*Diretório: `skills/antigravity-bridge/`*

**Objetivo:** Permitir que o OpenClaw tenha "consciência" do que foi decidido ou criado nas sessões da Antigravity, sem poluir a memória ativa (MEMORY.md).

**Fluxo de Funcionamento:**
1. **Configuração:** Um arquivo YAML (`antigravity-bridge.yaml`) define os projetos e quais caminhos do projeto Antigravity (ex: `.agent/memory`, `.gemini/GEMINI.md`, `docs/`) devem ser monitorados.
2. **Sincronização (`sync.sh`):** Pode ser ativado via CLI pelo agente ou via cron job rotineiro. Ele utiliza o `rsync` para copiar **apenas arquivos `.md`** das pastas da IDE para uma pasta de destino segura dentro do workspace do OpenClaw.
3. **Indexação Vetorial:** Essa pasta de destino está registrada na configuração nativa do OpenClaw (`memorySearch.extraPaths`). Ao entrar lá, todo o contexto é embutido em vetores automaticamente.
4. **Consulta:** Quando o OpenClaw executa a tool interna `memory_search`, os arquivos gerados pela Antigravity IDE são retornados de forma nativa e contextualizada.

### 2.2. Ponte de Execução e Automação (Antigravity Skill)
*Diretório: `skills/antigravity/`*

**Objetivo:** O agente OpenClaw cria um prompt de programação ou análise, despacha para a janela da IDE Antigravity (que tem maior consciência do código), e espera o resultado voltar.

**Fluxo de Funcionamento (Modo Bidirecional):**
1. O agente OpenClaw decide que precisa de uma refatoração ou código complexo e roda o script `bidirectional.ps1`.
2. O script limpa a área de transferência do Windows (Clipboard) para prepará-la.
3. Chama o script base de execução (`execute.ps1`), que usavia de comandos de inicialização da GUI (`agy chat --reuse-window`) para focar ou abrir a janela do Antigravity.
4. Injeção de Teclas (SendKeys): Como não há uma API "headless" para o chat na IDE nativa, o script usa simulação de teclado (`[System.Windows.Forms.SendKeys]`) para digitar o prompt (frequentemente usando o prefixo `/telegram`) e enviar com `{ENTER}`.
5. **Polling da Resposta:** De volta ao `bidirectional.ps1`, o script entra num loop aguardando. Ele periodicamente envia um `Ctrl+A`, `Ctrl+C` para tentar capturar a resposta que está sendo renderizada ou finalizada no chat da Antigravity.
6. **Webhook:** Assim que uma nova string grande é validada pelo clipboard, ele para o polling e faz uma requisição HTTP POST para um servidor local (gerenciado pelo `webhook-server.js` na porta 3101), retornando os dados capturados para a pipeline do OpenClaw.

---

## 3. Descrição dos Scripts Criados

### Scripts de Sincronização (`antigravity-bridge`)
* `sync.sh`: O core da primeira integração. Depende de `rsync` e `yq`. Faz a leitura da configuração YAML para parsear os repositórios fonte e realiza transferências com os filtros `--include='*.md'` para proteger informações sensíveis.
* `config-template.yaml`: Template da lista de projetos, descrevendo para o sync as mappings de pastas fonte (ex: repo de cliente) vs pasta de hospedagem na RAM do OpenClaw.

### Scripts de Execução (`antigravity`)
* `scripts/execute.ps1`: Script PowerShell responsável pelo "Fire-and-Forget". Ele resolve se a IDE já está rodando, usa APIs Win32 (como `user32.dll:SetForegroundWindow`) para puxar a janela correta para frente, serializa caracteres especiais (escapes) e despacha o texto na caixa de entrada em tempo real.
* `scripts/bidirectional.ps1`: Invólucro avançado do script de execução, que cuida do tráfego do prompt para a saída. Usa loops de tentativa no Clipboard. Possui timeout (`TimeoutSeconds`) e cuida do disparo do resultado json para uma `WebhookUrl`.
* `webhook-server.js`: Microservidor Node simples (porta 3101) para servir de endpoint final que escuta as respostas raspadas do clipboard e pode engatilhar o resumo para outras threads subjacentes ou plugins do próprio OpenClaw.

---

## 4. Benefícios Arquiteturais Atuais e Evolução
* **Separação de Papéis:** Modelos rápidos no OpenClaw montam a estratégia (planner, research), enquanto a Antigravity faz o _heavy lifting_ do código (executor).
* **Ausência de Chaves API Adicionais:** Ao rodar dentro da interface gráfica da Antigravity, contornamos problemas de quotas de API, reaproveitando as sessões Google autenticadas localmente.
* **Segurança:** O _Knowledge Sync_ recusa binários, configs ou secrets, limitando a ingestão do OpenClaw só aos resultados documentados (Markdown).

*(Criado de acordo com o estado do repositório em Abril/2026, com foco no sistema bridge/execute/polling).*
