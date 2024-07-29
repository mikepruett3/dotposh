function Get-VirtualServerList {
    <#
    .SYNOPSIS
        Report of all Virtual Services (VIP's) from a specifed NSX Edge
    .DESCRIPTION
        Function that returns a custom PS Object with all Virtual Services from
        a specified NSX Edge. This includes Pools, Health/Service monitors (if defined)
    .NOTES
        Used to export existing Load Balanacer Virtual Services out of NSX-V,
        for import/re-creation into NSX AVI Advanced Load Balancer.

        * Makes use of the Power-NSX cmdlets from the PowerShellGallery
         - https://www.powershellgallery.com/packages/PowerNSX -
    .PARAMETER Export (Optional)
        Export Results to a CSV File
    .PARAMETER Path (Optional)
        Fully-Quallified Path to the file to export results
    .EXAMPLE
        > Get-VirtualServerList

        or

        > Get-VirtualServerList -Export -Path C:\test.csv
    .NOTES
        Author: Mike Pruett
        Date: January 11th, 2022
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [switch]
        $Export,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [string]
        $Path
    )

    begin {
        # Check in PowerNSX Module is loaded
        If (!(Get-Module -Name PowerNSX)) {
            Write-Error "PowerNSX Module not loaded!!!"
            Break
        }

        # Check if the variable $defaultNSXConnection exists
        if (!($defaultNSXConnection)) {
            Write-Error "Not connected to a(n) NSX Instance!!!"
        }

        # Check if the switch $Export is selected, and if a $Path is included
        if ($Export) {
            if (!($Path)) {
                Write-Error "Path not specified for Export!!!"
                Break
            }
        }

        # Check if the variable $NSXEdge exists
        if (!($NSXEdge)) {
            Select-NSXEdge
            #$Edges = Get-NSXEdge | Select-Object id, name | Out-String
            #Write-Output $Edges
            #$NSXEdge = Read-Host "No NSX Edge selected, please select one from the list"
        }

        # Create empty Results array
        $Results = @()

        # Collect an array list of Virtual Servers from specified NSX Edge, and store in $VIPs variable
        $VIPs = Get-NSXEdge -objectId $NSXEdge | Get-NsxLoadBalancer | Get-NsxLoadBalancerVip
    }
    
    process {
        # Process thru each Virtual Server / VIP in array
        foreach ($VIP in $VIPs) {
            # Create new Temporary PSCustomObject array/table for each VS/VIP
            $TempObject = [PSCustomObject]@{
                VirtualServer = $VIP.name
                VirtualServerId = $VIP.virtualServerId
                VirtualServerIP = $VIP.ipAddress
                VirtualServerEnabled = $VIP.enabled
                Protocol = $VIP.protocol
                Port = $VIP.port
                Description = $VIP.description
            }
        
            # If VS/VIP has a defined Pool, include Pool information
            if ($VIP.defaultPoolId) {
                $PoolID = Get-NSXEdge -objectId $NSXEdge | Get-NsxLoadBalancer | Get-NsxLoadBalancerPool -PoolId $VIP.defaultPoolId
                $TempObject | Add-Member -MemberType NoteProperty -Name 'Pool' -Value $PoolID.name
                $TempObject | Add-Member -MemberType NoteProperty -Name 'PoolId' -Value $VIP.defaultPoolId
                $TempObject | Add-Member -MemberType NoteProperty -Name 'PoolAlgorithm' -Value $PoolID.algorithm
            }
        
            # If VS/VIP has a defined Service Monitor, include Service Monitor information
            if ($PoolID.monitorId) {
                $MonitorID = Get-NSXEdge -objectId $NSXEdge | Get-NsxLoadBalancer |  Get-NsxLoadBalancerMonitor -monitorId $PoolID.monitorId
                $TempObject | Add-Member -MemberType NoteProperty -Name 'Monitor' -Value $MonitorID.name
                $TempObject | Add-Member -MemberType NoteProperty -Name 'MonitorId' -Value $PoolID.monitorId
                $TempObject | Add-Member -MemberType NoteProperty -Name 'MonitorType' -Value $MonitorID.type
            }
        
            # Include VS/VIP pool members
            $TempObject | Add-Member -MemberType NoteProperty -Name 'Members' -Value "$($PoolID.member.name) ($($PoolID.member.ipAddress))"
        
            $Results += $TempObject
        }

        # If $Export switch is true, then export $Results to CSV file
        if ($Export) {
            if (!(Test-Path $Path -PathType 'Leaf')) {
                $Results | Export-Csv -Path $Path -NoTypeInformation #-Force
                Return "Results exported to $Path..."
            } else {
                Write-Error "Unable to find $Path file, or file already exists!!!"
                Break
            }
        } else {
            # Return $Results object
            Return $Results
        }
    }
    
    end {
        # Cleanup used Variables
        Write-Verbose "Cleaning up used Variables..."
        #Remove-Variable -Name "NSXEdge" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Edges" -ErrorAction SilentlyContinue
        Remove-Variable -Name "VIPs" -ErrorAction SilentlyContinue
        Remove-Variable -Name "VIP" -ErrorAction SilentlyContinue
        Remove-Variable -Name "TempObject" -ErrorAction SilentlyContinue
        Clear-Variable -Name "PoolID" -ErrorAction SilentlyContinue
        Clear-Variable -Name "MonitorID" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Results" -ErrorAction SilentlyContinue
    }
}