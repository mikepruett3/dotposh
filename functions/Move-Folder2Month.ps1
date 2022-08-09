function Move-Folder2Month {
    <#
    .SYNOPSIS
        Moves folders into created Month folders, based on folder Creation Date
    .DESCRIPTION
        Function that moves each folder located in a specified directory, to a
        newly created "Monthly" folder in the same location... based on the
        Original folders Creation Date.
    .PARAMETER Path
        A Fully-Qualified path to the specified folder to search in.
    .EXAMPLE
        > Move-Folder2Month -Path "C:\Users\MyUser\Folder1"
    .NOTES
        Author: Mike Pruett
        Date: August 9th, 2022
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True,ValueFromPipeline=$true)]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string]
        $Path
    )

    begin {
        # Get list of directores (folders) from $Path
        Write-Verbose "Get list of directores from '$Path' ..."
        $Directories = Get-ChildItem -Directory -Path ${Path}
    }

    process {
        # Process each directory found in $Directories
        Write-Verbose "Processing each each directory found in '$Path' ..."
        foreach ($item in $Directories) {
            $Folder = ${item}.Name
            $Month = (Get-Culture).DateTimeFormat.GetMonthName($item.CreationTime.Month)
            Write-Verbose "Creating folder '$Month' in '$Path', if it does not already exist ..."
            New-Item -Path "$Path\$Month" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
            Write-Verbose "Moving folder '$Folder' to '$Path\$Month\' ..."
            Move-Item -Path "$Path\$Folder" -Destination "$Path\$Month\"
        }
    }

    end {
        # Cleanup used Variables
        Write-Verbose "Cleaning up used Variables ..."
        Remove-Variable -Name "Path" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Directories" -ErrorAction SilentlyContinue
        Remove-Variable -Name "item" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Folder" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Month" -ErrorAction SilentlyContinue
    }
}
