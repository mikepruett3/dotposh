function Connect-Exchange {
    <#
    .SYNOPSIS
        Create a Remote PSSession to an Exchange server, and import Exchange Modules
    .DESCRIPTION
        Function that creates a Remote PSSession to an Exchange Server, then imports/ingests 
        Exchange cmdlets for use in current shell
    .LINK
        https://docs.microsoft.com/en-us/powershell/exchange/exchange-server/connect-to-exchange-servers-using-remote-powershell?view=exchange-ps
    .PARAMETER Server
        The Exchange Server to establish a Remote PSSession.
    .PARAMETER Credential
        Credentials used to connect to the Exchange Server, will prompt for password of
        the associated account. Can be in either DOMAIN\Username or Username@domain.com 
        format.
    .EXAMPLE
        > Connect-Exchange -Server exchserver.example.com -Credential mycreds@example.com
    .NOTES
        Author: Mike Pruett
        Date: August 26th, 2020
    #>
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
        Clear-Variable -Name "Server" -ErrorAction SilentlyContinue
        Clear-Variable -Name "Credential" -ErrorAction SilentlyContinue
        Clear-Variable -Name "UserCredential" -ErrorAction SilentlyContinue
        Clear-Variable -Name "Session" -ErrorAction SilentlyContinue
    }
}