function Find-StringInLogs {
    <#
    .SYNOPSIS
        Creates an Object of any log files matching a specific string of text
    .DESCRIPTION
        Function that searches text files for a matching string, based on the
        Start & End date. The resulting Object lists the file names that matched
        Usefull for searching SMTP logs for Email Addresses or Events.       
    .PARAMETER Path
        Path to the log files to search.
    .PARAMETER String
        String of text to search for.
    .PARAMETER StartDate
        Starting date of the Oldest log file to look at
    .PARAMETER EndDate
        Ending date of the Newest log file to look at
    .EXAMPLE
        To Search SMTP Logs for email addresses:
        > Find-StringInLogs -Path C:\inetpub\logs\SMTPSVC1 -StartDate 09/01/21 -EndDate 09/30/21 -String my@example.com

        To Search SMTP Logs for an array of email addresses:
        > $Addresses = @("1st@example.com", "2nd@example.com", "3rd@example.com")
        foreach ($Address in $Addresses) {
            Find-StringInLogs -Path C:\inetpub\logs\SMTPSVC1 -StartDate 09/01/21 -EndDate 09/30/21 -String $Address -Verbose
        }
    .NOTES
        Author: Mike Pruett
        Date: October 5th, 2021
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string]
        $Path,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $String,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $StartDate,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $EndDate
    )
    
    begin {
        # Creating an Array of established log file extensions
        $Patterns = @("*.log", "*.txt")

        # Checking for any matching $Patterns in $Path
        foreach ($Item in $Patterns) {
            if (Get-ChildItem -Path "$Path" -Recurse -Include "$Item") {
                $Pattern = "$Item"
            }
        }

        # Checking in $Pattern blank
        if (!$Pattern) {
            Write-Error "Unable to find any files matching established log file extensions in $Path !!!"
            Break
        }
        
        # Creating an Object of log files from $Path
        Write-Verbose "Creating an Object of log files from $Path"
        try {
            $Files = $(Get-ChildItem -Path "$Path" -Recurse -Include "$Pattern" | Where-Object {$_.CreationTime -ge "$StartDate" -and $_.CreationTime -le "$EndDate"})
        }
        catch {
            Write-Error "Unable to find any Log files in $Path !!!"
            Break
        }
    }
    
    process {
        # Define Result array
        $Result = @()

        # Begin Simple Search through Log files
        Write-Verbose "Checking for $String in files..."
        
        # Cleanup Item Variable for reuse
        Remove-Variable -Name "Item" -ErrorAction SilentlyContinue

        foreach ($Item in $Files) {
            $Output = @()
            if ($Output = Select-String -Pattern "$String" -SimpleMatch -Path "$Item" | Select-Object -Unique -ExpandProperty Path) {
                $Result += $Output
            }
        }
        if ($Result -ne $Null) {
            Write-Output "Found the string of text $String ; in the following files..." $Result
        }
    }
    
    end {
        # Cleanup Variables
        Write-Verbose "Cleaning up variables..."
        Remove-Variable -Name "Path" -ErrorAction SilentlyContinue
        Remove-Variable -Name "StartDate" -ErrorAction SilentlyContinue
        Remove-Variable -Name "EndDate" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Patterns" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Pattern" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Item" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Files" -ErrorAction SilentlyContinue
        Remove-Variable -Name "String" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Output" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Result" -ErrorAction SilentlyContinue
    }
}