function Import-PFX {
    <#
    .SYNOPSIS
        Import PFX formatted certificate bundle to the local Certificate store
        on a remote host
    .DESCRIPTION
        Function that copies over a PFX formatted certificate bundle to a remote host,
        then imports it into the local Certificate store
    .NOTES
        Remote host needs to be running at least Windows Server 2012, or have the 
        Import-PfxCertificate command avaliable
    .PARAMETER Server
        The remote server to establish a remote PSSession.
    .PARAMETER Credentials
        Credentials used to connect to the remote server, will prompt for password of
        the associated account. Can be in either DOMAIN\Username or Username@domain.com 
        format.
    .PARAMETER File
        Path to the .PFX certificate bundle file to import
    .PARAMETER Passphrase
        The Password or Passphrase used to encrypt the .PFX certificate bundle file

        **NOTE** The passphrase needs to include a escape character, if it contains a normally
        interpreted character. (i.e. " will need to be escaped, like "")
    .EXAMPLE
        > Import-PFX -Server myserver -Credentials mycreds@example.com -File .\mycert.pfx -Passphrase mypass
    .NOTES
        Author: Mike Pruett
        Date: Feburary 3rd, 2022
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $Server,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $Credentials,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
        [string]
        $File,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $Passphrase
    )
    
    begin {
        # Import Credentials into $Creds
        $Creds = Get-Credential("$Credentials")
        # Test Server Connectivity
        if (!(Test-Connection -Count 1 -ComputerName $Server -Quiet )) {
            Write-Error "Cannot ping $Server!!!"
            Break
        }
        # Create var for File
        $FileName = (Get-ChildItem -Path $File).Name
        # Create PSSession Variable - $Session
        $Session = New-PSSession -ComputerName $Server -Credential $Creds
        # Test if Import-PfxCertificate command exists
        Invoke-Command -Session $Session -ScriptBlock { Get-Command -Name Import-PfxCertificate | Out-Nul }
    }

    process {
        # Create new Certs directory on Remote Server
        Invoke-Command -Session $Session -ScriptBlock {
            New-Item -Path "C:\" -Name "Certs" -ItemType "Directory" -ErrorAction SilentlyContinue | Out-Null
        }
        # Copy file to C:\Certs\ on Remote Server
        Copy-Item $File -Destination C:\Certs\$FileName -ToSession $Session
        # Import Certificate on Remote Server
        Invoke-Command -Session $Session -ScriptBlock {
            Import-PfxCertificate -FilePath C:\Certs\$Using:FileName Cert:\LocalMachine\My -Password (ConvertTo-SecureString -String $Using:Passphrase -Force -AsPlainText) | Out-Null
        }
    }
    
    end {
        # Remove PSSession
        Remove-PSSession -Session $Session

        # Cleanup
        Write-Verbose "Cleaning up used Variables..."
        Clear-Variable -Name "Server" -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name "Credentials" -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name "Creds" -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name "File" -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name "FileName" -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name "Passphrase" -Scope Global -ErrorAction SilentlyContinue
    }
}