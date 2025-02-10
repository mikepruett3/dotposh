function Decrypt-Files {
    <#
    .SYNOPSIS
        Decrypt PGP/GPG encrypted files in a directory
    .DESCRIPTION
        Custom Function to scan a directory for PGP/GPG encrypted files
        and decrypt all.
    .NOTES
        File Name: Decrypt-File.ps1
        Author: Mike Pruett
        Date: February 10th, 2025
        Requires: GPG
        This function is expecting that gpg.exe is included in the $PATH
    .PARAMETER Path
        Directory to find PGP/GPG encrypted files. If not included
        function will just use the current working directory
    .PARAMETER Recipient
        Recipient to which the files were encrypted for. This could be
        either an EMail address or Fingerprint
    .PARAMETER Passphrase
        The passphrase for the associate recipient. This passphrase
        should be in clear-text (in future, would like to improve this!)
    .EXAMPLE
        > Decrypt-Files -Recipient me@example.com -Password mypassword
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
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

        Write-Verbose "Collecting the current path, if none is specified"
        if ($Path -eq $Null) {
            $Path = (Get-Item -Path .).FullName
        }

        Write-Verbose "Check if any matching files are found"
        $Extensions = @('*.gpg','*.pgp')
        foreach ($Extension in $Extensions) {
            $Target = "$Path\$Extension"
            if (Test-Path -Path $Target) {
                $Files += Get-ChildItem -Path $Path -Filter $Extension
            }
        }

        Write-Verbose "Error if no files are found"
        if (!($Files)) {
            Write-Error "No files found!!!"
            Break
        }
    }

    process {
        Write-Verbose "Processing files in $Path..."
        foreach ($File in $Files) {
            Write-Verbose "Decrypting $File.'Name'"
            $Destination = $File.'DirectoryName' + "\" + $File.'BaseName'
            gpg.exe --batch `
                    --passphrase $Passphrase `
                    --pinentry-mode loopback `
                    --yes `
                    --recipient $Recipient `
                    --decrypt $File.'FullName' |
            Out-File -FilePath "$Destination" -Encoding ASCII
        }
    }

    end {
        # Cleanup used Variables
        Write-Verbose "Cleaning up used Variables..."
        Remove-Variable -Name "Path" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Recipient" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Passphrase" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Extensions" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Extension" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Target" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Files" -ErrorAction SilentlyContinue
        Remove-Variable -Name "File" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Destination" -ErrorAction SilentlyContinue
    }
}

