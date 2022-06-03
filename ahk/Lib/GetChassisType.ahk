; https://www.autohotkey.com/board/topic/71509-wmi-win32-systemenclosure-query-using-com/
; https://devblogs.microsoft.com/scripting/how-can-i-determine-if-a-computer-is-a-laptop-or-a-desktop-machine/
GetChassisType()
{
    objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2")
    colChassis := objWMIService.ExecQuery("Select * from Win32_SystemEnclosure")
    For objChassis in colChassis {
    	For strChassisType in objChassis.ChassisTypes {
            switch strChassisType
            {
                Case "1":   SystemType = Other
                Case "2":   SystemType = Unknown
                Case "3":   SystemType = Desktop
                Case "4":   SystemType = LowProfileDesktop
                Case "5":   SystemType = Pizza Box
                Case "6":   SystemType = MiniTower
                Case "7":   SystemType = Tower
                Case "8":   SystemType = Portable
                Case "9":   SystemType = Laptop
                Case "10":  SystemType = Notebook
                Case "11":  SystemType = Handheld
                Case "12":  SystemType = DockingStation
                Case "13":  SystemType = All-in-One
                Case "14":  SystemType = Sub-Notebook
                Case "15":  SystemType = SpaceSaving
                Case "16":  SystemType = LunchBox
                Case "17":  SystemType = MainSystemChassis
                Case "18":  SystemType = ExpansionChassis
                Case "19":  SystemType = Sub-Chassis
                Case "20":  SystemType = BusExpansionChassis
                Case "21":  SystemType = PeripheralChassis
                Case "22":  SystemType = StorageChassis
                Case "23":  SystemType = Rack MountChassis
                Case "24":  SystemType = Sealed-CasePC
                Case Default:  SystemType = Unknown
            }
    	}
    }
    Return SystemType
}