function Start-ModPlay {
    <#
    .SYNOPSIS
        Play .MOD, .STM, or .S3M files from the current directory
    .DESCRIPTION
        Generate a list of .MOD, .STM, or .S3M files in the current
        directory, and play them using openmpt123.exe
    .LINK
        libopenmpt - https://lib.openmpt.org/libopenmpt/
    .PARAMETER Recurse
        Searches current directory, and any sub-directories for files
        to play
    .EXAMPLE
        > Start-ModPlay
    .NOTES
        Author: Mike Pruett
        Date: October 26th, 2020
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,
        HelpMessage="Search for files recursively?",
        ValueFromPipeline=$true)]
        [switch]
        $Recurse
    )
    
    begin {
        Write-Verbose "Building a list of files to play..."
        if ( $Recurse ) {
            $M3U = Get-ChildItem -Include *.mod, *.stm, *.s3m, *.xm -Recurse
        } else {
            $M3U = Get-ChildItem *.* -Include *.mod, *.stm, *.s3m, *.xm
        }

        Write-Verbose "Checking for openmpt123.exe in system path..."
        if (!(Get-Command -Name "openmpt123.exe" -ErrorAction SilentlyContinue)) {
            Write-Error "openmpt123.exe either not installed, or not in system path!"
            Break
        }
    }
    
    process {
        if ($M3U -ne $NULL) {
            Write-Verbose "Playing files..."
            openmpt123.exe --ui $M3U
        } else {
            Write-Error "Nothing to play, no matching files found!"
        }
    }
    
    end {
        Write-Verbose "Cleaning up after..."
        Clear-Variable -Name Recurse -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name M3U -Scope Global -ErrorAction SilentlyContinue
    }
}
