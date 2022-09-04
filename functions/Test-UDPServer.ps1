function Test-UDPServer {
    <#
    .SYNOPSIS
        Send UDP Datagram test data to a UDP Socket Listener Server
    .DESCRIPTION
        Function that creates a UDP Datagram packet to send to a
        UDP Socket Listener Server.

        Useful for testing UDP communications between hosts.
    .NOTES
        File Name: Test-UDPServer.ps1
        Author: Mike Pruett
        Date: September 4th, 2022

        Code Borrowed from Cloudbrothers Post
        https://cloudbrothers.info/en/test-udp-connection-powershell/
    .PARAMETER Port
        Specified UDP Port to send the Datagram packet to.
    .PARAMETER ComputerName
        Specified Hostname or IP to send the UDP Datagram packet to.
    .PARAMETER SourcePort
        Specified UDP Port to send the Datagram packet from.
    .EXAMPLE
        > Test-UDPServer -Port 50001 -ComputerName 127.0.0.1 -SourcePort 50000
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int32]$Port,

        [Parameter(Mandatory = $true)]
        [string]$ComputerName,

        [Parameter(Mandatory = $false)]
        [int32]$SourcePort = 50000
    )

    begin {
        # Create a UDP client object
        $UDPObject = New-Object System.Net.Sockets.UdpClient($SourcePort)
        # Define connect parameters
        $UDPObject.Connect($ComputerName, $Port)
    }

    process {
        # Convert current time string to byte array
        $ASCIIEncoding = New-Object System.Text.ASCIIEncoding
        $Bytes = $ASCIIEncoding.GetBytes("$(Get-Date -UFormat "%Y-%m-%d %T")")
        # Send data to server
        [void]$UDPObject.Send($Bytes, $Bytes.length)
    }

    end {
        # Cleanup
        Write-Verbose "Closing UDP Client Session..."
        $UDPObject.Close()
        Write-Verbose "Cleaning up used Variables..."
        Remove-Variable -Name "Port" -ErrorAction SilentlyContinue
        Remove-Variable -Name "ComputerName" -ErrorAction SilentlyContinue
        Remove-Variable -Name "SourcePort" -ErrorAction SilentlyContinue
        Remove-Variable -Name "UDPObject" -ErrorAction SilentlyContinue
        Remove-Variable -Name "ASCIIEncoding" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Bytes" -ErrorAction SilentlyContinue
    }
}
