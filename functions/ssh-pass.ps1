function ssh-pass {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]
        $Username,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [System.Security.SecureString]
        $Password,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]
        $Server
    )
    if (! ( Get-Command "plink.exe" -ErrorAction SilentlyContinue )) {
        Write-Error "Plink not found in PATH!!!"
        Break
    }
    $Pass = ConvertFrom-SecureString-AsPlainText -SecureString $Password
    plink -batch -l $Username -pw "$Pass" $Server
    Remove-Variable -Name "Username" -ErrorAction SilentlyContinue
    Remove-Variable -Name "Password" -ErrorAction SilentlyContinue
    Remove-Variable -Name "Server" -ErrorAction SilentlyContinue
    Remove-Variable -Name "Pass" -ErrorAction SilentlyContinue
}