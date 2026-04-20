Get-Process | Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero } | ForEach-Object {
    $title = $_.MainWindowTitle
    $name = $_.ProcessName
    if ($title) {
        Write-Host "PID=$($_.Id) Name=$name Title=$title"
    }
}
