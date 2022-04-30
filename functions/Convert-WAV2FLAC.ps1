function Convert-WAV2FLAC {
    <#
    .SYNOPSIS
        Mass convert .wav files to .flac
    .DESCRIPTION
        Function that will recursivley convert .wav files to .flac format.
    .NOTES
        File Name: Convert-WAV2FLAC.ps1
        Author: Mike Pruett
        Date: April 30th, 2022
        Requires: FFmpeg
        ffmpeg must be available in the current shell path.
    .LINK
        FFmpeg - https://ffmpeg.org
    .PARAMETER Destination
        Mandatory path to the Destination Directory, encapsulated in "quotes"
    .EXAMPLE
        > Convert-WAV2FLAC -Destination "C:\temp\"
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

        # Check for .wav files in the current directory, if not break
        Write-Verbose "Check for .wav files in the current directory..."
        if ( ! ( Get-ChildItem -Recurse "*.wav" ) ) {
            Write-Error "No .wav files found in current directory!"
            Break
        } else {
            Write-Verbose "Building a list of .wav files in the current directory..."
            $Files = $(Get-ChildItem -Include *.wav -Recurse).BaseName
        }
    }
    
    process {
        # Convert/Resize each .flac file
        foreach ($File in $Files) {
            Write-Verbose "Processing file $File!"
            try {
                ffmpeg.exe  -loglevel fatal `
                            -stats `
                            -i "$File.wav" `
                            -map_metadata:s:a 0:s:a `
                            -c:a flac `
                            -y `
                            "$Destination\$File.flac"
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
        Remove-Variable -Name "Destination"
        Remove-Variable -Name "Files"
        Remove-Variable -Name "File"
    }
}
