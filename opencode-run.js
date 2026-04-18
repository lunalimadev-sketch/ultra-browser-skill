#!/usr/bin/env node
const { spawn } = require('child_process');
const args = process.argv.slice(2);
// Filter out problematic args and add run command
const filtered = args.filter(a => !a.includes('--output-format') && !a.includes('--append-system-prompt-file') && !a.includes('--add-dir') && !a.includes('--dangerously-skip-permissions'));
const proc = spawn('opencode', ['run', ...filtered], { 
  shell: true,
  stdio: 'inherit'
});
proc.on('exit', (code) => process.exit(code));