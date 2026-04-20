# 🚀 OpenClaw Gateway — Otimização de Inicialização e Estabilidade

Este tutorial foca em resolver problemas de performance (lentidão extrema) e instabilidade durante o arranque do gateway OpenClaw no Windows.

---

## 🛠️ Diagnóstico de Lentidão
Se o seu gateway demora mais de **1 minuto** para inicializar ou trava em logs como `[bonjour]`, `[gateway/model-pricing]` ou `Browser control listening`, siga os passos abaixo.

### 1. Desativar o Bonjour / mDNS (Gargalo de Rede)
O serviço de discovery local (mDNS) costuma entrar em loop ou travar em certas configurações de rede do Windows, segurando o boot do gateway por minutos.

**Como resolver:**
1. Localize o arquivo `~/.openclaw/.env`.
2. Adicione a seguinte linha:
   ```env
   OPENCLAW_DISABLE_BONJOUR=1
   ```

### 2. Desabilitar Hooks Internos e Telemetria
O OpenClaw realiza diversas checagens de rede síncronas no startup (updates, pricing bootstrap, telemetria). Se houver latência com os servidores do OpenRouter ou Cloudflare, isso trava o processo.

**Como resolver:**
Execute no terminal:
```powershell
openclaw config set update.checkOnStart false
openclaw config set hooks.internal.enabled false
```

### 3. Otimizar o Browser Embutido
Se você não usa as ferramentas visuais do agente ou prefere performance pura, o carregamento da UI do Chrome (mesmo invisível) pode ser pesado.

**Como resolver:**
No arquivo `~/.openclaw/openclaw.json`, configure o browser para `headless: true`:
```json
{
  "browser": {
    "enabled": true,
    "headless": true
  }
}
```
*Dica: Se você usa a Antigravity IDE para navegar via CDP na porta 9000, você pode até desativar o browser interno (`"enabled": false`) para economizar RAM.*

### 4. Reinicialização Limpa (EADDRINUSE)
O comando `restart` às vezes falha porque o Windows não libera a porta TCP `18789` rápido o suficiente.

**Protocolo recomendado:**
```powershell
openclaw gateway stop
# Aguarde 3 segundos
Start-Sleep -Seconds 3
openclaw gateway start
```

### 5. Resiliência de Rede (Telegram & IPv6)
Se os logs mostrarem `UND_ERR_CONNECT_TIMEOUT` ou se o servidor de browser demorar muito para iniciar, o culpado pode ser a tentativa do Node.js de conectar via IPv6.

**Como resolver:**
No arquivo `openclaw.json`, force o canal Telegram a usar apenas IPv4:
```json
"channels": {
  "telegram": {
    "network": {
      "autoSelectFamily": false
    }
  }
}
```

---

## ✅ Resumo dos Benefícios
Após estas mudanças, o tempo de inicialização (startup time) deve cair de **> 4 minutos** para aproximadamente **~30-40 segundos**, com conexões de canais instantâneas.

---
*Atualizado em: 20/04/2026*
