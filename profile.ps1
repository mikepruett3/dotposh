# Set-ExecutionPolicy Unrestricted -- From Administrator Console

# Setting environment variables
$arch = "$Env:Processor_Architecture"
$userprofile = "$Env:UserProfile"
$username = "$Env:UserName"
$appdata = "$Env:AppData"
$dotposh = "$Env:UserProfile\dotposh"
if (Test-Path -Path "$UserProfile\Projects\dotposh")  {
    $dotposhrepo = "$UserProfile\Projects\dotposh"
}


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
Set-Alias -Name vi -Value edit

# Remove existing aliases from Shell
if ( Get-Command "ls.exe" -ErrorAction SilentlyContinue ) {
    Remove-Item alias:ls
    Function ll($path) { ls -l $path }
    Function l($path) { ls -la $path }
} else {
    Function ls($path) { Get-ChildItem -name -force $path }
    Function ll($path) { Get-ChildItem -force $path }
}
if ( Get-Command "wget.exe" -ErrorAction SilentlyContinue ) {
    Remove-Item alias:wget
}
if ( Get-Command "curl.exe" -ErrorAction SilentlyContinue ) {
    Remove-Item alias:curl
}
if (!( Get-Command "grep.exe" -ErrorAction SilentlyContinue )) {
    Set-Alias -Name grep -Value Select-String
    Set-Alias -Name grepr -Value Select-StringRecurse
}
#Remove-Item alias:dir
#Function dir($path) { Get-ChildItem -name $path }

# inline functions, aliases and variables
# https://github.com/scottmuc/poshfiles
Function which($name) { Get-Command $name | Select-Object Definition }
Function rm-rf($item) { Remove-Item $item -Recurse -Force }
Function touch($file) { "" | Out-File $file -Encoding ASCII }
Function hc { Get-History -count $MaximumHistoryCount }
Function ep { pushd $dotposhrepo; edit . ; popd }
Function Remove-AllPSSessions { Get-PSSession | Remove-PSSession }
function updp { pushd $dotposh; git pull; popd }
function lc { Get-ChildItem -File | Rename-Item -NewName { $_.FullName.ToLower() } }
function rusc { Get-ChildItem -File | Rename-Item -NewName { $_.Name -replace ' ','_' } }

# Alias definitions
Set-Alias -Name sta -Value Start-Transcript
Set-Alias -Name str -Value Stop-Transcript
Set-Alias -Name hh -Value Get-History
Set-Alias -Name gcid -Value Get-ChildItemDirectory
Set-Alias -Name ia -Value Invoke-Admin
Set-Alias -Name ica -Value Invoke-CommandAdmin
Set-Alias -Name isa -Value Invoke-ScriptAdmin
Set-Alias -Name exch -Value Connect-Exchange
Set-Alias -Name kpss -Value Remove-AllPSSessions

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
