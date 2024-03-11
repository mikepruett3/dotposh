function Decrypt-File {
    <#
    .SYNOPSIS
        Decrypt dile using GPG
    .DESCRIPTION
        Function that will decrypt a file using gpg.exe from the path
    .NOTES
        File Name: Decrypt-File.ps1
        Author: Mike Pruett
        Date: March 11th, 2024
        Requires: GPG
        This function is expecting that gpg.exe is included in the $PATH
    .PARAMETER File
        Path to the file to Decrypt
    .EXAMPLE
        > Decrypt-File -File "C:\temp\encrypted.txt.gpg"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
        [string]
        $File

        #[Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        #[string]
        #$Passphrase
    )

    begin {
        # Check if openssl.exe is in the path, if not break
        Write-Verbose "Check if gpg.exe is in the path..."
        if ( ! (Get-Command "gpg.exe" -ErrorAction SilentlyContinue ) ) {
            Write-Error "gpg.exe not found in path!!"
            Break
        }

        # Collect Filename
        $FileName = (Get-ChildItem $File).BaseName
    }

    process {
        try { gpg --output $FileName --decrypt $File }
        catch {
            Write-Error "Unable to decrypt $File!"
            Break
        }

    }

    end {
        # Cleanup
        Write-Verbose "Cleaning up used Variables..."
        Remove-Variable -Name "File" -ErrorAction SilentlyContinue
        Remove-Variable -Name "FileName" -ErrorAction SilentlyContinue
        #Clear-Variable -Name "Passphrase" -ErrorAction SilentlyContinue
    }
}