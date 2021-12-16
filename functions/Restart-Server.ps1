function Restart-Server {
    <#
    .SYNOPSIS
        Restart Windows Server from PowerShell
    .DESCRIPTION
        Function restarts a Windows Server (thats currently online),
        and then waits for the server to respond to WMI commands before
        closing.
    .PARAMETER Server
        The remote Server or Workstation to restart
    .PARAMETER Credentials
        The Domain Credentials needed to perform the restart
    .EXAMPLE
        > Restart-Server -Server host.example.com -Credentials <my-domain-creds>
    .NOTES
        Author: Mike Pruett
        Date: December 16th, 2021
        -- Made Easier with the BetterCredentials Module - https://github.com/Jaykul/BetterCredentials --
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True,ValueFromPipeline=$true)]
        [string]
        $Server,
        [Parameter(Mandatory=$True,ValueFromPipeline=$true)]
        [string]
        $Credentials
    )
    
    begin {
        # Slurp Credentials into Variable
        Write-Verbose ""
        $Creds = Get-Credential(${Credentials})

        # Ping Server to ensure its Operational
        if (!(Test-Connection -Count 1 -ComputerName ${Server} -Quiet )) {
            Write-Error "Cannot ping ${Server}!!!"
            Break
        }
    }
    
    process {
        # Restarting Server
        try { Restart-Computer -ComputerName ${Server} -Credential $Creds -Wait -For WMI}
        catch {
            Write-Error "Unable to restart $Server, please check your Credentials!!!"
            Break
        }
    }
    
    end {
        # Remove Used Variables
        Remove-Variable -Name "Server"
        Remove-Variable -Name "Credentials"
        Remove-Variable -Name "Creds"
    }
}