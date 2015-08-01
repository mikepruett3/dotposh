# Set-ExecutionPolicy Unrestricted -- From Administrator Console

# Module Imports
#Import-Module PSReadLine

# Setting environment variables
$arch = "$Env:Processor_Architecture"
$userprofile = "$Env:UserProfile"
$username = "$Env:UserName"
$appdata = "$Env:AppData"
$dotposh = "$Env:UserProfile\dotposh"

# Shell History Settings
$MaximumHistoryCount = 2048
$Global:histfile = "$Env:USERPROFILE\.history.csv"
$truncateLogLines = 100

# Shell customization settings
Set-Location $UserProfile\scripts
$Shell = $Host.UI.RawUI

# Import Functions
Import-Module "$dotposh\functions\*.ps1"

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
