Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class WinAPI {
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@

$w = Get-Process -Name Antigravity | Select-Object -First 1
if($w) {
    [WinAPI]::ShowWindow($w.MainWindowHandle, 3)
    Write-Host "Maximizado!"
}
