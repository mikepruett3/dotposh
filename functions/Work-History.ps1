function Work-History {
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
    param ()
    begin {
        # Create new History variable
        $History = @()
        $History += '#TYPE Microsoft.PowerShell.Commands.HistoryInfo'
        $History += '"Id","CommandLine","ExecutionStatus","StartExecutionTime","EndExecutionTime"'
    }
    process {
        # Look for existing History file, and import content into $History variable
        if (Test-Path $HistFile) {
            $History += (Get-Content -Path "$HistFile")[-$truncateLogLines..-1] | Where-Object {$_ -match '^"\d+"'}
        }
        # Write History back to History file
        $History > $HistFile
        $History | select -Unique | ConvertFrom-CSV -errorAction SilentlyContinue | Add-History -errorAction SilentlyContinue
    }
    
    end {
        #Clear-Variable -Name "History" -ErrorAction SilentlyContinue
    }
    
    
}
