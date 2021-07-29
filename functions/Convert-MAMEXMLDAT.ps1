function Convert-MAMEXMLDAT {
    <#
    .SYNOPSIS
        Creates an object from an filtered MAME XML formatted .DAT file
    .DESCRIPTION
        Function imports XML data from a MAME .DAT file (ClrMame), and then
        returns a powershell formatted object of the filterd output
    .NOTES
        Tested against the .dat files from FBNeo project
            https://github.com/libretro/FBNeo/tree/master/dats
    .PARAMETER file
        Path to the .DAT file containing the dataset to import.
    .EXAMPLE
        > Convert-MAMEXMLDAT -file C:\mydata.dat
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType 'Leaf'})]
        [string]
        $file
    )
    
    begin {
        # Import the file as an XML object
        Write-Verbose "Importing file as an XML formatted object..."
        try { $XML = [xml](Get-Content ${file}) }
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
        $Result = Select-Xml -Xml ${XML} -XPath ${XMLPath} | Select-Object -ExpandProperty Node | Select-Object Name, Description
        Return $Result
    }
    
    end {
        # Cleanup leftover variables
        Write-Verbose "Cleaning up unused variables..."
        Remove-Variable file
        Remove-Variable XML
        Remove-Variable XMLPath
        Remove-Variable Result
    }
}