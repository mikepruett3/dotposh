function Get-PoolStatus {
    <#
    .SYNOPSIS
        Load Balancer Pool status from a specifed NSX Edge
    .DESCRIPTION
        Function that outputs a custom PS Object with the status of a Load Balancer Pool
        from a specified NSX Edge.
    .NOTES
        * Makes use of the Power-NSX cmdlets from the PowerShellGallery
         - https://www.powershellgallery.com/packages/PowerNSX -
    .EXAMPLE
        > Get-PoolStatus
    .NOTES
        Author: Mike Pruett
        Date: July 28th, 2023
    #>
    [CmdletBinding()]
    param ()

    begin {
        # Check in PowerNSX Module is loaded
        If (!(Get-Module -Name PowerNSX)) {
            Write-Error "PowerNSX Module not loaded!!!"
            Write-Error "Connect-NSX -Server <FQDN-vCenter-Server> -Credential <Username>"
            Break
        }

        # Check if the variable $defaultNSXConnection exists
        if (!($defaultNSXConnection)) {
            Write-Error "Not connected to a(n) NSX Instance!!!"
            Write-Error "Connect-NSX -Server <FQDN-vCenter-Server> -Credential <Username>"
            Break
        }

        # Check if the variable $Edge exists
        if (!($Edge)) {
            # List Edges
            Get-NsxEdge | Select-Object name | Out-String
            # Collect NSX Edge to Enumerate
            Remove-Variable -Name "ReadHost" -ErrorAction SilentlyContinue
            $ReadHost = Read-Host "No NSX Edge selected, please select one from the list"
            Set-Variable -Name "Edge" -Value $ReadHost -Scope Global
        }

        # Check if the variable $VirtualServer exists
        if (!($VirtualServer)) {
            # List Virtual Servers
            (Get-NsxEdge -Name $Edge | Get-NsxLoadBalancer).virtualServer | Select-Object name | Out-String
            # Collect Virtual Servers to Enumerate
            Remove-Variable -Name "ReadHost" -ErrorAction SilentlyContinue
            $ReadHost = Read-Host -Prompt "No Virtual Server selected, please select one from the list"
            Set-Variable -Name "VirtualServer" -Value $ReadHost -Scope Global
        }

        # Find the Pool Name
        foreach ($Item in (Get-NsxEdge -Name $Edge | Get-NsxLoadBalancer).virtualServer) {
            if ($Item.name -eq $VirtualServer) {
                $PoolName = $Item.defaultPoolId
            }
        }

        # Create empty Results array
        $Results = @()
    }

    process {
        # Pull Load Balancer Stats from the $Edge
        $Stats = Get-NsxEdge -Name $Edge | Get-NsxLoadBalancer | Get-NsxLoadBalancerStats

        # Output the Status of the Specified Pool
        foreach ($Pool in $Stats.pool) {
            if ($Pool.poolId -eq $PoolName) {
                $Members = $Pool.member
                foreach ($Member in $Members) {
                    $Temp = [pscustomobject]@{
                        "PoolName" = $Pool.name
                        "PoolStatus" = $Pool.Status
                        "MemberName" = $Member.name
                        "MemberStatus" = $Member.Status
                        "MemberIp" = $Member.ipAddress
                    }
                    $Results += $Temp
                }
            }
        }

        # Return $Results object
        Return $Results | Format-Table
    }

    end {
        # Cleanup used Variables
        Write-Verbose "Cleaning up used Variables..."
        Remove-Variable -Name "ReadHost" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Item" -ErrorAction SilentlyContinue
        Remove-Variable -Name "PoolName" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Stats" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Pool" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Members" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Member" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Temp" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Results" -ErrorAction SilentlyContinue
    }
}