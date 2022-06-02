#NoEnv                     ; Reccomended for performace and compatability with future AutoHotKey releases.
#SingleInstance Force      ; Starts all Included AutoHotKey Scripts as one - https://stackoverflow.com/questions/4565321/autohotkey-calling-one-script-from-another-script
;#Warn                     ; Enable warnings to assist with detecting common errors.
SendMode Input             ; Reccomended for new scripts due to its superior speed and reliability.

;========== Run MouseJiggler AutoHotKey Script ==========
#Include, %A_WorkingDir%\Custom\Custom.ahk

;========== Run MouseJiggler AutoHotKey Script ==========
;#Include, %A_WorkingDir%\Scripts\MouseJiggler.ahk
pathToScript = %A_WorkingDir%\Scripts\MouseJiggler.ahk
DetectHiddenWindows, On
IfWinNotExist, %pathToScript%
{
    Run, %A_WorkingDir%\Scripts\MouseJiggler.ahk
}

;========== Text Replacement Hotkeys ==========
:*:omw::
SendInput On My Way{!}
SendInput {Enter}
Return

:*:btw::
SendInput By the way,
SendInput {Space}
Return

:*:ty::
SendInput Thank You
SendInput {Enter}
Return

:*:np::
SendInput No Problem
SendInput {Enter}
Return

:*:kk::
SendInput ok
SendInput {Enter}
Return

:*:ttt::
FormatTime, Time
SendRaw, %Time%
Return

::asshole::
SendInput I'm open to hearing what you have to say and having a discussion about it, but I have a policy of ignoring people who take a malicious approach to conversation. I felt something that you said fell under this heading, and if you'd like to try again with a kinder approach, I'd be happy to have a conversation with you.
SendInput {Enter}
Return

::safeharbor::
SendInput This message is intended only for the use of the individual or entity to which it is addressed. If the reader of this message is not the intended recipient, or the employee or agent responsible for delivering the message to the intended recipient, you are hereby notified that any dissemination, distribution or copying of this message is strictly prohibited. If you have received this communication in error, please notify us immediately by replying to the sender of this E-Mail or by telephone.
SendInput {Enter}
Return

#If WinActive("ahk_class ExploreWClass") or WinActive("ahk_class CabinetWClass")
{
    ;========== New Text File Hotkey ==========
    ; CTRL + SHIFT + T
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

    ;========== Show and Hide Hidden Files Hotkey ==========
    ; CTRL + F2
    ^F2::
    ToggleHiddenFilesDisplay()
    Return

    ;========== Move Up a Folder in File Explorer Hotkey ==========
    ; https://www.maketecheasier.com/favorite-autohotkey-scripts/
    ; BackSpace
    BackSpace::
    Send !{Up}
    Return
}
#If

;========== Hide/Show Taskbar Hotkey ==========
; CTRL + SHIFT + F12
^+F12::
HideShowTaskbar(hide := !hide)
Return

;========== Empty Recycle Bin Hotkey ==========
; https://www.maketecheasier.com/favorite-autohotkey-scripts/
; Win + Delete
#Del::
FileRecycleEmpty
Return

;========== Temporarily Suspend AutoHotkey Hotkey ==========
; https://www.maketecheasier.com/favorite-autohotkey-scripts/
; Win + ScrollLock
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