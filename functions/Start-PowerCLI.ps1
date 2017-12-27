function Start-PowerCLI {
    <#
    .SYNOPSIS
        Function locates and dot-sources the correct PowerCLI Environment into running shell
    .DESCRIPTION
        Function tests to ensure that the PowerCLI PSSnapins and Environment Scripts are located, and the imports them into the running shell
    .EXAMPLE
        PS > Start-PowerCLI
        Tries to import the PowerCLI PSSnapin and Environment Script from the Defaults
    .NOTES
        Author: Mike Pruett
        Date: December 27th, 2017
    #>

    # >> No longer needed, as Script Handles the PSSnapin! <<

    # If ( ! (Get-PSSnapin VMware.VimAutomation.Core )) {
    #     Add-PSSnapin VMware.VimAutomation.Core
    # } else {
    #     Write-Error "Cannot find VMware.VimAutomation.Core PSSnapin!!"
    #     Break
    # }

    $PowerCLIEnv = "${Env:ProgramFiles(x86)}\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
    if (Test-Path $PowerCLIEnv) {
        . "$PowerCLIEnv"
    } else {
        $PowerCLIEnv = "${Env:ProgramFiles}\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
        . "$PowerCLIEnv"
    }
}