function Convert-MP42OGG {
    <#
    .SYNOPSIS
        Mass convert .mp4 files to .ogg
    .DESCRIPTION
        Function that will recursivley convert .mp4 files to .ogg format.
    .NOTES
        File Name: Convert-MP42OGG.ps1
        Author: Mike Pruett
        Date: August 23rd, 2021
        Requires: FFmpeg
        ffmpeg must be available in the current shell path.
    .LINK
        FFmpeg - https://ffmpeg.org
    .PARAMETER Destination
        Mandatory path to the Destination Directory, encapsulated in "quotes"
    .EXAMPLE
        > Convert-MP42OGG -Destination "C:\temp\"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string]
        $Destination
    )
    
    begin {
        # Check if ffmpeg.exe is in the path, if not break
        Write-Verbose "Check if ffmpeg.exe is in the path..."
        if ( ! (Get-Command "ffmpeg.exe" -ErrorAction SilentlyContinue ) ) {
            Write-Error "ffmpeg.exe not found in path!`nDownload from https://ffmpeg.org, and place in path!"
            Break
        }

        # Check for .mp4 files in the current directory, if not break
        Write-Verbose "Check for .mp4 files in the current directory..."
        if ( ! ( Get-ChildItem -Recurse "*.mp4" ) ) {
            Write-Error "No .mp4 files found in current directory!"
            Break
        } else {
            Write-Verbose "Building a list of .mp4 files in the current directory..."
            $Files = $(Get-ChildItem -Include *.mp4 -Recurse).BaseName
        }
    }
    
    process {
        # Convert/Resize each .mp4 file
        foreach ($File in $Files) {
            Write-Verbose "Processing file $File!"
            try {
                ffmpeg.exe  -loglevel fatal `
                            -stats `
                            -i "$File.mp4" `
                            -acodec libvorbis `
                            -y `
                            "$Destination\$File.ogg"
            }
            catch {
                Write-Error "Unable to process file $File!"
                Break
            }
        }
    }
    
    end {
        # Cleanup
        Write-Verbose "Cleaning up used Variables..."
        Clear-Variable -Name "Destination" -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name "Files" -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name "File" -Scope Global -ErrorAction SilentlyContinue
    }
}
