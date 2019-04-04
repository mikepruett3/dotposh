function Get-IPAddress {
    <#
    .SYNOPSIS
    Enumerates either the Public or Private IP address of the current machine
    .DESCRIPTION
    This script can be used to enumerate the current workstaions public or private IP address of the current workstation.
    .PARAMETER public
    To return the Public (External) IP Address of the current workstation
    .PARAMETER private
    To return the Private (Internal) IP Address of the current workstaion
    .EXAMPLE
    Enumerate the Public IP Address

    .\Get-IPAddress -public
    .EXAMPLE 
    Enumerate the Private IP Address

    .\Get-IPAddress -private
    #>

    [CmdletBinding()]
    Param(
        [switch]$Public,
        [switch]$Private,
        [switch]$Interactive
    )

    begin {
        $WShell = New-Object -ComObject Wscript.Shell -ErrorAction Stop
        $paramHash = @{
            uri = 'http://icanhazip.com/'
            DisableKeepAlive = $True
            UseBasicParsing = $True
            ErrorAction = 'Stop'
        }
    }

    process {
        if ($Public) {
            # Function from The Lonley Administrator Blog
            # http://jdhitsolutions.com/blog/friday-fun/4342/friday-fun-whats-my-ip/
            Try { $IPAddress = $(Invoke-WebRequest @paramHash).Content.Trim() }
            Catch { Throw $_ }
            if ($Interactive) {
                $WShell.Popup("$IPAddress",5,"External IP address...",0x0 + 0x40)   
            } else {
                $IPAddress   
            }
        }

        if ($Private) {
            $IPAddress = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName . | `
                        Where-Object { $_.IPEnabled } | `
                        Where-Object { $_.DHCPEnabled -eq $True } | `
                        Select-Object -ExpandProperty IPAddress | `
                        Select-Object -First 1
            if ($Interactive) {
                $WShell.Popup("$IPAddress",5,"Internal IP address...",0x0 + 0x40)
            } else {
                $IPAddress   
            }
        }
    }

    end {
        $WShell = $Null
        $IPAddress = $Null
        $Private = $Null
        $Public = $Null
        $paramHash = $Null
    }
}