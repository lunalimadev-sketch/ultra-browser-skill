const fs = require('fs');
const backup_file = 'C:\\Users\\Luna\\.openclaw\\openclaw.json.bak.1';
const target_file = 'C:\\Users\\Luna\\.openclaw\\openclaw.json';

let raw = fs.readFileSync(backup_file, 'utf8');
if(raw.charCodeAt(0) === 0xFEFF) { raw = raw.slice(1); }
let data = JSON.parse(raw);

const keep_providers = ['deepseek', 'google', 'openrouter', 'nvidia', 'zai', 'kilocode', 'huggingface', 'opencode', 'kimi-coding', 'qwen-portal'];
if(data.models && data.models.providers){
    const providers = data.models.providers;
    for(let k in providers){
        if(!keep_providers.includes(k)){
            delete providers[k];
        }
    }
}

if(!data.channels) data.channels = {};
if(!data.channels.telegram) data.channels.telegram = {};
data.channels.telegram.enabled = true;
data.channels.telegram.botToken = '7842331840:AAHHe16KhlBDQFC6GsUgthUembQlWhnhvs4';
data.channels.telegram.dmPolicy = 'allowlist';
data.channels.telegram.allowFrom = ['6863590559', '927583799'];
data.channels.telegram.groupPolicy = 'allowlist';

if(!data.plugins) data.plugins = {};
if(!data.plugins.entries) data.plugins.entries = {};
if(!data.plugins.entries.telegram) data.plugins.entries.telegram = {};
data.plugins.entries.telegram.enabled = true;

fs.writeFileSync(target_file, JSON.stringify(data, null, 2), 'utf8');
console.log('');
