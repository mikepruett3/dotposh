# Set-ExecutionPolicy Unrestricted -- From Administrator Console

# Setting Environment Variables
#$arch = "$Env:Processor_Architecture"
$dotposh = "$HOME\dotposh"
if (Test-Path -Path "$HOME\Projects\dotposh")  {
    $dotposhrepo = "$HOME\Projects\dotposh"
}

# Extending the PSModulePath to include custom module location
$PSModulePath = [Environment]::GetEnvironmentVariable("PSModulePath")
$PSModulePath += ";$dotposh\modules\"
[Environment]::SetEnvironmentVariable("PSModulePath",$PSModulePath)
Clear-Variable -Name "PSModulePath" -ErrorAction SilentlyContinue

# Shell History Settings
#$MaximumHistoryCount = 2048
$Global:HistFile = "$HOME\.history.csv"
$truncateLogLines = 100

# Shell customization settings
$Shell = $Host.UI.RawUI

# Custom Module Imports
If ( Test-Path -Path "$HOME\Documents\WindowsPowerShell\modules.ps1" ) {
    . "$HOME\Documents\WindowsPowerShell\modules.ps1"
}

# Import Modules
foreach ( $Module in $(Get-ChildItem -Path "$HOME\Documents\WindowsPowerShell\Modules\" -Directory).Name ) {
    Import-Module $Module -ErrorAction SilentlyContinue
}
Clear-Variable -Name "Module" -ErrorAction SilentlyContinue

# Import Functions
ForEach ( $Function in $(Get-ChildItem -Path "$dotposh\functions\*.ps1" -File).Name ) {
    Import-Module "$dotposh\functions\$Function" -ErrorAction SilentlyContinue
}
Clear-Variable -Name "Function" -ErrorAction SilentlyContinue

# Create the Scripts: drive
# http://stackoverflow.com/a/146945
If ((Test-Path -Path "$HOME\scripts") -and (Test-Path -Path "$HOME\Projects")) {
    $NULL = New-PSDrive -Name X -PSProvider FileSystem -Root "$HOME\scripts"
    $NULL = New-PSDrive -Name P -PSProvider FileSystem -Root "$HOME\Projects"
}

# Create edit Function, based on EDITOR variable
if ($Env:EDITOR -eq $NULL) {
    if ( Get-Command "code" -ErrorAction SilentlyContinue ) {
        function edit($file) { code $file }
    } else {
        function edit($file) { notepad $file }
    }
} else {
    function edit($file) { Start-Process -FilePath $Env:EDITOR -ArgumentList $file }
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
Function hc { Write-Output "$(Get-History).Count lines" }
Function ep { pushd $dotposhrepo; edit . ; popd }
Function Remove-AllPSSessions { Get-PSSession | Remove-PSSession }
function updp { pushd $dotposh; git pull; popd }
function lc { Get-ChildItem -File | Rename-Item -NewName { $_.FullName.ToLower() } }
function rusc { Get-ChildItem -File | Rename-Item -NewName { $_.Name -replace ' ','_' } }
function rnn($number) { Get-ChildItem -File | Rename-Item -NewName { $_.BaseName + $number + $_.Extension } }
function gitreset {git fetch --all; git reset --hard origin/master; git pull}

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

# Call Work-History Function
Work-History

# Load Custom Prompt
If ( Test-Path -Path "$dotposh\Prompt.ps1" ) {
    . "$dotposh\Prompt.ps1"
}
