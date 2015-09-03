Function ExtractZip{
    <#
    .SYNOPSIS
    Synopsis
    .DESCRIPTION
    Description
    .PARAMETER <name>
    1st Parameter
    .PARAMETER <name>
    2nd Parameter
    .EXAMPLE
    Example of Parameter 1
    .\<ScriptName>.ps1 -<name>
    .EXAMPLE
    Example of Parameter 2
    .\<ScriptName>.ps1 -<name>
    #>

    param (
        [string]$filename,
        [string]$destination = (pwd | Select-Object -ExpandProperty Path)
    )

    # ----- Variables -------
    $ScriptName = $MyInvocation.MyCommand.Name
    # -----------------------

    # ----- Default Check for Parameters or the Required Parameteri -----
    if (($PSBoundParameters.Count -eq 0) -or !($filename)) {
        Get-Help $Scriptname
        break
    }

    Write-Host $destination

    # If ($destination -eq '') {
    #     $destination = $MyInvocation.MyCommand.Name
    #     Write-Host $destination
    # }

    If (!(Test-Path -Path $filename)) {
        Write-Host "File not found!!!"
        break
    }

    # $Shell = New-Object -com Shell.Application
    # $zip = $Shell.NameSpace($filename)

    # ForEach ($item in $zip.items()) {
    #     $Shell.NameSpace($destination).copyhere($item)
    # }
}
