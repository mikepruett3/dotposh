function Convert-Media {
    <#
    .SYNOPSIS
        Mass convert media files to different formats
    .DESCRIPTION
        Function that will recursivley convert any matching media files to
        a different specified format.
    .NOTES
        File Name: Convert-Media.ps1
        Author: Mike Pruett
        Date: August 31th, 2022
        Requires: FFmpeg
        ffmpeg must be available in the current shell path.

        **NOTE** This consolidates the many functions (scripts) that I
        created for converting media types (Convert-FLAC2MP3,
        Convert-MP42OGG,etc..) to one reusable and managable function!
    .LINK
        FFmpeg - https://ffmpeg.org
    .PARAMETER Type
        File extension of the Destination media to convert
    .PARAMETER Destination
        Mandatory path to the Destination Directory (Target), encapsulated in "quotes"
    .EXAMPLE
        > Convert-Media -Type "mp3" -Destination "C:\temp\"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $Type,
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

        # Strip last "\" from $Destination, if included
        $Destination = $Destination.TrimEnd('\')

        # Create vars based on current path
        Write-Verbose "Creating Variables based on current path..."
        $CurrentDir = $(Split-Path -Path (Get-Location) -Parent)
        $Parent = $(Split-Path -Path $CurrentDir -Leaf)
        $Folder = $(Split-Path -Path (Get-Location) -Leaf)

        # Check for files matching the $SourceList in the current directory, if not break
        $SourceList = @('flac','m4a','mp3','mp4','ogg','wav')
        foreach ($Extension in $SourceList) {
            Write-Verbose "Check for .$Extension files in the current directory..."
            if ( Get-ChildItem -Recurse -Filter "*.$Extension" ) {
                Write-Verbose "Building a list of .$Extension files in the current directory..."
                $Files = $(Get-ChildItem -Recurse -Filter "*.$Extension").BaseName
                $Ext = $Extension
            } else {
                Write-Verbose "No .$Extension files found in current directory!"
            }
        }
        if ( $Files -eq $Null ) {
            Write-Error "Could not find any files matching any of the '$SourceList' file type(s0 listed in current directory!"
            Break
        }

        # Set FFMPEG Options, based on $Type variable
        switch ($Type) {
            'flac' { $Options = @("-c:a","flac","-c:v","copy") }
            'm4a' { $Options = @("-c:a","aac","-ar","44100","-b:a","320k","-c:v","copy") }
            'mp3' { $Options = @("-c:a","mp3","-abr","320k","-c:v","copy") }
            'mp4' { $Options = @("-c:a","aac","-c:v","mpeg4") }
            'oga' { $Options = @("-c:a","libvorbis","-c:v","copy") }
            'ogg' { $Options = @("-c:a","libvorbis","-c:v","copy") }
            'ogv' { $Options = @("-c:a","libvorbis","-c:v","libtheora") }
            Default {}
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

        # Convert each file to the specified destination format
        foreach ($File in $Files) {
            Write-Verbose "Converting file $File to format $Type!"
            try
            {
                ffmpeg.exe  -loglevel fatal `
                            -stats `
                            -i `
                            "$File.$Ext" `
                            $Options `
                            -y `
                            "$Destination\$Parent\$Folder\$File.$Type"
            }
            catch
            {
                Write-Error "Unable to process file $File!"
                Break
            }
        }
    }

    end {
        # Cleanup used Variables
        Write-Verbose "Cleaning up used Variables..."
        Remove-Variable -Name "Destination" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Type" -ErrorAction SilentlyContinue
        Remove-Variable -Name "CurrentDir" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Parent" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Folder" -ErrorAction SilentlyContinue
        Remove-Variable -Name "SourceList" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Extension" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Files" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Ext" -ErrorAction SilentlyContinue
        Remove-Variable -Name "File" -ErrorAction SilentlyContinue
    }
}