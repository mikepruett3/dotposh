function Set-DateFromCSV {
    <#
    .SYNOPSIS
        Sets the date of each file found, from a CSV file
    .DESCRIPTION
        Function imports content from a CSV file (looking for at least
        two columns named 'Name' & 'Date'), then sets either the Created,
        Modified, or Accessed date for each file found in the specfied Path.
    .NOTES
        This function was created to modify all of the Created and Modified
        dates on all of the files found in a large directory (600+ files)!
    .PARAMETER File
        The fully-qualified path to the CSV formatted file.
    .PARAMETER Path
        The fully-qualified path to the directory with files to modify.
    .PARAMETER Type
        The type of operation to take on each file found.
        Creation,Created,Cre*     Update the Creation date
        Modify,Modified,Mod*      Update the Last Modified date
        Access,Accessed,Acc*      Update the Last Accessed date
        Both                      Update the Creation & Last Modified date
        All                       Update all of the dates!
    .EXAMPLE
        > Set-DateFromCSV -File "C:\myfile.csv" -Path "C:\MyDirectory\" -Type Modify
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
        [string]
        $File,
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string]
        $Path,
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [string]
        $Type
    )

    begin {
        # Strip last "\" from $Path, if included
        $Path = $Path.TrimEnd('\')

        # Import the content of the CSV file into $CSV
        $CSV = Get-Content -Path "$File" |
            ConvertFrom-Csv |
            Sort-Object -Property Name
    }

    process {
        # Navigate through each record in $CSV
        Write-Verbose "Processing each file found in $File"

        # Cleanup $File variable, for future use
        Remove-Variable -Name "File" -ErrorAction SilentlyContinue

        foreach ($Item in $CSV) {
            $Date = Get-Date -Format "MM/dd/yyyy HH:mm:ss" -Date $Item.Date
            $File = $Item.Name -Replace ':',' -'
            $File = $File -Replace '\?',''
            $File = $File -Replace '\/','&'
            if (Test-Path -Path "$Path\$File") {
                #$File = (Get-ChildItem -Path "$Path\$FileName.*").Name
                Write-Verbose "Found File: $Path\$File"
                switch -Wildcard ( $Type ) {
                    "Cre*" {
                        Write-Verbose "Setting Created date to '$Date'"
                        (Get-Item -Path "$Path\$File").CreationTime = "$Date"
                    }

                    "Mod*" {
                        Write-Verbose "Setting Modified date to '$Date'"
                        (Get-Item -Path "$Path\$File").LastWriteTime = "$Date"
                    }

                    "Acc*" {
                        Write-Verbose "Setting Accessed date to '$Date'"
                        (Get-Item -Path "$Path\$File").LastAccessTime = "$Date"
                    }

                    "Both" {
                        Write-Verbose "Setting Created date to '$Date'"
                        (Get-Item -Path "$Path\$File").CreationTime = "$Date"
                        Write-Verbose "Setting Modified date to '$Date'"
                        (Get-Item -Path "$Path\$File").LastWriteTime = "$Date"
                    }

                    "All" {
                        Write-Verbose "Setting Created date to '$Date'"
                        (Get-Item -Path "$Path\$File").CreationTime = "$Date"
                        Write-Verbose "Setting Modified date to '$Date'"
                        (Get-Item -Path "$Path\$File").LastWriteTime = "$Date"
                        Write-Verbose "Setting Accessed date to '$Date'"
                        (Get-Item -Path "$Path\$File").LastAccessTime = "$Date"
                    }

                    Default {
                        Write-Output "Nothing to do!"
                    }
                }
            } else {
                Write-Output "Unable to Find File: $Path\$File"
            }
        }
    }

    end {
        # Cleanup used Variables
        Write-Verbose "Cleaning up used Variables..."
        Remove-Variable -Name "File" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Path" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Type" -ErrorAction SilentlyContinue
        Remove-Variable -Name "CSV" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Item" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Date" -ErrorAction SilentlyContinue
    }
}