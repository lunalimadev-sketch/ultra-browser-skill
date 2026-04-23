# Paperclip WSL Launcher
# Run this to start Paperclip server

Write-Host "🚀 Starting Paperclip..." -ForegroundColor Cyan

# Kill any existing instances
wsl --exec bash -c "killall node 2>/dev/null" 2>$null

# Wait a bit
Start-Sleep -Seconds 2

# Start Paperclip in WSL (background)
Start-Process -FilePath "wsl" -ArgumentList "--exec", "bash", "-c", "cd /tmp && npx paperclipai@latest run" -WindowStyle Hidden

# Wait for server to start
Write-Host "⏳ Waiting for server..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Verify
try {
    $health = Invoke-WebRequest -Uri "http://127.0.0.1:3100/api/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    if ($health.StatusCode -eq 200) {
        Write-Host "✅ Paperclip is running!" -ForegroundColor Green
        Write-Host "🌐 Dashboard: http://127.0.0.1:3100" -ForegroundColor Cyan
    }
} catch {
    Write-Host "⚠️  Server may still be starting. Check manually at http://127.0.0.1:3100" -ForegroundColor Yellow
}
