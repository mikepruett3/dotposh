# Windows Key Manager Shortcut
Create-Shortcut -Link "$Env:AppData\Microsoft\Windows\Start Menu\Programs\Key Manager.lnk" `
                -App "$Env:SystemRoot\System32\rundll32.exe" `
                -Arguments "keymgr.dll,KRShowKeyMgr" `
                -Icon "%SystemRoot%\System32\imageres.dll, 77" `
                -Description "Windows Key Manager" `

# Windows Credential Manager Shortcut
Create-Shortcut -Link "$Env:AppData\Microsoft\Windows\Start Menu\Programs\Credential Manager.lnk" `
                -App "$Env:SystemRoot\System32\control.exe" `
                -Arguments "/name Microsoft.CredentialManager" `
                -Icon "%SystemRoot%\System32\imageres.dll, 54" `
                -Description "Windows Credential Manager" `

# Windows Credential Backup Utility Shortcut
Create-Shortcut -Link "$Env:AppData\Microsoft\Windows\Start Menu\Programs\Credential Backup Utility.lnk" `
                -App "$Env:SystemRoot\System32\credwiz.exe" `
                -Icon "%SystemRoot%\System32\credwiz.exe" `
                -Description "Windows Credential Backup Utility" `

# Administrative Tools Shortcut
Create-Shortcut -Link "$Env:AppData\Microsoft\Windows\Start Menu\Programs\Administrative Tools.lnk" `
                -App "$Env:SystemRoot\System32\control.exe" `
                -Arguments "/name Microsoft.AdministrativeTools" `
                -Icon "%SystemRoot%\System32\imageres.dll, 109" `
                -Description "Administrative Tools" `

# Active Directory Administration Center Shortcut
Create-Shortcut -Link "$Env:AppData\Microsoft\Windows\Start Menu\Programs\dsac.lnk" `
                -App "$Env:SystemRoot\System32\runas.exe" `
                -Arguments "/savecred /user:$Env:FAPS ""cmd /C Start /B %SYSTEMROOT%\System32\dsac.exe""" `
                -Icon "%SystemRoot%\System32\dsac.exe" `
                -Description "Active Directory Administration Center" `

# Active Directory Users & Computers Shortcut
Create-Shortcut -Link "$Env:AppData\Microsoft\Windows\Start Menu\Programs\ad.lnk" `
                -App "$Env:SystemRoot\System32\runas.exe" `
                -Arguments "/savecred /user:$Env:FAPS ""cmd /C Start /B %SYSTEMROOT%\System32\mmc.exe %SYSTEMROOT%\System32\dsa.msc""" `
                -Icon "%SystemRoot%\System32\dsa.msc, 1" `
                -Description "Active Directory Users & Computers" `

# Environment Variables Shortcut
Create-Shortcut -Link "$Env:AppData\Microsoft\Windows\Start Menu\Programs\Environment Variables.lnk" `
                -App "$Env:SystemRoot\System32\rundll32.exe" `
                -Arguments "sysdm.cpl,EditEnvironmentVariables" `
                -Icon "%SystemRoot%\System32\shell32.dll, 189" `
                -Description "Environment Variables" `
                #-HotKey "CTRL+SHIFT+F"

# Hosts File Shortcut
Create-Shortcut -Link "$Env:AppData\Microsoft\Windows\Start Menu\Programs\Hosts File.lnk" `
                -App "$Env:SystemRoot\System32\notepad.exe" `
                -Arguments "$Env:SystemRoot\System32\drivers\etc\hosts" `
                -Icon "%SystemRoot%\System32\imageres.dll, 73" `
                -Description "Edit the Hosts file with Notepad, running as Administrator" `
                -Admin

# System Restore Shortcut
Create-Shortcut -Link "$Env:AppData\Microsoft\Windows\Start Menu\Programs\System Restore.lnk" `
                -App "$Env:SystemRoot\System32\rstrui.exe" `
                -Icon "%SystemRoot%\System32\rstrui.exe" `
                -Description "Recover your system, using System Restore Point" `
                -Admin

# Create System Restore Point Shortcut
Create-Shortcut -Link "$Env:AppData\Microsoft\Windows\Start Menu\Programs\Create Instant System Restore Point.lnk" `
                -App "$Env:UserProfile\dotposh\tools\Instant_Restore_Point.vbs" `
                -Icon "%SystemRoot%\System32\bootux.dll, 20" `
                -Description "Create Instant System Restore Point" `
                -Admin

# my_ahk.ahk Shortcut
Create-Shortcut -Link "$Env:AppData\Microsoft\Windows\Start Menu\Programs\My AHK.lnk" `
                -App "$Env:UserProfile\dotposh\ahk\my_ahk.ahk" `
                -Icon "%UserProfile%\scoop\apps\autohotkey-installer\current\AutoHotkey.exe" `
                -Description "My AutoHotKey Launcher"