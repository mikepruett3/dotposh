SetTitleMatchMode RegEx

#IfWinActive ahk_class ExploreWClass|CabinetWClass
    ; <CTRL> + <SHIFT> + T
    ^+t::
        NewTextFile()
    Return
#IfWinActive

NewTextFile() {
    WinGetText, full_path, A
    StringSplit, word_array, full_path, `n
    Loop, %word_array0% {
		IfInString, word_array%A_Index%, Address
		{
			full_path := word_array%A_Index%
			break
		}
	}
    full_path := RegExReplace(full_path, "^Address: ", "")
    StringReplace, full_path, full_path, `r, , all
    
    IfInString full_path, \
    {
        NoFile = 0
        Loop {
            IfExist %full_path%\NewTextFile%NoFile%.txt
            {
                NoFile++
            } else {
                break
            }
        }
        FileAppend, ,%full_path%\NewTextFile%NoFile%.txt
    } else {
        return
    }
}