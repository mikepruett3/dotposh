<#
.SYNOPSIS
    Record Desktop to MP4 file
.DESCRIPTION
    Function that launches VLC to record the Desktop of Monitor #1 (Middle)
    to a specified MP4 file.
.NOTES
    Author: Mike Pruett
    Date: May 25th, 2024
    Requires: Videl Lan Player (VLC)
    vlc.exe must be available in the current shell path.
.LINK
    VLC - https://videolan.org
.PARAMETER Path
    Path to the recording output. Must end in .mp4
.EXAMPLE
    > Record-Screen -Path C:\Users\MyUser\Desktop\example.mp4
#>
function Record-Screen {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [System.IO.FileInfo]
        #[String]
        $Path
    )

    begin {
        # Check if vlc.exe is in the path, if not break
        Write-Verbose "Check if vlc.exe is in the path..."
        if ( ! (Get-Command "vlc.exe" -ErrorAction SilentlyContinue ) ) {
            Write-Error "vlc.exe not found in path!`nDownload from https://videolan.org, and place in path!"
            Break
        }
    }

    process {
        Write-Verbose "Recording screen to file $Path!"
        Write-Output $Path
        $SOUT = "#transcode{vcodec=mp4v,acodec=mp4a,fps=60}:std{access=file,dst=$Path}:display{novideo,noaudio}"
        vlc --screen-fps=60.000000 `
            --screen-left=1920 `
            --screen-width=1920 `
            --screen-height=1080 `
            --live-caching=300 `
            screen:// `
            --sout "$SOUT"
    }

    end {
        # Cleanup used Variables
        Write-Verbose "Cleaning up used Variables..."
        Remove-Variable -Name "Path" -ErrorAction SilentlyContinue
    }
}