Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Windows.Forms

# Find windows with non-empty titles
$procs = Get-Process | Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero }
$procs | ForEach-Object {
    $title = $_.MainWindowTitle
    if ($title) {
        Write-Host "PID=$($_.Id) Name=$($_.ProcessName) Title=$title"
    }
}
