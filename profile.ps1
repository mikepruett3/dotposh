# Set-ExecutionPolicy Unrestricted -- From Administrator Console

# Module Imports
Import-Module PSReadLine

# Setting environment variables
$Arch = $Env:PROCESSOR_ARCHITECTURE
$UserProfile = $Env:USERPROFILE
$UserName = $Env:USERNAME
$AppData = $Env:APPDATA

# Shell History Settings
$MaximumHistoryCount = 2048
$Global:histfile = "$Env:USERPROFILE\.history.csv"
$truncateLogLines = 100

# Shell customization settings
Set-Location $UserProfile\scripts
$Shell = $Host.UI.RawUI

# Unzip function
Function unzip ([string]$filename){
    & "$Env:ProgramFiles\7-Zip\7z.exe" e $filename
}

# History Function
Function work-history {
    $history = @()
    $history += '#TYPE Microsoft.PowerShell.Commands.HistoryInfo'
    $history += '"Id","CommandLine","ExecutionStatus","StartExecutionTime","EndExecutionTime"'
    if (Test-Path $histfile) {
        $history += (get-content $histfile)[-$truncateLogLines..-1] | where {$_ -match '^"\d+"'}
    }
    $history > $histfile
    $history | select -Unique | Convertfrom-csv -errorAction SilentlyContinue | Add-History -errorAction SilentlyContinue
}

# Get-RedirectedUrl Function - http://stackoverflow.com/questions/25125818/powershell-invoke-webrequest-how-to-automatically-use-original-file-name
Function Get-DownloadFileName {
    Param (
        [Parameter(Mandatory=$true)]
        [String]$URL
    )
    $request = Invoke-WebRequest $url | Select -ExpandProperty Headers
    $equalpos = $request.Get_Item("Content-Disposition").IndexOf("=")
    return $request.Get_Item("Content-Disposition").SubString($equalpos + 1)
}

Function Get-DownloadFile {
    Param (
        [Parameter(Mandatory=$true)]
        [String]$URL
    )
    $filename = Get-DownloadFileName $url
    return Invoke-WebRequest $url -OutFile $filename
}

# Overwrite Existing WGET Alias
Set-Alias -Name wget -Value Get-DownloadFile -Option AllScope

# Alias definitions
New-Alias -Name which -Value "Get-Command" -Description "Alias for Get-Command, mimic's Linux which command"
New-Alias -Name grep -Value "Select-String" -Description "Alias for Select-String, mimic's Linux grep command"
New-Alias -Name ll -Value "Get-ChildItem" -Description "Alias for Get-ChildItem, like 'ls' from linux."
New-Alias -Name l -Value "Get-ChildItem" -Description "Alias for Get-ChildItem, like 'ls' from linux."

#Call Work-History Function
work-history

Function prompt {
    $hid = $myinvocation.historyID
    if ($hid -gt 1) {
        get-history ($myinvocation.historyID -1 ) | convertto-csv | Select -last 1 >> $histfile
    }
    $(if (test-path variable:/PSDebugContext) { '[DBG]: ' } else { '' }) + "#$([math]::abs($hid)) PS$($PSVersionTable.psversion.major) " + $(Get-Location) + $(if ($nestedpromptlevel -ge 1) { '>>' }) + '> '
}
