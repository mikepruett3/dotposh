function Start-UDPServer {
    <#
    .SYNOPSIS
        Start a UDP Listener Server
    .DESCRIPTION
        Function that creates a UDP Socket Listener Server, that echos any
        UDP datagram recieved.

        Useful for testing UDP communications between hosts.
    .NOTES
        File Name: Start-UDPServer.ps1
        Author: Mike Pruett
        Date: September 4th, 2022

        Code Borrowed from Cloudbrothers Post
        https://cloudbrothers.info/en/test-udp-connection-powershell/
    .PARAMETER Port
        Specified UDP Port to start the Socket Listener Server
    .EXAMPLE
        > Start-UDPServer -Port 50001
    #>
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory = $false)]
        $Port = 10000
    )

    begin {
        # Create a endpoint that represents the remote host from which the data was sent.
        $RemoteComputer = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, 0)
    }

    process {
        Write-Host "Server is waiting for connections - $($UdpObject.Client.LocalEndPoint)"
        Write-Host "Stop with CRTL + C"

        # Loop de Loop
        do {
            # Create a UDP listender on Port $Port
            $UDPObject = New-Object System.Net.Sockets.UdpClient($Port)
            # Return the UDP datagram that was sent by the remote host
            $ReceiveBytes = $UDPObject.Receive([ref]$RemoteComputer)
            # Close UDP connection
            $UDPObject.Close()
            # Convert received UDP datagram from Bytes to String
            $ASCIIEncoding = New-Object System.Text.ASCIIEncoding
            [string]$ReturnString = $ASCIIEncoding.GetString($ReceiveBytes)

            # Output information
            [PSCustomObject]@{
                LocalDateTime = $(Get-Date -UFormat "%Y-%m-%d %T")
                SourceIP      = $RemoteComputer.address.ToString()
                SourcePort    = $RemoteComputer.Port.ToString()
                Payload       = $ReturnString
            }
        } while (1)
    }

    end {
        Write-Verbose "Cleaning up used Variables..."
        Remove-Variable -Name "Port" -ErrorAction SilentlyContinue
        Remove-Variable -Name "RemoteComputer" -ErrorAction SilentlyContinue
        Remove-Variable -Name "UDPObject" -ErrorAction SilentlyContinue
        Remove-Variable -Name "ReceiveBytes" -ErrorAction SilentlyContinue
        Remove-Variable -Name "ASCIIEncoding" -ErrorAction SilentlyContinue
        Remove-Variable -Name "ReturnString" -ErrorAction SilentlyContinue
    }
}
