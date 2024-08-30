function Search-ExpiredCerts {
    <#
    .SYNOPSIS
        Check the local Certificate store for expired Certificates on a remote host
    .DESCRIPTION
        Function that queries the local Certificate store on a remote host for
        expired Certificates
    .PARAMETER Server
        The remote server to establish a remote PSSession.
    .PARAMETER Credentials
        Credentials used to connect to the remote server, will prompt for password of
        the associated account. Can be in either DOMAIN\Username or Username@domain.com 
        format.
    .EXAMPLE
        > Search-ExpiredCerts -Server myserver -Credentials mycreds@example.com
    .NOTES
        Author: Mike Pruett
        Date: Feburary 4th, 2022
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $Server,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $Credentials
    )
    
    begin {
        # Import Credentials into $Creds
        $Creds = Get-Credential("$Credentials")

        # Test Server Connectivity
        if (!(Test-Connection -Count 1 -ComputerName $Server -Quiet )) {
            Write-Error "Cannot ping $Server!!!"
            Break
        }

        # Create PSSession Variable - $Session
        $Session = New-PSSession -ComputerName $Server -Credential $Creds
    }
    
    process {
        # Query the local Certificate store for Expired Certificates
        # -HideComputerName
        Return Invoke-Command -Session $Session -ScriptBlock {
            Return Get-ChildItem -Path Cert:\LocalMachine\My -Recurse -ExpiringInDays 0 | `
                   Select-Object *,@{N="CommonName";E={$_.Subject.Split(',')[0]}}
        } | Select-Object CommonName,FriendlyName,@{N="Expired On";E={$_.NotAfter}},PSComputerName
    }
    
    end {
        # Remove PSSession
        Remove-PSSession -Session $Session

        # Cleanup
        Write-Verbose "Cleaning up used Variables..."
        Clear-Variable -Name "Server" -ErrorAction SilentlyContinue
        Clear-Variable -Name "Session" -ErrorAction SilentlyContinue
        Clear-Variable -Name "Credentials" -ErrorAction SilentlyContinue
        Clear-Variable -Name "Creds" -ErrorAction SilentlyContinue
    }
}