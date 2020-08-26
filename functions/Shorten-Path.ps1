function Shorten-Path ( [string] $Path ) {
    <#
    .SYNOPSIS
        Shortens current path, for use in PowerShell Prompt
    .DESCRIPTION
        Function takes the current Path, and shortens it for use with
        the current Shell
    .LINK
        http://winterdom.com/2008/08/mypowershellprompt
    .PARAMETER Path
        Current path
    .EXAMPLE
        > Shorten-Path
    .NOTES
        Author: Mike Pruett
        Date: August 26th, 2020
    #>
    #[CmdletBinding()]
    #param ()
    begin {}
    process {
        # Replace the $HOME directory with ~
        $Location = $Path.Replace($HOME,'~')
        # Remove Prefix for UNC Paths
        $Location = $Location.Replace('^[^:]+::','')
        # make path shorter like tabs in Vim,
        # handle paths starting with \\ and . correctly 
        Return ( $Location.Replace('\\(\.?)([^\\])[^\\]*(?=\\)','\$1$2') ) 
    }
    end {
        Clear-Variable -Name "Path" -ErrorAction SilentlyContinue
        Clear-Variable -Name "Location" -ErrorAction SilentlyContinue
    }
}