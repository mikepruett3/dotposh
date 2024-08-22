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
    .PARAMETER Credential
        Credentials used to connect to the remote server, will prompt for password of
        the associated account. Can be in either DOMAIN\Username or Username@domain.com
        format.
    .PARAMETER File
        Path to the .PFX certificate bundle file to import
    .PARAMETER Passphrase
        The Password or Passphrase used to encrypt the .PFX certificate bundle file

        **NOTE** The passphrase needs to include a escape character, if it contains a normally
        interpreted character. (i.e. " will need to be escaped, like "")
    .PARAMETER Delete
        If switch included, all matching old & expired certificates will be deleted
    .PARAMETER RDS
        If switch included, will import this PFX Certificate for the RDS Deployment Certificate
    .EXAMPLE
        > Import-PFX -Server myserver -Credential mycreds@example.com -File .\mycert.pfx -Passphrase mypass
    .NOTES
        Author: Mike Pruett
        Date: Feburary 3rd, 2022
        Updated: August 22st, 2024
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $Server,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $Credential,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
        [string]
        $File,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $Passphrase,
        [switch]
        $Delete,
        [switch]
        $RDS
    )

    begin {
        Write-Verbose "Ingesting Credentials of $Credential into variable"
        $Creds = Get-Credential("$Credential")

        # Test Server Connectivity
        #if (!(Test-Connection -Count 1 -ComputerName $Server -Quiet )) {
        #    Write-Error "Cannot ping $Server!!!"
        #    Break
        #}

        Write-Verbose "Collect Certificate Information from PFX file"
        $FileName = (Get-ChildItem -Path $File).Name
        $PFXData = $(Get-PfxData -FilePath $File -Password (ConvertTo-SecureString -String $Passphrase -Force -AsPlainText))
        $Subject = $PFXData.EndEntityCertificates.Subject
        $Thumbprint = $PFXData.EndEntityCertificates.Thumbprint

        Write-Verbose "Creating PSSession Variable"
        $Session = New-PSSession -ComputerName $Server -Credential $Creds

        Write-Verbose "Test if Import-PfxCertificate command exists"
        Invoke-Command -Session $Session -ScriptBlock {
            Get-Command -Name Import-PfxCertificate | Out-Null
        }
    }

    process {
        Write-Output "New $Subject Certificate thumbprint - $Thumbprint"

        Write-Verbose "Create new Certs directory on $Server"
        Invoke-Command -Session $Session -ScriptBlock {
            New-Item -Path "C:\" -Name "Certs" -ItemType "Directory" -ErrorAction SilentlyContinue | Out-Null
        }

        Write-Verbose "Copy file to C:\Certs\ on $Server"
        Copy-Item $File -Destination C:\Certs\$FileName -ToSession $Session

        Write-Verbose "Importing Certificate on $Server"
        Invoke-Command -Session $Session -ScriptBlock {
            Import-PfxCertificate -FilePath C:\Certs\$Using:FileName Cert:\LocalMachine\My -Password (ConvertTo-SecureString -String $Using:Passphrase -Force -AsPlainText) | Out-Null
        }

        if ($Delete) {
            Invoke-Command -Session $Session -ScriptBlock {
                foreach ( $ExistingCert in (Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -like "$Using:Subject*"}) ) {
                    if ($ExistingCert.Thumbprint -ne $Using:Thumbprint) {
                        #Write-Output ""
                        Write-Output "Deleting this Expired Certificate:"
                        Write-Output $ExistingCert.Subject
                        Write-Output $ExistingCert.Thumbprint
                        Write-Output ""
                        Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Thumbprint -eq $ExistingCert.Thumbprint} | Remove-Item -Force -Verbose
                    }
                }
            }
        }

        if ($RDS) {
            Invoke-Command -Session $Session -ScriptBlock {
                foreach ($Role in @('RDRedirector','RDGateway','RDPublishing','RDWebAccess')) {
                    Set-RDCertificate -Role $Role `
                    -ImportPath C:\Certs\$Using:FileName `
                    -Password (ConvertTo-SecureString -String $Using:Passphrase -Force -AsPlainText) `
                    -ConnectionBroker (Get-RDServer -Role "RDS-CONNECTION-BROKER").Server
                }
            }
        }
    }

    end {
        Write-Verbose "Removing PSSession Variable"
        Remove-PSSession -Session $Session

        Write-Verbose "Cleaning up used Variables"
        Remove-Variable -Name "Server" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Credentials" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Creds" -ErrorAction SilentlyContinue
        Remove-Variable -Name "File" -ErrorAction SilentlyContinue
        Remove-Variable -Name "FileName" -ErrorAction SilentlyContinue
        Remove-Variable -Name "PFXData" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Subject" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Thumbprint" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Passphrase" -ErrorAction SilentlyContinue
        Remove-Variable -Name "ExistingCert" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Delete" -ErrorAction SilentlyContinue
        Remove-Variable -Name "RDS" -ErrorAction SilentlyContinue
    }
}