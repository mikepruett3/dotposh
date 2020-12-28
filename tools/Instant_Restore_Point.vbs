' Created by: Shawn Brink
' Created on: March 9th 2015
' Modified on: September 7th 2016
' Tutorial: https://www.tenforums.com/tutorials/4543-system-restore-point-shortcut-create-windows-10-a.html


Function GetOS    
    Set objWMI = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & ".\root\cimv2")
    Set colOS = objWMI.ExecQuery("Select * from Win32_OperatingSystem")
    For Each objOS in colOS
    If instr(objOS.Caption, "Windows 10") Then
        	GetOS = "Windows 10"
        elseIf instr(objOS.Caption, "Windows 8") Then
        	GetOS = "Windows 8"  
        elseIf instr(objOS.Caption, "Windows 7") Then
        	GetOS = "Windows 7"  
        elseIf instr(objOS.Caption, "Vista") Then
        	GetOS = "Windows Vista"
        elseIf instr(objOS.Caption, "Windows XP") Then
      		GetOS = "Windows XP"
        End If
	Next
End Function


If GetOS = "Windows XP" Then
	CreateSRP

End If

If GetOS = "Windows Vista" Or GetOS = "Windows 7" Then
         If WScript.Arguments.length =0 Then
  		Set objShell = CreateObject("Shell.Application")
		objShell.ShellExecute "wscript.exe", Chr(34) & WScript.ScriptFullName & Chr(34) & " Run", , "runas", 1 
        Else 
                CreateSRP
        End If 
End If

If GetOS = "Windows 8" Or GetOS = "Windows 10" Then
	If WScript.Arguments.length =0 Then
  		Set objShell = CreateObject("Shell.Application")
		objShell.ShellExecute "wscript.exe", Chr(34) & WScript.ScriptFullName & Chr(34) & " Run", , "runas", 1 
         Else  
               const HKEY_LOCAL_MACHINE = &H80000002
               strComputer = "."
               Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")
               strKeyPath = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore"
               strValueName = "SystemRestorePointCreationFrequency"
               oReg.SetDWORDValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,0  	
        CreateSRP  
  	End If
End If


Sub CreateSRP

	GetObject("winmgmts:\\.\root\default:Systemrestore").CreateRestorePoint "Automatic Restore Point", 7, 100

End Sub