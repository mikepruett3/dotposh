function Convert-FLAC2MP3 {
    <#
    .SYNOPSIS
        Mass convert .flac files to .mp3
    .DESCRIPTION
        Function that will recursivley convert .flac files to .mp3 format.
    .NOTES
        File Name: Convert-FLAC2MP3.ps1
        Author: Mike Pruett
        Date: October 17th, 2021
        Requires: FFmpeg
        ffmpeg must be available in the current shell path.
    .LINK
        FFmpeg - https://ffmpeg.org
    .PARAMETER Destination
        Mandatory path to the Destination Directory, encapsulated in "quotes"
    .EXAMPLE
        > Convert-FLAC2MP3 -Destination "C:\temp\"
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
        Write-Verbose "Check for .flac files in the current directory..."
        if ( ! ( Get-ChildItem -Recurse "*.flac" ) ) {
            Write-Error "No .flac files found in current directory!"
            Break
        } else {
            Write-Verbose "Building a list of .flac files in the current directory..."
            $Files = $(Get-ChildItem -Include *.flac -Recurse).BaseName
            Write-Verbose "Creating Variables based on current path..."
            $CurrentDir = $(Split-Path -Path (Get-Location) -Parent)
            $Parent = $(Split-Path -Path $CurrentDir -Leaf)
            $Folder = $(Split-Path -Path (Get-Location) -Leaf)
        }
    }

    process {
        # Create $Destination\$Parent Directory if it does not exist
        if ( ! (Test-Path $Destination\$Parent -PathType 'Container') ) {
            Write-Verbose "Creating $Destination\$Parent Directory, as it did not exist!"
            New-Item -Path $Destination\$Parent -ItemType Directory | Out-Null
        }

        # Create $Destination\$Parent\$Folder Directory if it does not exist
        if ( ! (Test-Path $Destination\$Parent\$Folder -PathType 'Container') ) {
            Write-Verbose "Creating $Destination\$Parent\$Folder Directory, as it did not exist!"
            New-Item -Path $Destination\$Parent\$Folder -ItemType Directory | Out-Null
        }

        # Convert/Resize each .flac file
        foreach ($File in $Files) {
            Write-Verbose "Processing file $File!"
            try {
                ffmpeg.exe  -loglevel fatal `
                            -stats `
                            -i "$File.flac" `
                            -ab 320k `
                            -y `
                            "$Destination\$Parent\$Folder\$File.mp3"
            }
            catch {
                Write-Error "Unable to process file $File!"
                Break
            }
        }
    }

    end {
        # Cleanup used Variables
        Write-Verbose "Cleaning up used Variables..."
        Remove-Variable -Name "Destination" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Files" -ErrorAction SilentlyContinue
        Remove-Variable -Name "CurrentDir" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Parent" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Folder" -ErrorAction SilentlyContinue
        Remove-Variable -Name "File" -ErrorAction SilentlyContinue
    }
}