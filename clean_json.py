import json
import os

backup_file = r'C:\Users\Luna\.openclaw\openclaw.json.bak.1'
target_file = r'C:\Users\Luna\.openclaw\openclaw.json'

with open(backup_file, 'r', encoding='utf-8') as f:
    data = json.load(f)

# Limpar provedores de modelo não utilizados para otimizar inicializacao
keep_providers = ['deepseek', 'google', 'openrouter', 'nvidia', 'zai', 'kilocode', 'huggingface', 'opencode', 'kimi-coding', 'qwen-portal']
if 'models' in data and 'providers' in data['models']:
    providers = data['models']['providers']
    keys = list(providers.keys())
    for k in keys:
        if k not in keep_providers:
            del providers[k]

# Configurar Telegram corretamente
if 'channels' not in data:
    data['channels'] = {}
if 'telegram' not in data['channels']:
    data['channels']['telegram'] = {}

data['channels']['telegram']['enabled'] = True
data['channels']['telegram']['botToken'] = '7842331840:AAHHe16KhlBDQFC6GsUgthUembQlWhnhvs4'
data['channels']['telegram']['dmPolicy'] = 'allowlist'
data['channels']['telegram']['allowFrom'] = ['6863590559', '927583799']
data['channels']['telegram']['groupPolicy'] = 'allowlist'

if 'plugins' not in data:
    data['plugins'] = {}
if 'entries' not in data['plugins']:
    data['plugins']['entries'] = {}
if 'telegram' not in data['plugins']['entries']:
    data['plugins']['entries']['telegram'] = {}

data['plugins']['entries']['telegram']['enabled'] = True

with open(target_file, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2)

print('Limpeza do openclaw.json concluída com sucesso.')
