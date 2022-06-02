; https://www.autohotkey.com/boards/viewtopic.php?t=69925
GetActiveExplorerPath()
{
    explorerHwnd := WinActive("ahk_class CabinetWClass")
    if (explorerHwnd)
    {
        for window in ComObjCreate("Shell.Application").Windows
        {
            if (window.hwnd==explorerHwnd)
            {
                return window.Document.Folder.Self.Path
			}
		}
	}
}
