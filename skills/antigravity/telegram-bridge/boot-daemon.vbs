Set objShell = CreateObject("WScript.Shell")
strPath = WScript.ScriptFullName
Set objFSO = CreateObject("Scripting.FileSystemObject")
strDir = objFSO.GetParentFolderName(strPath)

' Roda o node index.js totalmente oculto (0 = Hide)
objShell.Run "cmd /c cd /d """ & strDir & """ && node index.js", 0, False
