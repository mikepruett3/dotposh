# Set-ExecutionPolicy Unrestricted -- From Administrator Console

# Setting Project Environment Variables
$dotposh = "$HOME\dotposh"
if (Test-Path -Path "$HOME\Development\dotposh") {
    $dotposhrepo = "$HOME\Development\dotposh"
} else {
    if (Test-Path -Path "$HOME\Projects\dotposh") {
        $dotposhrepo = "$HOME\Projects\dotposh"
    }
}

# Shell History Settings
#$MaximumHistoryCount = 2048
$Global:HistFile = "$HOME\.history.csv"
$truncateLogLines = 100

# Custom Variables
$FAPS = $Env:FAPS
$FAPSLP = $Env:FAPSLP
$FAPSCORP = $Env:FAPSCORP
$FAPSMP = $Env:FAPSMP
$FAPSDTA = $Env:FAPSDTA

# Shell customization settings
$Shell = $Host.UI.RawUI

# Custom Module Imports
If ( Test-Path -Path "$dotposh\custom.ps1" ) {
    . "$dotposh\custom.ps1"
}

# Import Modules
if (Test-Path -Path "$HOME\Documents\WindowsPowerShell\Modules\" ) {
    foreach ( $Module in $(Get-ChildItem -Path "$HOME\Documents\WindowsPowerShell\Modules\" -Directory).Name ) {
        Import-Module $Module -ErrorAction SilentlyContinue
    }
    Remove-Variable -Name "Module" -ErrorAction SilentlyContinue
}

# Import Functions
ForEach ( $Function in $(Get-ChildItem -Path "$dotposh\functions\*.ps1" -File).Name ) {
    Import-Module "$dotposh\functions\$Function" -ErrorAction SilentlyContinue
}
Remove-Variable -Name "Function" -ErrorAction SilentlyContinue

# Create the Scripts: drive
# http://stackoverflow.com/a/146945
#If ((Test-Path -Path "$HOME\scripts") -and (Test-Path -Path "$HOME\Projects")) {
#    $NULL = New-PSDrive -Name X -PSProvider FileSystem -Root "$HOME\scripts"
#    $NULL = New-PSDrive -Name P -PSProvider FileSystem -Root "$HOME\Projects"
#}

# Create edit Function, based on EDITOR variable
if ($Env:EDITOR -eq $NULL) {
    if (Get-Command -Name code -ErrorAction SilentlyContinue) {
        Function edit($File) {
            & code $File
        }
    } else {
        Function edit($File) {
            & notepad.exe $File
        }
    }
} else {
    Function edit($Path) {
        & $ENV:EDITOR $Path
    }
}
Set-Alias -Name vi -Value edit

# Remove existing aliases from Shell
if (Get-Command -Name eza.exe -ErrorAction SilentlyContinue) {
    Remove-Item Alias:ls -Force
    $EZA_OPTIONS = @('--hyperlink','--icons')
    Function ls($Path) {
        & eza.exe $EZA_OPTIONS $Path
    }
    Function ll($Path) {
        & eza.exe $EZA_OPTIONS -l $Path
    }
    Function l($Path) {
        & eza.exe $EZA_OPTIONS -la $Path
    }
} else {
    Function ls($Path) {
        Get-ChildItem -Name -Force $Path
    }
    Function ll($Path) {
        Get-ChildItem -Force $Path
    }
}
if (Get-Command -Name wget2.exe -ErrorAction SilentlyContinue) {
    Remove-Item Alias:wget -Force
    Set-Alias -Name wget -Value wget2
} elseif (Get-Command -Name wget.exe -ErrorAction SilentlyContinue) {
    Remove-Item Alias:wget -Force
}
if (Get-Command -Name curl.exe -ErrorAction SilentlyContinue) {
    Remove-Item Alias:curl -Force
}
if (!(Get-Command -Name grep.exe -ErrorAction SilentlyContinue)) {
    Set-Alias -Name grep -Value Select-String
    Set-Alias -Name grepr -Value Select-StringRecurse
}
if (Get-Command -Name bat.exe -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -Force
    Function cat($Path) {
        & bat.exe $Path
    }
}
#Remove-Item alias:dir
#Function dir($path) { Get-ChildItem -name $path }

# inline functions, aliases and variables
# https://github.com/scottmuc/poshfiles
Function which($Name) {
    Get-Command $Name |
    Select-Object Definition
}

Function rmf($Item) {
    Remove-Item $Item -Recurse -Force
}

Function touch($File) {
    "" | Out-File $File -Encoding ASCII
}

Function hc {
    Write-Output "$(Get-History).Count lines"
}

function dwn {
    Set-Location -Path ~\Downloads
}

function dev {
    if (Test-Path -Path ~\Development) {
        Set-Location -Path ~\Development
    }
    if (Test-Path -Path ~\Projects) {
        Set-Location -Path ~\Projects
    }
}

function home {
    Set-Location -Path ~\
}

Function ep {
    Push-Location -Path $dotposhrepo
    & edit .
    Pop-Location
}

Function Remove-AllPSSessions {
    Get-PSSession |
    Remove-PSSession
}

function updp {
    Push-Location -Path $dotposh
    & git.exe pull
    Pop-Location
}

function upps {
    $Tools = @("ps-vmtools", "ps-certtools")
    foreach ($Tool in $Tools) {
        Push-Location -Path $Env:ProgramFiles\WindowsPowerShell\Modules\$Tool
        & sudo git.exe pull
        Pop-Location
    }
}

function lc {
    Get-ChildItem -File |
    Rename-Item -NewName { $_.FullName.ToLower() }
}

function rusc {
    Get-ChildItem -File |
    Rename-Item -NewName { $_.Name -replace ' ','_' }
}

function rnn($Number) {
    Get-ChildItem -File |
    Rename-Item -NewName { $_.BaseName + $Number + $_.Extension }
}

function gitreset {
    & git.exe fetch --all
    & git.exe reset --hard
    & git.exe pull
}

Remove-Item -Path Alias:gp -Force
function gp($dir) {
    Push-Location -Path $dir
    & git.exe pull
    Pop-Location
}

function Unblock-Dir($Path) {
    Get-ChildItem -Path '$Path' -Recurse |
    Unblock-File
}

function mc-cp {
    Push-Location -Path $HOME
    & mc.exe cp --recursive minio .\Images\
    Pop-Location
}

function mc-mirror {
    Push-Location -Path $HOME
    & mc.exe mirror .\Images\ minio
    Pop-Location
}

function ytd($url) {
    & youtube-dl.exe $url
}

function cping($Server) {
    ping -t $Server
}

function cping2($Server) {
    while (1) {
        Test-Connection -ComputerName $Server
    }
}

function ssh-copy-id($Server) {
    $PublicKeys = Get-Item $ENV:UserProfile\.ssh\id_*.pub
    & ssh.exe $Server "mkdir --mode=0700 -p ~/.ssh"
    & ssh.exe $Server "touch ~/.ssh/authorized_keys; chmod 0600 ~/.ssh/authorized_keys"
    foreach ($PublicKey in $PublicKeys) {
        & scp.exe $PublicKey.FullName ${Server}:/tmp/
    }
    & ssh.exe $Server "/bin/cat /tmp/id_*.pub >> ~/.ssh/authorized_keys"
    & ssh.exe $Server "/bin/rm -f /tmp/id_*.pub"
}

function dnbradio {
    & mpv.com https://dnbradio.nl/dnbradio_main.mp3
}

function demovibes {
    & mpv.com http://necta.burn.net:8000/nectarine
}

# Alias definitions
Set-Alias -Name sta -Value Start-Transcript
Set-Alias -Name str -Value Stop-Transcript
Set-Alias -Name hh -Value Get-History
Set-Alias -Name gcid -Value Get-ChildItemDirectory
Set-Alias -Name ia -Value Invoke-Admin
Set-Alias -Name ica -Value Invoke-CommandAdmin
Set-Alias -Name isa -Value Invoke-ScriptAdmin
#Set-Alias -Name exch -Value Connect-Exchange
Set-Alias -Name kpss -Value Remove-AllPSSessions

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# Call Work-History Function
Work-History

# Load Custom Prompt
#If ( Test-Path -Path "$dotposh\Prompt.ps1" ) {
    . "$dotposh\Prompt.ps1"
#}
#try { $null = gcm pshazz -ea stop; pshazz init 'default' } catch { }

# Load Starship Cross-Shell Prompt
If ( Get-Command -Name "starship.exe" ) {
    $ENV:STARSHIP_DISTRO = ""
    Invoke-Expression (&starship init powershell)
}
