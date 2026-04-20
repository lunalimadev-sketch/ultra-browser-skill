try {
    $r = Invoke-RestMethod -Uri 'http://localhost:9222/json' -TimeoutSec 5
    $r | ForEach-Object { Write-Host "id=$($_.id) title=$($_.title) url=$($_.url)" }
} catch {
    Write-Host "ERRO: $($Error[0].Exception.Message)"
}
