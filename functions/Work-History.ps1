function Work-History {
    <#
    .SYNOPSIS
        Creates a History for the current shell
    .DESCRIPTION
        Function that creates a History for the running shell, and writes it
        to a .csv file.
    .LINK
        https://docs.microsoft.com/en-us/powershell/exchange/exchange-server/connect-to-exchange-servers-using-remote-powershell?view=exchange-ps.
    .EXAMPLE
        > Work-History
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
