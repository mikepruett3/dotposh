# Installation:

From Command Line

    git clone https://github.com/mikepruett3/dotposh.git %UserProfile%\dotposh

From PowerShell

    git clone https://github.com/mikepruett3/dotposh.git $Env:UserProfile\dotposh

## Create symlinks:

**Needs to be run as Administrator** :

    mklink %UserProfile%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 %UserProfile%\dotposh\profile.ps1
    mklink /D %UserProfile%\Documents\WindowsPowerShell\modules\ %UserProfile%\dotposh\modules

## Installing SubModules:

Switch into the "%UserProfile%\dotposh" directory, and fetch submodules

    cd %UserProfile%\dotposh
    git submodule init
    git submodule update

## Adding New SubModules:

Adding new submodules to the directory

    cd %UserProfile%\dotposh
    git submodule add http://github.com/<username>/<repository>.git modules/<module-name>

