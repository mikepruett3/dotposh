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
    .EXAMPLE
        > Convert-PFXtoPEM -Path "C:\temp\mycerts.pfx"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
        [string]
        $Path
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
        # Collect PFX file password
        $PFXPass = Read-Host "Enter PFX File Password" -AsSecureString
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($PFXPass)
        Set-Item -Path Env:PFXPass -Value ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR))

        # Convert/Extract the PFX file
        Write-Verbose "Extracting Private Key from $Path, and writing to $Path.key"
        Write-Output $Env:PFXPass
        try { openssl pkcs12 -in "$Path" -nocerts -nodes -passin pass:"$Env:PFXPass" | openssl pkcs8 -nocrypt -out "$FileName.key" }
        catch {
            Write-Error "Unable to extract Private key from file $Path!"
            Break
        }
        #Write-Verbose "Extracting Certificate from $Path, and writing to $Path.crt"
        #try { openssl pkcs12 -in "$Path" -clcerts -nokeys -passin $Env:PFXPass | openssl x509 -out "$FileName.crt" }
        #catch {
        #    Write-Error "Unable to extract Certificate from file $Path!"
        #    Break
        #}
        #Write-Verbose "Extracting CA Certificates from $Path, and writing to $Path.chain.cer"
        #try { openssl pkcs12 -in "$Path" -cacerts -nokeys -chain -passin $Env:PFXPass -out "$FileName.chain.cer" }
        #catch {
        #    Write-Error "Unable to extract CA Certificates from file $Path!"
        #    Break
        #}
    }

    end {
        # Cleanup
        Write-Verbose "Cleaning up used Variables..."
        Clear-Variable -Name "Path" -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name "FileName" -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name "PFXPass" -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name "BSTR" -Scope Global -ErrorAction SilentlyContinue
        Remove-Item -Path Env:PFXPass
    }
}