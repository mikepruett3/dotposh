function Decrypt-OneFile {
    <#
    .SYNOPSIS
        Decrypt a PGP/GPG encrypted file
    .DESCRIPTION
        Function that will decrypt a PGP/GPG encrypted file
    .NOTES
        File Name: Decrypt-File.ps1
        Author: Mike Pruett
        Date: March 11th, 2024
        Requires: GPG
        This function is expecting that gpg.exe is included in the $PATH
    .PARAMETER Path
        Path to the PGP/GPG encrypted file to Decrypt
    .PARAMETER Recipient
        Recipient to which the files were encrypted for. This could be
        either an EMail address or Fingerprint
    .PARAMETER Passphrase
        The passphrase for the associate recipient. This passphrase
        should be in clear-text (in future, would like to improve this!)
    .EXAMPLE
        > Decrypt-File -Path ".\encrypted.txt.gpg" -Recipient me@example.com -Password mypassword
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
        [string]
        $Path,
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [string]
        $Recipient,
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [string]
        $Passphrase
    )

    begin {
        Write-Verbose "Check if gpg.exe is in the path..."
        if ( ! (Get-Command "gpg.exe" -ErrorAction SilentlyContinue ) ) {
            Write-Error "gpg.exe not found in path!`nDownload from hhttps://www.gnupg.org/download/, and place in path!"
            Break
        }
    }

    process {
        Write-Verbose "Decrypting $Path.'Name'"
        try {
            $Destination = $Path.'DirectoryName' + "\" + $Path.'BaseName'
            gpg.exe --batch `
                    --passphrase $Password `
                    --pinentry-mode loopback `
                    --yes `
                    --recipient $Recipient `
                    --output $Destination
                    --decrypt $Path.'FullName'
        }
        catch {
            Write-Error "Unable to decrypt $Path!"
            Break
        }
    }

    end {
        # Cleanup
        Write-Verbose "Cleaning up used Variables..."
        Remove-Variable -Name "Path" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Recipient" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Passphrase" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Destination" -ErrorAction SilentlyContinue
    }
}