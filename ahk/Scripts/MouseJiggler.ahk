; Code from MouseJiggler project
; https://github.com/BryanKoehn/MouseJiggler

; Loop Help from - https://www.autohotkey.com/boards/viewtopic.php?t=24501
Loop
{
   While (Toggle)
   {
      MouseGetPos, xPos, yPos
      if (xPos = oldX && yPos = oldY)
      {
         MouseMove,xPos - 25, yPos - 50
         MouseMove,xPos, yPos
         oldX = %xPos%
         oldY = %yPos%
         Sleep, 90000
         ;Sleep, 9000
      } else {
         oldX = %xPos%
         oldY = %yPos%
         Sleep, 30000
         ;Sleep, 3000
      }
   }
}
Return

RemoveToolTip:
ToolTip
Return

^F8::
Toggle := !Toggle
If (Toggle){
   ToolTip, Jiggler Activating...
   SetTimer, RemoveToolTip, -2000
} Else {
   ToolTip, Jiggler Deactivating...
   SetTimer, RemoveToolTip, -2000
}
