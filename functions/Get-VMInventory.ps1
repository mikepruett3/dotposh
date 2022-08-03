function Get-VMInventory {
    <#
    .SYNOPSIS
        Report of all Virtual Machines from a specifed vCenter
    .DESCRIPTION
        Function that returns a object with all Virtual Servers from
        a specified vCenter, excluding the specified VM Folders.
    .NOTES
        * Makes use of either the Power-NSX cmdlets from the PowerShellGallery
         - https://www.powershellgallery.com/packages/PowerNSX -
          or the PowerCLI cmdlets
         - https://www.powershellgallery.com/packages/VMware.PowerCLI -
    .PARAMETER Folders (Optional)
        A list (array) of VM Folders to exclude from the report. By default
        the script excludes the "Discovered virtual machine" and "vm" folders.
    .EXAMPLE
        > Get-VMInventory
        or
        > Get-VMInventory -Folders "myfolder","anotherfolder"
    .NOTES
        Author: Mike Pruett
        Date: August 3rd, 2022
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        $Folders = ("vm","Discovered virtual machine")
    )

    begin {
        # Check in PowerNSX Module is loaded
        If (!(Get-Module -Name PowerNSX) -and !(Get-Module -Name PowerCLI)) {
            Write-Error "PowerNSX or PowerCLI Module not loaded!!!"
            Break
        }
    }

    process {
        # Collect Inventory of VM's from VCenter, excluding VM's that is stored in $Folders
        # Logic borrowed from https://stackoverflow.com/questions/49898822/powershell-use-match-to-compare-to-an-array
        $Results = Get-VM | Where-Object { $_.Folder -notmatch ('(' + ($Folders -join ')|(') + ')' ) } | `
        Select-Object Name, `
        @{N="IP Address";E={@($_.guest.IPAddress[0])}}, `
        Folder, `
        PowerState

        # Return $Results object
        Return $Results
    }

    end {
        # Cleanup used Variables
        Write-Verbose "Cleaning up used Variables..."
        Remove-Variable -Name "Results" -ErrorAction SilentlyContinue
    }
}
