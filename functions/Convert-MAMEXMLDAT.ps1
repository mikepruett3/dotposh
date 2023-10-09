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
    .PARAMETER File
        Path to the .DAT file containing the dataset to import.
    .PARAMETER Region
        Region Name, used to Filter results. (i.e. USA, JAP, EU, etc..)
    .EXAMPLE
        > Convert-MAMEXMLDAT -File C:\mydata.dat -Region USA
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType 'Leaf'})]
        [string]
        $File,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $Region
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

        # Setting $SearchRegion text based on selected $Region
        switch ($Region) {
            USA {
                $SearchRegion = "(USA)"
                $FilterRegion = @(",Fr,",",De,",",Es,",",It,",",Nl,",",Sv,",",No,",",Da,",",Fi,",",Pt,")
            }
            EU {
                $SearchRegion = "(Europe)"
            }
            JAP {
                $SearchRegion = "(Japan)"
            }
            Default {
                $SearchRegion = "(USA)"
            }
        }
    }

    process {
        # Generate Output
        Write-Verbose "Converting MAME XML formatted .DAT file output to an object..."
        $Result = Select-Xml -Xml ${XML} -XPath ${XMLPath} |
                    Select-Object -ExpandProperty Node |
                    Where-Object { $_.category -eq "Games" } |
                    Where-Object { $_.Name -like "*${SearchRegion}*" } |
                    Where-Object { $_.Name -notlike "*(Rev*)*" } |
                    Where-Object { $_.Name -notmatch ( $FilterRegion -join "|" ) } |
                    Select-Object Name, `
                        @{name="Description"; expression={ $_.Description.Replace(" ${SearchRegion}","") }} |
                    Sort-Object -Property Name
        Return $Result
    }

    end {
        # Cleanup leftover variables
        Write-Verbose "Cleaning up unused variables..."
        Remove-Variable -Name "File" -ErrorAction SilentlyContinue
        Remove-Variable -Name "XML" -ErrorAction SilentlyContinue
        Remove-Variable -Name "XMLPath" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Region" -ErrorAction SilentlyContinue
        Remove-Variable -Name "SearchRegion" -ErrorAction SilentlyContinue
        Remove-Variable -Name "FilterRegion" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Result" -ErrorAction SilentlyContinue
    }
}