# Set-ExecutionPolicy Unrestricted -- From Administrator Console

# Setting environment variables
$arch = "$Env:Processor_Architecture"
$userprofile = "$Env:UserProfile"
$username = "$Env:UserName"
$appdata = "$Env:AppData"
$dotposh = "$Env:UserProfile\dotposh"

# Shell History Settings
$MaximumHistoryCount = 2048
$Global:histfile = "$Env:UserProfile\.history.csv"
$truncateLogLines = 100

# Shell customization settings
Set-Location $UserProfile\scripts
$Shell = $Host.UI.RawUI

# Module Imports
$CustomModules = $(dir "$dotposh\modules") | Select-Object -ExpandProperty Name
ForEach ($Module in $CustomModules) {
    Import-Module "$dotposh\modules\$Module"
}

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
    $history | select -Unique | ConvertFrom-CSV -errorAction SilentlyContinue | Add-History -errorAction SilentlyContinue
}

# Alias definitions
New-Alias -Name which -Value "Get-Command" -Description "Alias for Get-Command, mimic's Linux which command"
New-Alias -Name grep -Value "Select-String" -Description "Alias for Select-String, mimic's Linux grep command"
New-Alias -Name ll -Value "Get-ChildItem" -Description "Alias for Get-ChildItem, like 'ls' from linux."
New-Alias -Name l -Value "Get-ChildItem" -Description "Alias for Get-ChildItem, like 'ls' from linux."

#Call Work-History Function
work-history

# http://winterdom.com/2008/08/mypowershellprompt
function shorten-path([string] $path) { 
   $loc = $path.Replace($HOME, '~') 
   # remove prefix for UNC paths 
   $loc = $loc -replace '^[^:]+::', '' 
   # make path shorter like tabs in Vim, 
   # handle paths starting with \\ and . correctly 
   return ($loc -replace '\\(\.?)([^\\])[^\\]*(?=\\)','\$1$2') 
}

# http://winterdom.com/2008/08/mypowershellprompt
Function prompt {
    # Color Variables
    $dcyan = [ConsoleColor]::DarkCyan
    $green = [ConsoleColor]::Green
    $cyan = [ConsoleColor]::Cyan
    $white = [ConsoleColor]::White
    $hid = $MyInvocation.HistoryID
    if ($hid -gt 1) {
        Get-History ($MyInvocation.HistoryID -1 ) | ConvertTo-CSV | Select -Last 1 >> $histfile
    }
    if (Test-Path Variable:/PSDebugContext) {
        Write-Host '[DBG]: ' -n
    } else {
        Write-Host '' -n
    }
    Write-Host "#$([math]::abs($hid)) " -n -f $white
    Write-Host "$([net.dns]::GetHostName()) " -n -f $green
    Write-Host "{" -n -f $dcyan
    Write-Host "$(shorten-path (pwd).Path)" -n -f $cyan
    Write-Host "}" -n -f $dcyan
    Write-Host ">" -n -f $white
    return ' '
}
