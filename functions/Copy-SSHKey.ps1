function Copy-SSHKey {
    <#
    .SYNOPSIS
        Copy the SSH Public Key to a server
    .DESCRIPTION
        Like the Unix equavilent, ssh-copy-id... this cmdlet will open
        an SSH session to the server, and copy the contents of the SSH
        Public Key to the .ssh/authorized_keys on the remote server.
    .PARAMETER Server
        Server name to copy the SSH Public Key
    .PARAMETER Credentials
        Credentials (Username and Password) used to connect to the
        remote server. Use BetterCredentials to make this process
        easier
    .PARAMETER Key
        Path to the SSH Public Key to copy to the server. Cmdlet will
        use the Default Public Key $Env:UserProfile\.ssh\id_rsa.pub, 
        if avaliable
    .EXAMPLE
        > Copy-SSHKey -Server myserver.example.com -Credentials myuser -Key \Path\To\Key\File.pub
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True,ValueFromPipeline=$true)]
        [string]
        $Server,

        [Parameter(Mandatory=$True,ValueFromPipeline=$true)]
        [string]
        $Credentials,

        [Parameter(Mandatory=$False,ValueFromPipeline=$true)]
        [string]
        $Key
    )
    
    begin {
        # Load contents of SSH Public Key into variable
        Write-Verbose "Load contents of SSH Public Key into variable..."
        if ($Key -eq "") {
            if (Test-Path -Path $Env:UserProfile\.ssh\id_rsa.pub) {
                # Use the default location of the Public Key, if avaliable
                $Key = "$Env:UserProfile\.ssh\id_rsa.pub"
            } else {
                Write-Error "Key not found!!!"
                Break
            }
        } else {
            Write-Error "Key not found!!!"
            Break
        }
        if (Test-Path -Path $Key) {
            $SSHKey = Get-Content -Path "$Key"
        }
        
        # Get Credentials into variable (User BetterCredentials to make this easier!)
        Write-Verbose "Load Credentials into variable..."
        try { $Creds = Get-Credential("$Credentials") }
        catch {
            Write-Error "Could not retrieve the Credentials!!!"
            Break
        }
        $UserName = $Creds.GetNetworkCredential().UserName
        $Password = $Creds.GetNetworkCredential().Password

        # Ping the server
        Write-Verbose "Testing communication with the $Server server..."
        try { Test-Connection -ComputerName $Server -Count 1 -ErrorAction Stop > $null }
        catch {
            Write-Error "Count not communicate with $Server!!!"
            Break
        }

        # Check for plink in system path
        Write-Verbose "Checking for plink in system path"
        if (!(Get-Command -Name "plink.exe" -ErrorAction SilentlyContinue)) {
            Write-Error "plink.exe either not installed, or not in system path!!!"
            Break
        }
    }
    
    process {
        try {
            Write-Output "$SSHKey" | plink.exe "$Server" -l "$UserName" -pw "$Password" "umask 077; test -d .ssh || mkdir .ssh ; cat >> .ssh/authorized_keys"
        }
        catch {
            Write-Error "Unable to copy the Public Key to the server!!!"
            Break
        }
        
    }
    
    end {
        Write-Verbose "Cleaning up after Copying the SSH Public Key to the server $Server..."
        Clear-Variable -Name Server -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name Credentials -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name Key -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name SSHKey -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name Creds -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name UserName -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name Password -Scope Global -ErrorAction SilentlyContinue
    }
}