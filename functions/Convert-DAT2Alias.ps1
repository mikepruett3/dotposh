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
        > Convert-DAT2Alias -Path .\MAME.dat | Export-CSV MAME.txt
    #>

    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
        [string]
        $File
    )
    
    begin {
        # Ingest .dat file to $XML
        $XML = [xml](Get-Content $File)
    }
    
    process {
        # Generate Output
        Write-Verbose "Converting MAME XML formatted .DAT file output to an object..."
        $Result = $XML.datafile.game | Select @{ Name="ROM"; Expression = { $_.rom.name.Substring(0,$_.rom.name.Length-4) }}, name
        Return $Result
    }
    
    end {
        # Clear Used Variables
        Remove-Variable -Name "File"
        Remove-Variable -Name "XML"
        Remove-Variable -Name "Result"
    }
}