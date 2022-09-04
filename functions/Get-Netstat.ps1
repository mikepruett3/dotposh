function Get-Netstat {
    <#
    .SYNOPSIS
        Collect information about Network Connections
    .DESCRIPTION
        Function that emulates the MS-DOS netstat tool, and returns a PSCustomObect
        that includes resultes in a specified format.
    .NOTES
        File Name: Get-Netstat.ps1
        Author: Mike Pruett
        Date: September 4th, 2022
    .PARAMETER Listen
        Returns all Network Connections with the state of 'Listening'
    .PARAMETER Process
        Returns all Network Connections that match the 'Process' name
    .PARAMETER ID
        Returns all Network Connections that match the Process 'ID'
    .PARAMETER LocalPort
        Returns all Network Connections that match the Local Port number
    .PARAMETER RemotePort
        Returns all Network Connections that match the Remote Port number
    .PARAMETER Process
        Returns all Network Connections that match the 'Process' name
    .EXAMPLE
        > Get-Netstat -Listen
            or
        > Get-Netstat -Process svchost
            or
        > Get-Netstat -RemotePort 443
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [switch]
        $Listen,
        [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [string]
        $Process,
        [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [string]
        $ID,
        [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [string]
        $LocalPort,
        [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [string]
        $RemotePort
    )

    begin {
        $Results = @()
    }

    process {
        #If no Parameters are set, then Collect all of the Network TCP Connections
        if ($PSBoundParameters.Count -eq 0) {
            $TCPConnections = Get-NetTCPConnection -ErrorAction SilentlyContinue
            $UDPConnections = Get-NetUDPEndpoint -ErrorAction SilentlyContinue

            $Sort = "LocalAddress"
        }

        #If $Listen is True, then Collect all of the Network TCP Connections into a Variable based on the State = Listen
        if ($Listen) {
            Write-Verbose "Building an array with TCP Connections, matching State of Listening"
            $TCPConnections = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue

            #Write-Verbose "Building an array with UDP Connections, matching State of Listening"
            #$UDPConnections = Get-NetUDPEndpoint -ErrorAction SilentlyContinue #| `
            #Where-Object { $_.LocalAddress -match '0.0.0.0|127.0.0.1'}

            $Sort = "LocalAddress"
        }

        #If $Process is True, then Collect all of the Network TCP Connections into a Variable that match the ProcessName
        if ($Process) {
            Write-Verbose "Building an array with TCP Connections, maching Process Name - $Process"
            $TCPConnections = Get-NetTCPConnection `
            -OwningProcess (Get-Process -Name $Process -ErrorAction SilentlyContinue).Id -ErrorAction SilentlyContinue

            Write-Verbose "Building an array with UDP Connections, maching Process Name - $Process"
            $UDPConnections = Get-NetUDPEndpoint `
            -OwningProcess (Get-Process -Name $Process -ErrorAction SilentlyContinue).Id -ErrorAction SilentlyContinue

            $Sort = "LocalAddress"
        }

        #If $ID is True, then Collect all of the Network TCP Connections into a Variable that match the Process
        if ($ID) {
            Write-Verbose "Building an array with TCP Connections, maching Process ID - $ID"
            $TCPConnections = Get-NetTCPConnection -OwningProcess $ID -ErrorAction SilentlyContinue

            Write-Verbose "Building an array with UDP Connections, maching Process ID - $ID"
            $UDPConnections = Get-NetUDPEndpoint -OwningProcess $ID -ErrorAction SilentlyContinue

            $Sort = "LocalAddress"
        }

        #If $LocalPort is True, then Collect all of the Network TCP Connections into a Variable that match the LocalPort
        if ($LocalPort) {
            Write-Verbose "Building an array with TCP Connections, maching Local Port - $LocalPort"
            $TCPConnections = Get-NetTCPConnection -LocalPort $LocalPort -ErrorAction SilentlyContinue

            Write-Verbose "Building an array with UDP Connections, maching Local Port - $LocalPort"
            $UDPConnections = Get-NetUDPEndpoint -LocalPort $LocalPort -ErrorAction SilentlyContinue

            $Sort = "ProcessName"
        }

        #If $RemotePort is True, then Collect all of the Network TCP Connections into a Variable that match the RemotePort
        if ($RemotePort) {
            Write-Verbose "Building an array with TCP Connections, maching Remote Port - $RemotePort"
            $TCPConnections = Get-NetTCPConnection -RemotePort $RemotePort -ErrorAction SilentlyContinue

            $Sort = "ProcessName"
        }

        # Build new PSCustomObject, using the results of $TCPConnections
        Write-Verbose "Building a new PSCustomObject of all the matching TCP Connection items..."
        foreach ($Connection in $TCPConnections) {
            $Temp = [PSCustomObject]@{
                LocalAddress = $Connection.LocalAddress
                LocalPort = $Connection.LocalPort
                RemotePort = $Connection.RemotePort
                Protocol = "TCP"
                State = $Connection.State
                ID = $Connection.OwningProcess
                ProcessName = (Get-Process -Id $Connection.OwningProcess -ErrorAction SilentlyContinue).ProcessName
                CreationTime = $Connection.CreationTime
                OffloadState = $Connection.OffloadState
            }

            if (Resolve-DNSName -Name $Connection.RemoteAddress -DnsOnly -ErrorAction SilentlyContinue) {
                $Temp |  Add-Member -MemberType NoteProperty -Name 'RemoteAddress' -Value (Resolve-DNSName -Name $Connection.RemoteAddress -DnsOnly).NameHost
            } else {
                $Temp |  Add-Member -MemberType NoteProperty -Name 'RemoteAddress' -Value $Connection.RemoteAddress
            }

            $Results += $Temp
        }

        # Build new PSCustomObject, using the results of $UDPConnections
        Write-Verbose "Building a new PSCustomObject of all the matching UDP Connection items..."
        foreach ($Connection in $UDPConnections) {
            $Temp = [PSCustomObject]@{
                LocalAddress = $Connection.LocalAddress
                LocalPort = $Connection.LocalPort
                RemoteAddress = $Connection.RemoteAddress
                RemotePort = $Connection.RemotePort
                Protocol = "UDP"
                State = $Connection.State
                ID = $Connection.OwningProcess
                ProcessName = (Get-Process -Id $Connection.OwningProcess -ErrorAction SilentlyContinue).ProcessName
                CreationTime = $Connection.CreationTime
                OffloadState = $Connection.OffloadState
            }
            $Results += $Temp
        }

        # Return $Results variable
        Write-Verbose "Returing the Results..."
        Return $Results | `
        Select-Object Protocol,LocalAddress,LocalPort,RemoteAddress,RemotePort,ProcessName,ID | `
        Sort-Object -Property @{Expression = "Protocol"}, `
        @{Expression = $Sort} | `
        Format-Table -AutoSize -Wrap
    }

    end {
        # Cleanup used Variables
        Write-Verbose "Cleaning up used Variables..."
        Remove-Variable -Name "Listen" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Process" -ErrorAction SilentlyContinue
        Remove-Variable -Name "ID" -ErrorAction SilentlyContinue
        Remove-Variable -Name "LocalPort" -ErrorAction SilentlyContinue
        Remove-Variable -Name "RemotePort" -ErrorAction SilentlyContinue
        Remove-Variable -Name "TCPConnections" -ErrorAction SilentlyContinue
        Remove-Variable -Name "UDPConnections" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Connection" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Sort" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Temp" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Results" -ErrorAction SilentlyContinue
    }
}