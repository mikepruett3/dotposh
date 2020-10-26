function Start-ModPlaylist {
    <#
    .SYNOPSIS
        Play .MOD files from M3U Playlist
    .DESCRIPTION
        Loads in files from .M3U Playlist, and plays using openmpt123.exe
    .LINK
        libopenmpt - https://lib.openmpt.org/libopenmpt/
    .PARAMETER Playlist
        Fully-Qualified path to the .M3U Playlist file to play.
        Each line in file should contain the path one .MOD, .STM, or .S3M
        file.
    .EXAMPLE
        > Start-ModPlaylist -Playlist <path-to-playlist-file>.m3u
    .NOTES
        Author: Mike Pruett
        Date: October 26th, 2020
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,
        HelpMessage="Enter Fully-Qualified path to the Playlist file.",
        ValueFromPipeline=$true)]
        [ValidateScript({Test-Path $_})]
        [Alias("File")]
        [string]
        $Playlist
    )
    
    begin {
        try {
            Write-Verbose "Ingesting files from M3U Playlist..."
            $M3U = Get-Content -Path "$Playlist"
        }
        catch {
            Write-Warning "Unable to open $M3U Playlist!"
            Break
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
        Clear-Variable -Name Playlist -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name M3U -Scope Global -ErrorAction SilentlyContinue
    }
}
