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

# Remote Exchange PowerShell Session
# https://docs.microsoft.com/en-us/powershell/exchange/exchange-server/connect-to-exchange-servers-using-remote-powershell?view=exchange-ps
function Connect-Exchange {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True)]
        [string]$Server,
        [Parameter(Mandatory=$True)]
        [string]$Credential
    )
    begin {
        $UserCredential = Get-Credential("$Credential")
        if (!(Test-Connection -Count 1 -ComputerName $Server -Quiet )) {
            Write-Error "Cannot ping $Server!!!"
            Break
        }
    }
    process {
        $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$Server/PowerShell/ -Authentication Kerberos -Credential $UserCredential
        Import-PSSession $Session -DisableNameChecking
    }
    end {
        $Server = $NULL
        $Credential = $NULL
        $UserCredential = $NULL
        $Session = $NULL
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

# Create edit Function, based on EDITOR variable
if ($Env:EDITOR -eq $NULL) {
    if ( Get-Command "code" -ErrorAction SilentlyContinue ) {
        Function edit($file) { code $file }
    } else {
        Function edit($file) { notepad $file }
    }
} else {
    Function edit($file) { Start-Process -FilePath $Env:EDITOR -ArgumentList $file }
}

# Remove existing aliases from Shell
if ( Get-Command "ls.exe" -ErrorAction SilentlyContinue ) {
    Remove-Item alias:ls
}
if ( Get-Command "wget.exe" -ErrorAction SilentlyContinue ) {
    Remove-Item alias:wget
}
if ( Get-Command "curl.exe" -ErrorAction SilentlyContinue ) {
    Remove-Item alias:curl
}
#Remove-Item alias:dir

# inline functions, aliases and variables
# https://github.com/scottmuc/poshfiles
Function which($name) { Get-Command $name | Select-Object Definition }
Function rm-rf($item) { Remove-Item $item -Recurse -Force }
Function touch($file) { "" | Out-File $file -Encoding ASCII }
#Function dir($path) { Get-ChildItem -name $path }
Function ll($path) { ls -l }
Function l($path) { ls -la }
#Function ll($path) { Get-ChildItem -force $path }
Function hc { Get-History -count $MaximumHistoryCount }
Function ep { edit $Profile }
function Remove-AllPSSessions { Get-PSSession | Remove-PSSession }

# Alias definitions
Set-Alias grep      Select-String
Set-Alias grepr     Select-StringRecurse
Set-Alias sta       Start-Transcript
Set-Alias str       Stop-Transcript
Set-Alias hh        Get-History
Set-Alias gcid      Get-ChildItemDirectory
Set-Alias vi        edit
Set-Alias ia        Invoke-Admin
Set-Alias ica       Invoke-CommandAdmin
Set-Alias isa       Invoke-ScriptAdmin
Set-Alias exch      Connect-Exchange
Set-Alias kpss      Remove-AllPSSessions

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
