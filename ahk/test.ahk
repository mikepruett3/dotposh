;========== Show and Hide Hidden Files Hotkey ==========
; CTRL + F2
;^F2::
;CheckActiveWindow()
;Return
#If WinActive("ahk_class ExploreWClass") or WinActive("ahk_class CabinetWClass")
{
    ^F2::
    ToggleHiddenFilesDisplay()
    Return
}
#If