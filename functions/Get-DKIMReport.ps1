function Get-DKIMReport {
    <#
    .SYNOPSIS
        Creates a report (object) of the Exchange Online domains and their DKIM status
    .DESCRIPTION
        Function that queries the Accepted Domains from the Exchange Online tenant, 
        and reports on the status of the DKIM configuration for each
    .NOTES
        Requires ExchangeOnlineManagement module to be loaded, and connected to
        Exchange Online PowerShell.
            https://docs.microsoft.com/en-us/powershell/exchange/connect-to-exchange-online-powershell?view=exchange-ps
    .EXAMPLE
        > Get-DKIMReport
    .NOTES
        Author: Mike Pruett
        Date: September 28th, 2021
    #>
    
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        # Check for  ExchangeOnlineManagement Module
        If ( ! (Get-Module -Name ExchangeOnlineManagement) ) {
            Write-Error " ExchangeOnlineManagement Module not loaded!"
            Break
        }

        # Collect Object of Accepted Domain names
        $Domains = $(Get-AcceptedDomain | Select-Object -ExpandProperty DomainName)
    }
    
    process {
        # Process object list and collect results
        $Result = foreach ($Domain in $Domains) {
            if ($Query = Get-DkimSigningConfig -Identity "$Domain" -ErrorAction SilentlyContinue) {
                $Object = [PSCustomObject]@{
                    Domain = "$Domain"
                    Status = $Query.Status
                    Enabled = $Query.Enabled
                }
            } else {
                $Object = [PSCustomObject]@{
                    Domain = "$Domain"
                    Status = "Invalid"
                    Enabled = "False"
                }
            }
            $Object
        }
        Return $Result
    }
    
    end {
        # Cleanup Variables
        Write-Verbose "Cleaning up variables..."
        Remove-Variable -Name "Domains" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Result" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Domain" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Query" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Object" -ErrorAction SilentlyContinue
    }
}





