function Connect-NSX {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True,ValueFromPipeline=$true)]
        [string]
        $Server,
        [Parameter(Mandatory=$True,ValueFromPipeline=$true)]
        [string]
        $Credential
    )
    #Slurp Credentials into variable
    $Creds = Get-Credential("$Credential")
    #Ping $Server to see if avaliable
    if (!(Test-Connection -Count 1 -ComputerName $Server -Quiet )) {
        Write-Error "Cannot ping $Server!!!"
        Break
    }
    #Connect to NSX Server
    Connect-NsxServer -vCenterServer $Server -Credential $Creds
}