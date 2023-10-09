function Convert-DAT2Alias {
    <#
    .SYNOPSIS
        Create a SimpleMenu Alias text file from CLRMAMEPRO formatted .DAT files
    .DESCRIPTION
        Function imports .DAT file as type XML, and then selects two fields to
        generate a SimpleMenu Alias text file.
    .NOTES
        Use this in conjunction with Skraper to tidy up your SimpleMenu display
        on your Retro Handheld
    .PARAMETER Path
        Path to the .DAT file to ingest
    .EXAMPLE
        Convert .DAT file, and export as CSV
        > Convert-DAT2Alias -Path .\MAME.dat | Export-CSV -NoTypeInformation -NoClobber MAME.txt
    #>

    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
        [string]
        $File
    )

    begin {
        # Import the file as an XML object
        Write-Verbose "Importing file as an XML formatted object..."
        try { $XML = [xml](Get-Content ${File}) }
        catch {
            Write-Error "Unable to import file as XML object!!"
        }

        # Creating variables
        Write-Verbose "Creating variables..."
        $XMLPath = "/datafile/game"
    }

    process {
        # Generate Output
        Write-Verbose "Converting MAME XML formatted .DAT file output to an object..."
        $Result = $XML.datafile.game |
                    Where-Object { $_.category -eq "Games" }
        #$Result = Select-Xml -Xml ${XML} -XPath ${XMLPath} |
        #            Select-Object @{ Name="ROM"; Expression = { $_.rom.name.Substring(0,$_.rom.name.Length-4) }}, Name
        Return $Result
    }

    end {
        # Clear Used Variables
        Remove-Variable -Name "File" -ErrorAction SilentlyContinue
        Remove-Variable -Name "XML" -ErrorAction SilentlyContinue
        Remove-Variable -Name "XMLPath" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Result" -ErrorAction SilentlyContinue
    }
}