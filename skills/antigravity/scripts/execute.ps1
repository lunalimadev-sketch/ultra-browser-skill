# antigravity-execute.ps1
# Bridge entre OpenClaw e Google Antigravity
#
# Usa modo GUI (agy chat) para continuar o contexto existente

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Prompt,

    [Parameter()]
    [string]$WorkDir = "",

    [Parameter()]
    [string[]]$AddFiles = @()
)

$ErrorActionPreference = "Stop"

function Test-AgyInstalled {
    $cmd = Get-Command agy -ErrorAction SilentlyContinue
    return ($null -ne $cmd)
}

function Send-ToGUI {
    param([string]$PromptText, [string[]]$Files)

    Add-Type -AssemblyName System.Windows.Forms

    if (-not (Test-AgyInstalled)) {
        Write-Error "ERRO: 'agy' nao encontrado no PATH."
        return $false
    }

    $chatArgs = @("chat", "--reuse-window")
    foreach ($f in $Files) {
        if (Test-Path $f) {
            $chatArgs += "--add-file"
            $chatArgs += $f
        }
    }

    Write-Host "[>] Abrindo Antigravity..." -ForegroundColor Cyan

    $proc = Start-Process -FilePath "agy" -ArgumentList $chatArgs -PassThru
    
    Write-Host "[~] Aguardando o Antigravity desbloquear..." -ForegroundColor Yellow
    Start-Sleep -Seconds 6

    if ($proc -and ($proc.HasExited -eq $false -or $proc.ExitCode -eq 0)) {
        Write-Host "[*] Injetando prompt..." -ForegroundColor Gray
        
        # Foca na janela do Antigravity
        Start-Sleep -Seconds 1
        $aggyProc = Get-Process -Name "Antigravity" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero } | Select-Object -First 1
        if ($aggyProc) {
            Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
}
"@
            [Win32]::SetForegroundWindow($aggyProc.MainWindowHandle)
            Start-Sleep -Milliseconds 500
        }
        
        $PromptToSend = $PromptText
        if (-not $PromptText.StartsWith("/telegram")) {
            $PromptToSend = "/telegram " + $PromptText
        }
        $escapedPrompt = ""
        $specialChars = "+^%~()[]{}"
        foreach ($c in $PromptToSend.ToCharArray()) {
            if ($specialChars.Contains($c)) {
                $escapedPrompt += "{" + $c + "}"
            } else {
                $escapedPrompt += $c
            }
        }
        
        $lines = $escapedPrompt -split "`r?`n"
        for ($i = 0; $i -lt $lines.Length; $i++) {
            [System.Windows.Forms.SendKeys]::SendWait($lines[$i])
            if ($i -lt $lines.Length - 1) {
                [System.Windows.Forms.SendKeys]::SendWait("+{ENTER}")
            }
        }
        
        Start-Sleep -Milliseconds 500
        [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")

        Write-Host ""
        Write-Host "[+] Prompt enviado!" -ForegroundColor Green
        return $true
    } else {
        Write-Error "agy falhou."
        return $false
    }
}

# Execucao principal
$pushedLocation = $false
if ($WorkDir -and $WorkDir.Length -gt 0 -and (Test-Path $WorkDir)) {
    Push-Location $WorkDir
    $pushedLocation = $true
}

$exitCode = 0

$guiOk = Send-ToGUI -PromptText $Prompt -Files $AddFiles
if (-not $guiOk) { $exitCode = 1 }

if ($pushedLocation) {
    Pop-Location
}

exit $exitCode