# Quick script to run paperclip server
$env:PC_ROOT = "$env:USERPROFILE\.paperclip\instances\default"
Set-Location "C:\Users\Luna\.openclaw\node_modules\@paperclip-ui\cli"
node bin/paperclip.js run