function Sync-Minio {
    <#
    .SYNOPSIS
        Sync or Copy files to and from a Mini.io bucket
    .DESCRIPTION
        Using the minio-client, copy or sync files to/from the bucket
    .NOTES
        Requires the minio-client to be installed, and in the system path
    .LINK
        https://docs.minio.io/docs/minio-client-complete-guide
    .PARAMETER Target
        Path to a local folder to sync changes to/from
    .PARAMETER Alias
        Configured alias to a bucket (Minio, S3, Google Cloud, etc...)
        Configured using mc.exe alias
    .PARAMETER Copy
        Switch to use mc cp (or copy) to download files from bucket
        to the local folder. Faster than sync for inital local folder
        seeding
    .EXAMPLE
        Sync-Minio -Target C:\My-Path -Alias AWS -Copy
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string]
        $Target,
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [string]
        $Alias,
        [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [switch]
        $Copy
    )
    
    begin {
        # Check for mc.exe in system path
        Write-Verbose "Checking for minio-client (mc.exe) in system path"
        if (!(Get-Command -Name "mc.exe" -ErrorAction SilentlyContinue)) {
            Write-Error "minio-client either not installed, or not in system path!"
            Break
        }

        # Check for appropriate Bucket alias
        Write-Verbose "Checking if the alias $Alias is configured"
        if (!(mc.exe alias ls $Alias 2> $Null)) {
            Write-Error "Alias $Alias missing, or not configured!"
            Break
        }

        # Get a list of the folders in the bucket
        Write-Verbose "Gathering a list of folders in the $Alias bucket"
        $Bucket = $(mc.exe ls $Alias)
        $Folders = @()
        foreach ($Folder in $Bucket) {
            $Folder = $Folder -split "0B "
            $Folders += $Folder[1].SubString(0,($Folder[1].Length - 1))
        }
    }
    
    process {
        if ($Copy) {
            # Copying files from each folder in the bucket
            Write-Verbose "Copy files from each folder in the $Alias bucket to $Target"
            Clear-Variable -Name Folder -Scope Global -ErrorAction SilentlyContinue
            foreach ($Folder in $Folders) {
                Write-Verbose "Copying $Alias\$Folder to $Target"
                mc.exe cp --recursive $Alias\$Folder $Target
            }
        } else {
            # Syncing the Target folder from files in the bucket
            Write-Verbose "Syncing files from the $Alias bucket to $Target"
            mc.exe mirror $Alias $Target
            # Syncing the Bucket from files in the Target folder
            Write-Verbose "Syncing files from the $Target folder to $Alias bucket"
            mc.exe mirror $Target $Alias
        }
    }
    
    end {
        Write-Verbose "Cleaning up after Syncing files..."
        Clear-Variable -Name Target -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name Alias -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name Bucket -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name Folders -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name Folder -Scope Global -ErrorAction SilentlyContinue
    }
}