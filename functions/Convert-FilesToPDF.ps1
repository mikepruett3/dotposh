function Convert-FilesToPDF {
    <#
    .SYNOPSIS
        Mass-Convert a directory of files to .PDFs, using pdfbox
    .DESCRIPTION
        Function generates a list of files from a Source Directory, and then
        converts those files to .PDFs in a different Destination Directory.
    .LINK
        https://pdfbox.apache.org
    .PARAMETER Source
        Path to the Source Directory, encapsulated in "quotes"
    .PARAMETER Destination
        Path to the Destination Directory, encapsulated in "quotes"
    .EXAMPLE
        > Convert-FilesToPDF -Source "C:\DIR1\" -Destination "C:\DEST\"
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string]
        $Source,
        
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string]
        $Destination
    )
    
    begin {
        # Check for pdfbox in system path
        Write-Verbose "Checking for pdfbox in system path"
        if (!(Get-Command -Name "pdfbox.cmd" -ErrorAction SilentlyContinue)) {
            Write-Error "pdfbox.cmd either not installed, or not in system path!"
            Break
        }
    }
    
    process {
        # Copy all files from $Source to $Destination
        try {
            Write-Verbose "Copying files from $Source to $Destination"
            Copy-Item -Path "$Source\*" -Destination $Destination -Recurse
        }
        catch {
            Write-Error "Unable to copy files to $Destination!"
            Break
        }

        # Delete all files out of $Destination, leaving folder structure
        try {
            Write-Verbose "Deleting all files out of $Destination, just leaving folder structure"
            Get-ChildItem -Recurse -Path $Destination -File | Remove-Item -Force
        }
        catch {
            Write-Error "Unable to delete files out of $Destination!"
            Break
        }

        # Generate a list of files from $Source, including full path
        try {
            Write-Verbose "Generating a list of file from $Source, including full path"
            $SourceFiles = $(Get-ChildItem -Recurse -Path $Source).VersionInfo.FileName
        }
        catch {
            Write-Error "Unable to generate a list of files from $Source!"
            Break
        }

        # Create PDF from each file in $SourceFiles, using pdfbox
        foreach ($item in $SourceFiles) {
            $tmp = $item.Replace($Source, $Destination) + ".pdf"
            try {
                Write-Verbose "Creating PDF file of output from $item"
                pdfbox TextToPDF "$tmp" "$item"
            }
            catch {
                Write-Error "Unable to create PDF file of $item at $tmp!"
            }
        }
    }
    
    end {
        Write-Verbose "Cleaning up after Creating PDF files..."
        Clear-Variable -Name Source -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name Destination -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name item -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name tmp -Scope Global -ErrorAction SilentlyContinue
    }
}

