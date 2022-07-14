#NoEnv                     ; Reccomended for performace and compatability with future AutoHotKey releases.
#SingleInstance Force      ; Starts all Included AutoHotKey Scripts as one - https://stackoverflow.com/questions/4565321/autohotkey-calling-one-script-from-another-script
;#Warn                     ; Enable warnings to assist with detecting common errors.
SendMode, Input            ; Reccomended for new scripts due to its superior speed and reliability.

;========== Run MouseJiggler AutoHotKey Script ==========
;DetectHiddenWindows, On
;IfWinNotExist, %A_WorkingDir%\Scripts\MouseJiggler.ahk
;{
;    Run, %A_WorkingDir%\Scripts\MouseJiggler.ahk
;}
;DetectHiddenWindows, Off

;SystemType := GetChassisType()
;RunOnSystems := "Portable Laptop Notebook Handheld DockingStation All-in-One Sub-Notebook LunchBox"
;If InStr(RunOnSystems, SystemType)
;{
;    Run, %A_WorkingDir%\Scripts\MouseJiggler.ahk
;}

;========== Include Custom AutoHotKey Script ==========
#Include, %A_WorkingDir%\Custom\Custom.ahk

;========== Text Replacement Hotkeys ==========
:*:omw::
SendInput, On My Way{!}
SendInput, {Space}
Return

:*:btw::
SendInput, By the way,
SendInput, {Space}
Return

;:*:ty::
;SendInput, Thank You
;SendInput, {Space}
;Return

:*:np::
SendInput, No Problem
SendInput, {Space}
Return

:*:kk::
SendInput, ok
SendInput, {Space}
Return

:*:ttt::
FormatTime, Time
SendRaw, %Time%
Return

::asshole::
asshole()
Return

::safeharbor::
safeharbor()
Return

;#If WinActive("ahk_class ExploreWClass") or WinActive("ahk_class CabinetWClass")
;{
;    ;========== New Text File Hotkey ==========
;    ; CTRL + SHIFT + T
;    ^+t::
;    Path := GetActiveExplorerPath()
;    NoFile = 0
;    Loop
;    {
;        IfExist, %Path%\NewTextFile%NoFile%.txt
;        {
;            NoFile++
;        } Else {
;            Break
;        }
;    }
;    FileAppend, ,%Path%\NewTextFile%NoFile%.txt
;    Return
;
;    ;========== Show and Hide Hidden Files Hotkey ==========
;    ; CTRL + F2
;    ^F2::
;    ToggleHiddenFilesDisplay()
;    Return
;
;    ;========== Move Up a Folder in File Explorer Hotkey ==========
;    ; https://www.maketecheasier.com/favorite-autohotkey-scripts/
;    ; BackSpace
;    BackSpace::
;    Send, !{Up}
;    Return
;}
;#If

;========== MacOS "Command-M"-like Hotkey ==========
; Lifted from RamValli's post - https://stackoverflow.com/questions/42918534/autohotkey-script-to-toggle-minimize-maximize-window
; WIN + M
#M::
WinGet, WindowID, ID, A
WinGet, WindowStatus, MinMax, ahk_id %WindowID%
WinMinimize, ahk_id %WindowID%
;DetectHiddenWindows, On
;If (!WindowID)
;{
;    WinGet, WindowID, ID, A
;} Else {
;    MinMaxWindow(WindowID)
;}
Return

;========== MacOS "Command-Q"-like Hotkey ==========
; WIN + Q
#Q::
WinGet, WindowID, ID, A
WinGet, WindowStatus, MinMax, ahk_id %WindowID%
WinClose, ahk_id %WindowID%
Return

;========== TextOnlyPaste Hotkey ==========
; CTRL + SHIFT + V
^+V::
TextOnlyPaste()
Return

;========== Hide/Show Taskbar Hotkey ==========
; CTRL + SHIFT + F12
^+F12::
HideShowTaskbar(hide := !hide)
Return

;========== Empty Recycle Bin Hotkey ==========
; https://www.maketecheasier.com/favorite-autohotkey-scripts/
; WIN + Delete
#Del::
FileRecycleEmpty
Return

;========== Transparency toggle, Scroll Lock ==========
; https://www.reddit.com/r/AutoHotkey/comments/lvzqlx/share_your_most_useful_ahk_scripts_my_huge/
sc046::
toggle:=!toggle
If toggle=1
{
    WinSet, Transparent, 150, A
} Else {
    WinSet, Transparent, OFF, A
}
Return

;========== Temporarily Suspend AutoHotkey Hotkey ==========
; https://www.maketecheasier.com/favorite-autohotkey-scripts/
; WIN + ScrollLock
#ScrollLock::
SplashTextOn,200,50,AutoHotKeySystem,`nSuspending Hotkeys...
Sleep, 500
Suspend
SplashTextOff
Return

;========== Reload AutoHotkey Hotkey ==========
; CTRL + R
^R::
SplashTextOn,100,50,AutoHotKeySystem,`nReloading...
Sleep, 500
Reload
SplashTextOff
Return

;========== Show IP Address Hotkey ==========
; CTRL + SHIFT + I
^+I::
;SplashTextOn,150,50,IPAddress,Your IP Address:`n%A_IPAddress1%
;Sleep, 1000
;SplashTextOff
ToolTip, Your IP Address:`n%A_IPAddress1%...
SetTimer, RemoveToolTip, -2000
Return

RemoveToolTip:
ToolTip
Return