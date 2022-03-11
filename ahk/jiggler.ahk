; Code from MouseJiggler project
; https://github.com/BryanKoehn/MouseJiggler

JigglerBeginning:
MouseGetPos, xPos, yPos
if (xPos = oldX && yPos = oldY)
{
   MouseMove,xPos - 25, yPos - 50
   MouseMove,xPos, yPos
   oldX = %xPos%
   oldY = %yPos%
   Sleep, 90000
}else{
   oldX = %xPos%
   oldY = %yPos%
   Sleep, 30000
}
Goto, JigglerBeginning
