; Show and Hide Hidden Files
; https://www.maketecheasier.com/favorite-autohotkey-scripts/

ToggleHiddenFilesDisplay()
{
    RegKey = HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
    RegRead, Hidden_Status, %RegKey%, Hidden
    if (Hidden_Status=2)
    {
        RegWrite, REG_DWORD, %RegKey%, Hidden, 1
        ToolTip, Showing Hidden Files...
        SetTimer, RemoveToolTip, -2000
    } else {
        RegWrite, REG_DWORD, %RegKey%, Hidden, 2
        ToolTip, Hiding Hidden Files...
        SetTimer, RemoveToolTip, -2000
    }
    Send, {F5}
    Return
}
