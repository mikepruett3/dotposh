function Extract-IPAddress {
    <#
    .SYNOPSIS
        Extract IP Addresses from a data set (CSV file, TXT file, etc.)
    .DESCRIPTION
        Function imports a data set from a file, and then uses Regular Expressions
        to extract IP Addresses from that data.
    .NOTES
        Borrowed code from:
        https://www.powershellbros.com/extract-ip-address-from-log-lines-using-powershell/
    .PARAMETER file
        Path to the file containing the dataset to import.
    .EXAMPLE
        > Extract-IPAddress -file C:\mydata.txt
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType 'Leaf'})]
        [string]
        $file
    )
    
    begin {
        # Import Data from File
        Write-Verbose "Importing data from $file ..."
        try { $Data = Get-Content $file }
        catch {
            Write-Error "Unable to retrieve data from $file !"
        }
        # Create new Results array
        $Results = @()
    }
    
    process {
        # Loop thru each line in $Data
        Write-Verbose "Processing each line in imported data..."
        Foreach ($line in $Data) {
            $IP = $Object1 = $null
            $IP = ($line | Select-String -Pattern "\d{1,3}(\.\d{1,3}){3}" -AllMatches).Matches.Value
            if ($IP -notmatch "0.0.0.0"){
                $Object1 = New-Object PSObject -Property @{
                    IPAddress = $IP
                }
                $Results += $IP   
            }
        }
        # Return $Results
        Write-Verbose "Returning Results..."
        Return $Results
    }
    
    end {
        Write-Verbose "Cleaning up after processing data files..."
        Clear-Variable -Name file -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name Data -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name Results -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name line -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name IP -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name Object1 -Scope Global -ErrorAction SilentlyContinue
    }
}

#Selecting unique IPs
#$IPUnique = $Results | Select-Object IPAddress -Unique