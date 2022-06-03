strComputer = "."
Set objWMIService = GetObject("winmgmts:" _
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set colChassis = objWMIService.ExecQuery _
    ("Select * from Win32_SystemEnclosure")
For Each objChassis in colChassis
    For  Each strChassisType in objChassis.ChassisTypes
        Wscript.Echo strChassisType
    Next
Next