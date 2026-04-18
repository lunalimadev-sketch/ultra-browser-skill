# get-response.ps1
# Captura resposta da janela do Antigravity

param(
    [Parameter()]
    [int]$TimeoutSeconds = 90,
    [int]$PollInterval = 4,
    [string]$WindowTitle = "Antigravity"
)

[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

Add-Type -ReferencedAssemblies System.Windows.Forms @"
using System;
using System.Runtime.InteropServices;
public class AgyWin32 {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
}
"@

function Get-AntigravityResponse {
    param([int]$Timeout, [int]$PollInterval, [string]$Title)
    
    $hWnd = [AgyWin32]::FindWindow($null, $Title)
    if ($hWnd -eq [IntPtr]::Zero) {
        $procs = Get-Process -Name "Antigravity" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero }
        if ($procs) { $hWnd = $procs[0].MainWindowHandle }
    }
    
    if ($hWnd -eq [IntPtr]::Zero) {
        Write-Error "Janela Antigravity nao encontrada"
        return $null
    }
    
    Write-Host "[~] Focando janela..."
    [AgyWin32]::SetForegroundWindow($hWnd)
    Start-Sleep -Milliseconds 800
    
    $startTime = Get-Date
    $lastResponse = ""
    $stableCount = 0
    
    while (((Get-Date) - $startTime).TotalSeconds -lt $Timeout) {
        Start-Sleep -Seconds $PollInterval
        
        [System.Windows.Forms.SendKeys]::SendWait("^{END}")
        Start-Sleep -Milliseconds 300
        [System.Windows.Forms.SendKeys]::SendWait("^a")
        Start-Sleep -Milliseconds 200
        [System.Windows.Forms.SendKeys]::SendWait("^c")
        Start-Sleep -Milliseconds 400
        
        try {
            $text = [System.Windows.Forms.Clipboard]::GetText()
            
            # Filtra linhas que parecem resposta de IA
            $lines = $text -split "`n" | Where-Object { 
                $_ -match "^[A-Za-zãéíóúàèìòùäëïöüâîûô]" -and $_.Length -gt 10 
            }
            $responseText = ($lines -join "`n").Trim()
            
            if ($responseText -and $responseText.Length -gt 15 -and $responseText -ne $lastResponse) {
                Write-Host "[~] Nova: $($responseText.Length) chars"
                $lastResponse = $responseText
                $stableCount = 0
            } elseif ($responseText -and $responseText -eq $lastResponse -and $responseText.Length -gt 20) {
                $stableCount++
                Write-Host "[=] Estavel ($stableCount/3)"
                if ($stableCount -ge 3) {
                    Write-Host "[OK] Resposta capturada"
                    return $lastResponse
                }
            }
        } catch {}
        
        Write-Host "." -NoNewline
    }
    
    Write-Host ""
    return $lastResponse
}

$result = Get-AntigravityResponse -Timeout $TimeoutSeconds -PollInterval $PollInterval -Title $WindowTitle

if ($result -and $result.Length -gt 5) {
    Write-Host "[OK] Result: $($result.Length) chars"
    $result
    exit 0
} else {
    Write-Error "Timeout ou resposta vazia"
    exit 1
}