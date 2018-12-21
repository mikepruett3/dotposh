# Set-ExecutionPolicy Unrestricted -- From Administrator Console

# Setting environment variables
$arch = "$Env:Processor_Architecture"
$userprofile = "$Env:UserProfile"
$username = "$Env:UserName"
$appdata = "$Env:AppData"
$dotposh = "$Env:UserProfile\dotposh"

# Extending the PSModulePath to include custom module location
$PSModPath = [Environment]::GetEnvironmentVariable("PSModulePath")
$PSModPath += ";$dotposh\modules\"
[Environment]::SetEnvironmentVariable("PSModulePath",$PSModPath)

# Shell History Settings
$MaximumHistoryCount = 2048
$Global:histfile = "$Env:UserProfile\.history.csv"
$truncateLogLines = 100

# Shell customization settings
# Set-Location $UserProfile\scripts
$Shell = $Host.UI.RawUI

# Module Imports
$CustomModules = "$Env:UserProfile\Documents\WindowsPowerShell\modules.ps1"
If ( Test-Path -Path $CustomModules ) {
    . $CustomModules
}

# Import Functions
$CustomFunctions = $(dir "$dotposh\functions\*.ps1") | Select-Object -ExpandProperty Name
ForEach ($Function in $CustomFunctions) {
    Import-Module "$dotposh\functions\$Function" -ErrorAction SilentlyContinue
}

# Create the Scripts: drive
# http://stackoverflow.com/a/146945
If ((Test-Path -Path "$UserProfile\scripts") -and (Test-Path -Path "$UserProfile\Projects")) {
    $NULL = New-PSDrive -Name X -PSProvider FileSystem -Root "$UserProfile\scripts"
    $NULL = New-PSDrive -Name P -PSProvider FileSystem -Root "$UserProfile\Projects"
}

# Unzip function
Function unzip ([string]$filename){
    & "$Env:ProgramFiles\7-Zip\7z.exe" e $filename
}

# Exchange PowerShell Environment Function
Function Start-ExchEnv {
    if (Test-Path -Path "C:\Program Files\Microsoft\Exchange Server\V14\bin\RemoteExchange.ps1") {
        . "C:\Program Files\Microsoft\Exchange Server\V14\bin\RemoteExchange.ps1"
        Connect-ExchangeServer -auto
    }
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

# inline functions, aliases and variables
# https://github.com/scottmuc/poshfiles
Function which($name) { Get-Command $name | Select-Object Definition }
Function rm-rf($item) { Remove-Item $item -Recurse -Force }
Function touch($file) { "" | Out-File $file -Encoding ASCII }
Remove-Item alias:dir
Function dir($path) { Get-ChildItem -name $path }
Remove-Item alias:ls
Function ls($path) { Get-ChildItem -name -force $path }
Function ll($path) { Get-ChildItem -force $path }
Function hc { Get-History -count $MaximumHistoryCount }
Function ep { gvim $Profile }

# Alias definitions
Set-Alias grep      Select-String
Set-Alias grepr     Select-StringRecurse
Set-Alias sta       Start-Transcript
Set-Alias str       Stop-Transcript
Set-Alias hh        Get-History
Set-Alias gcid      Get-ChildItemDirectory
Set-Alias vi        gvim
#set-alias wget      Get-WebItem
Set-Alias ia        Invoke-Admin
Set-Alias ica       Invoke-CommandAdmin
Set-Alias isa       Invoke-ScriptAdmin
Set-Alias exch      Start-ExchEnv

#Call Work-History Function
work-history

# Check if Docker-Machine.exe in location. If so, then bind env to Invoke-Expression
if ( Test-Path -Path "$Env:UserProfile\scoop\apps\docker-machine\current\docker-machine.exe" ) {
    # Creates Functions
    function denv { & docker-machine.exe env | Invoke-Expression }
    function dstart { docker-machine.exe start }
    function dstop { docker-machine.exe stop }
    if ( (docker-machine.exe active) -ne "No active host found" ) {
        denv
    }
}

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
