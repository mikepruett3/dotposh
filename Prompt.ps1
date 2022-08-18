function Prompt {
    <#
    .SYNOPSIS
        Current PowerShell Prompt
    .DESCRIPTION
        Function creates my current PowerShell Prompt
    .LINK
        http://winterdom.com/2008/08/mypowershellprompt
    .EXAMPLE
        > Prompt
    .NOTES
        Author: Mike Pruett
        Date: August 26th, 2020
    #>
    #[CmdletBinding()]
    param ()
    begin {
        ## Color Variables
        #$DarkCyan = [ConsoleColor]::DarkCyan
        #$Green = [ConsoleColor]::Green
        #$Cyan = [ConsoleColor]::Cyan
        #$White = [ConsoleColor]::White
        ## Current History ID
        $HistoryID = $MyInvocation.HistoryID
    }
    process {
        if ($HistoryID -gt 1) {
            Get-History ($MyInvocation.HistoryID -1 ) | ConvertTo-CSV | Select -Last 1 >> $HistFile
        }
        #if (Test-Path Variable:/PSDebugContext) {
        #    Write-Host '[DBG]: ' -n
        #} else {
        #    Write-Host '' -n
        #}
        #Write-Host "#$([math]::abs($HistoryID)) " -n -f $White
        #Write-Host "$([net.dns]::GetHostName()) " -n -f $Green
        #Write-Host "{" -n -f $DarkCyan
        #Write-Host "$(Shorten-Path (pwd).Path)" -n -f $Cyan
        #Write-Host "}" -n -f $DarkCyan
        #Write-Host ">" -n -f $White
        #Return ' '
    }
    end {
        #Clear-Variable -Name "DarkCyan" -ErrorAction SilentlyContinue
        #Clear-Variable -Name "Green" -ErrorAction SilentlyContinue
        #Clear-Variable -Name "Cyan" -ErrorAction SilentlyContinue
        #Clear-Variable -Name "White" -ErrorAction SilentlyContinue
        Clear-Variable -Name "HistoryID" -ErrorAction SilentlyContinue
        #Clear-Variable -Name "Location" -ErrorAction SilentlyContinue
    }
}
