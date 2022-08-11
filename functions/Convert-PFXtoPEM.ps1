function Convert-PFXtoPEM {
    <#
    .SYNOPSIS
        Convert/Extract a PFX formatted certificate bundle to PEM formatted.
    .DESCRIPTION
        Function that will extract the appropriate PEM certificates from a PFX bundle.
    .NOTES
        File Name: Convert-PFXtoPEM.ps1
        Author: Mike Pruett
        Date: August 24th, 2021
        Requires: OpenSSL
        openssl must be available in the current shell path.
    .LINK
        FFmpeg - https://www.openssl.org
    .PARAMETER Path
        PFX formatted file to convert/extract, encapsulated in "quotes"
    .PARAMETER Passphrase
        Password for the PFX formatted file to convert/extract, encapsulated in "quotes"
    .EXAMPLE
        > Convert-PFXtoPEM -Path "C:\temp\mycerts.pfx" -Passphrase "MyPassword"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
        [string]
        $Path,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $Passphrase
    )

    begin {
        # Check if openssl.exe is in the path, if not break
        Write-Verbose "Check if openssl.exe is in the path..."
        if ( ! (Get-Command "openssl.exe" -ErrorAction SilentlyContinue ) ) {
            Write-Error "openssl.exe not found in path!`nDownload from https://wiki.openssl.org/index.php/Binaries, and place in path!"
            Break
        }

        # Collect Filename
        $FileName = (Get-ChildItem $Path).BaseName
    }

    process {
        # Convert/Extract the PFX file
        # Added "-legacy" option to support newer OpenSSL Versions - https://stackoverflow.com/questions/72598983/curl-openssl-error-error0308010cdigital-envelope-routinesunsupported
        Write-Verbose "Extracting Private Key from $Path, and writing to $Path.key"
        try { openssl pkcs12 -in "$Path" -legacy -nocerts -nodes -passin pass:"$Passphrase" | openssl pkcs8 -nocrypt -out "$FileName.key" }
        catch {
            Write-Error "Unable to extract Private key from file $Path!"
            Break
        }
        Write-Verbose "Extracting Certificate from $Path, and writing to $Path.crt"
        try { openssl pkcs12 -in "$Path" -legacy -clcerts -nokeys -passin pass:"$Passphrase" | openssl x509 -out "$FileName.crt" }
        catch {
            Write-Error "Unable to extract Certificate from file $Path!"
            Break
        }
        Write-Verbose "Extracting CA Certificates from $Path, and writing to $Path.chain.cer"
        try { openssl pkcs12 -in "$Path" -legacy -cacerts -nokeys -chain -passin pass:"$Passphrase" -out "$FileName.chain.cer" }
        catch {
            Write-Error "Unable to extract CA Certificates from file $Path!"
            Break
        }
    }

    end {
        # Cleanup
        Write-Verbose "Cleaning up used Variables..."
        Remove-Variable -Name "Path" -ErrorAction SilentlyContinue
        Remove-Variable -Name "FileName" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Passphrase" -ErrorAction SilentlyContinue
    }
}