function Rename-Magazines {
    <#
    .SYNOPSIS
        Renames Magazine files to a 'Year - Month' format
    .DESCRIPTION
        Function that takes a path, and searches for matching
        Magazine files (.pdf, .cbz, .jpg), renames them to the specified
        format, and moves them to the parent path.
    .NOTES
        This is usefull for migrating Magazines, Comics and Manga from a
        Calibre library style to a single folder with all files

        Created this for use in migrating my Calibre libraries to something 
        that Komga could parse.
    .PARAMETER Path
        Mandatory path to find the associated magazine files
    .EXAMPLE
        Use the following to process folders and files in the current
        directory.

        $Folders = Get-ChildItem -Attributes Directory -Path .
        foreach ($Folder in $Folders) {
            Rename-Magazines -Target $Folder.FullName -Verbose
        }
    #> 
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string]
        $Path
    )

    begin {
        # Getting the Parent folder of the $Path
        $Parent = (Get-Item -Path $Path).Parent.FullName
        # Common extensions of Magazines, Comics and Manga
        $Extensions = @('pdf','cbz','jpg')
        $Files = @()
    }

    process {
        # Enumerate the specified path, looking for matching files
        Write-Verbose "Checking $Path"
        $Count = 0
        foreach ($ext in $Extensions) {
            if (Get-ChildItem -Recurse -Path $Path -Include *.$ext) {
                Clear-Variable -Name "File" -ErrorAction SilentlyContinue
                $File = Get-ChildItem -Recurse -Path $Path -Include *.$ext
                Write-Verbose "Found file - $($File.Name)..."
                $Files += $File
                $Count = $Count + 1
            }
        }

        if ($Count -eq 0) {
            Write-Error "Unable to find a file to process!!"
            Break
        }
    
        # Collect the 4 digit year from the first filename
        if ($Files[0] -match '[0-9][0-9][0-9][0-9]') {
            $Year = $Matches[0]
        }

        # Collect the Month (or Special) name from the first filename
        switch -regex ($Files[0]) {
            'Jan' { $Month = 'January' }
            'Feb' { $Month = 'Feburary' }
            'Mar' { $Month = 'March' }
            'Apr' { $Month = 'April' }
            'May' { $Month = 'May' }
            'Jun' { $Month = 'June' }
            'Jul' { $Month = 'July' }
            'Aug' { $Month = 'August' }
            'Sep' { $Month = 'September' }
            'Oct' { $Month = 'October' }
            'Nov' { $Month = 'November' }
            'Dec' { $Month = 'December' }
            'Holiday' { $Month = 'Holiday' }
            'Spring' { $Month = 'Spring' }
            'Summer' { $Month = 'Summer' }
            'Winter' { $Month = 'Winter' }
            'Autumn' { $Month = 'Autumn' }
        }

        Clear-Variable -Name "File" -ErrorAction SilentlyContinue
        foreach ($File in $Files) {
            Clear-Variable -Name "New" -ErrorAction SilentlyContinue
            Write-Verbose "Processing File - $($File.Name)..."
            $New = $File.Directory.FullName + "\" + $Year + " - " + $Month + $File.Extension
            Write-Verbose "Renamed File - $($File.Name) to $New..."
            Rename-Item -Path $File.FullName -NewName $New
            Write-Verbose "Moving file - $New to $Parent... `r`n"
            Move-Item -Path $New $Parent
        }
    }
    
    end {
        # Cleanup
        Write-Verbose "Cleaning up used Variables..."
        Clear-Variable -Name "Path" -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name "Parent" -ErrorAction SilentlyContinue
        Clear-Variable -Name "Extensions" -ErrorAction SilentlyContinue
        Clear-Variable -Name "Files" -ErrorAction SilentlyContinue
        Clear-Variable -Name "File" -ErrorAction SilentlyContinue
        Clear-Variable -Name "Count" -ErrorAction SilentlyContinue
        Clear-Variable -Name "ext" -ErrorAction SilentlyContinue
        Clear-Variable -Name "Year" -ErrorAction SilentlyContinue
        Clear-Variable -Name "Month" -ErrorAction SilentlyContinue
        Clear-Variable -Name "New" -ErrorAction SilentlyContinue
    }
}
