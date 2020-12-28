function Create-Shortcut {
    <#
    .SYNOPSIS
        Create a Shortcut, with Arguments and Elevated (if needed)
    .DESCRIPTION
        Function creats a Shortcut, specifing the application w/ arguments,
        description, icon to use, a hotkey combination and if the link
        will need to run as an Administrator (if needed)
    .PARAMETER Link
        The full-path where to create the shortcut
    .PARAMETER App
        The application that the shortcut launches
    .PARAMETER Arguments
        Arguments to include the shortcut, for the application
    .PARAMETER Description
        A description for what the shortcut does
    .PARAMETER Icon
        An icon to use for the shortcut
    .PARAMETER Hotkey
        Optional - a hotkey combination to assign to the shortcut
    .PARAMETER Admin
        Optional - Wether or not to run the shortcut as an Administrator
    .EXAMPLE
        > Create-Shortcut -Link "$Env:UserProfile\Desktop\mylink.lnk" -App "C:\myprog.exe" -Arguments "-option 1" -Description "My description" -Icon "C:\myprog.exe" -Hotkey "CTRL+SHIFT+I" -Admin
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [string]
        $Link,

        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [ValidateScript({ Test-Path -Path $_ })]
        [string]
        $App,

        [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [string]
        $Arguments,

        [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [string]
        $Description,

        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [string]
        $Icon,

        [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [string]
        $HotKey,

        [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
        [switch]
        $Admin
    )
    begin {
        # Create WSHShell Object
        try { $WSHShell = New-Object -ComObject WScript.Shell }
        catch {
            Write-Error "Unable to create WScript.Shell Object!!!"
            Break
        }
    }
    process {
        # Create Shortcut
        $Shortcut = $WSHShell.CreateShortcut($Link)
        $Shortcut.TargetPath = $App
        $Shortcut.Arguments = $Arguments
        $Shortcut.WindowStyle = 1
        if ($HotKey -ne "") {
            $Shortcut.Hotkey = $HotKey
        }
        $Shortcut.IconLocation = $Icon
        $Shortcut.Description = $Description
        $Shortcut.WorkingDirectory = Split-Path $App -Resolve
        $Shortcut.Save()

        # Set Shortcut to RunAs Administrator
        if ($Admin) {
            $Bytes = [System.IO.File]::ReadAllBytes($Link)
            $Bytes[0x15] = $Bytes[0x15] -bor 0x20
            [System.IO.File]::WriteAllBytes($Link, $Bytes)
        }
    }
    end {
        # Cleanup Variables
        Clear-Variable -Name "Server" -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name "Link" -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name "App" -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name "Arguments" -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name "Description" -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name "Icon" -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name "HotKey" -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name "Admin" -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name "WSHShell" -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name "Shortcut" -Scope Global -ErrorAction SilentlyContinue
        Clear-Variable -Name "Bytes" -Scope Global -ErrorAction SilentlyContinue
    }
}
