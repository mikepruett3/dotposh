;SetTitleMatchMode RegEx

#If WinActive("ahk_class ExploreWClass") || WinActive("ahk_class CabinetWClass")
    ; <CTRL> + <SHIFT> + T
    ^+t::
        Path := GetActiveExplorerPath()
        NoFile = 0
        Loop
        {
            IfExist, %Path%\NewTextFile%NoFile%.txt
            {
                NoFile++
            } Else {
                Break
            }
        }
        FileAppend, ,%Path%\NewTextFile%NoFile%.txt
    Return
#IfWinActive

; https://www.autohotkey.com/boards/viewtopic.php?t=69925
GetActiveExplorerPath() {
	explorerHwnd := WinActive("ahk_class CabinetWClass")
	if (explorerHwnd) {
		for window in ComObjCreate("Shell.Application").Windows {
			if (window.hwnd==explorerHwnd) {
				return window.Document.Folder.Self.Path
			}
		}
	}
}
