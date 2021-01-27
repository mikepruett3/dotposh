; Create a variable of folders w/ AHK files to Include
IncludeFolders = 
(comments ltrim
    %A_WorkingDir%\functions
    %A_WorkingDir%\test
)

; Set Variable for Output file
OutputFileName = %A_Temp%\my_ahk.ahk

; Delete the previous Output file
;If FileExist("%OutputFileName%")
FileDelete, %OutputFileName%

; Loop thru all of the folders in the Include variable,
; and generate a new Output file to include
Loop, Parse, IncludeFolders, `n
{
    ;MsgBox, %A_LoopField%
    Loop, %A_LoopField%\*.ahk, 0, 1
    {
        ;MsgBox %A_LoopFilePath%
        FileAppend, #Include %A_LoopFilePath% `n, %OutputFileName%
    }
    
}

; Include the new Output file
; Special Remark - https://www.autohotkey.com/docs/commands/_Include.htm#Remarks
#Include *i %A_Temp%\my_ahk.ahk
