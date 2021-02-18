function Resize-M2VFiles {
    <#
    .SYNOPSIS
        Mass convert/resize .m2v files to MPEG4
    .DESCRIPTION
        Function that will recursivley convert .m2v files to MPEG4, as
        well as resize them using a specified Resoluton.
    .NOTES
        File Name: Resize-M2Vfiles.ps1
        Author: Mike Pruett
        Date: Feburary 18th, 2021
        Requires: MediaInfo & FFmpeg
        Both ffmpeg and mediainfo must be available in the current shell path.
    .LINK
        MediaInfo - https://mediaarea.net/en/MediaInfo
        FFmpeg - https://ffmpeg.org
    .PARAMETER Resolution
        Optional resolution to resize the .m2v files
    .PARAMETER Destination
        Mandatory path to the Destination Directory, encapsulated in "quotes"
    .EXAMPLE
        > Resize-M2VFiles -Resolution 640x480 -Destination "C:\temp\"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [string]
        $Resolution = "320x240",
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string]
        $Destination
    )
    
    begin {
        # Check if mediainfo.exe is in the path, if not break
        Write-Verbose "Check if mediainfo.exe is in the path..."
        if ( ! (Get-Command "mediainfo.exe" -ErrorAction SilentlyContinue ) ) {
            Write-Error "mediainfo.exe not found in path!`nDownload from https://mediaarea.net/en/MediaInfo, and place in path!"
            Break
        }

        # Check if ffmpeg.exe is in the path, if not break
        Write-Verbose "Check if ffmpeg.exe is in the path..."
        if ( ! (Get-Command "ffmpeg.exe" -ErrorAction SilentlyContinue ) ) {
            Write-Error "ffmpeg.exe not found in path!`nDownload from https://ffmpeg.org, and place in path!"
            Break
        }

        # Check for .m2v files in the current directory, if not break
        Write-Verbose "Check for .m2v files in the current directory..."
        if ( ! ( Get-ChildItem -Recurse "*.m2v" ) ) {
            Write-Error "No .m2v files found in current directory!"
            Break
        } else {
            Write-Verbose "Building a list of .m2v files in the current directory..."
            $Files = $(Get-ChildItem -Include *.m2v -Recurse).Name
        }
    }
    
    process {
        # Convert/Resize each .m2v file
        foreach ($File in $Files) {
            Write-Verbose "Extracting the FrameRate using mediainfo.exe..."
            try { $FPS = $(mediainfo.exe --Output="Video;%FrameRate%" $File) }
            catch {
                Write-Error "Unable to get FrameRate of the file $File!"
                Break
            }
            Write-Verbose "Processing $File using the following $Resolution Resolution and $FPS Framerate!"
            try {
                ffmpeg.exe  -loglevel fatal `
                            -stats `
                            -i $File `
                            -codec:v mpeg2video `
                            -an `
                            -s $Resolution `
                            -r $FPS `
                            -b:v 3000k `
                            -maxrate 4000k `
                            -g 18 `
                            -bf 2 `
                            -y `
                            $Destination\$File
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
        Clear-Variable -Name "Resolution" -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name "Destination" -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name "Files" -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name "File" -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name "FPS" -Scope Global -ErrorAction SilentlyContinue
    }
}
