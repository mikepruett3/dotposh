function Move-Media {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $Type,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string]
        $Destination
    )

    begin {
        # Strip last "\" from $Destination, if included
        $Destination = $Destination.TrimEnd('\')

        # Create vars based on current path
        Write-Verbose "Creating Variables based on current path..."
        $CurrentDir = $(Split-Path -Path (Get-Location) -Parent)
        $Folder = $(Split-Path -Path (Get-Location) -Leaf)

        # Folder Month Hacking
        Write-Verbose "Hacking out the Month Names from the $Folder Name..."
        $Months = @(
            'January',
            'February',
            'March',
            'April',
            'May',
            'June',
            'July',
            'August',
            'September',
            'October',
            'November',
            'December'
        )
        $MonthSet = $True
        foreach ($Temp in $Months) {
            if ($Folder -ilike "*$Temp*") {
                $Folder = $Folder -ireplace ($Temp,"")
                $Month = $Temp
                $MonthSet = $False
            }
        }
        if ($MonthSet) {
            $Month = (Get-Item -Path . ).CreationTime.ToString("MMMM")
            $MonthNumber = (Get-Item -Path . ).CreationTime.ToString("MM")
            $Folder = $Folder.Replace($Month,"")
            $Folder = $Folder.Replace($MonthNumber,"")
        }

        # Folder Year Hacking
        Write-Verbose "Hacking out the Year from the $Folder Name..."
        $Year = (Get-Item -Path . ).CreationTime.ToString("yyyy")
        $Folder = $Folder.Replace($Year,"")

        # Removing a bunch of Terms from Folder Name
        Write-Verbose "Hacking out matching Terms from the $Folder Name..."
        $Terms = @(
            'magazine',
            'ebook',
            'no',
            'libricide',
            'hybrid',
            'digital',
            'zone-empire',
            'retail'
        )
        foreach ($Temp in $Terms) {
            if ($Folder -ilike "*$Temp*") {
                $Folder = $Folder -ireplace ($Temp,"")
            }
        }

        # Final Folder Name hacking!
        switch ($Type) {
            magazine {
                Write-Verbose "More hacking/cleanup of the $Folder Name...";
                $Folder = $Folder.Replace("(","");
                $Folder = $Folder.Replace(")","");
                $Folder = $Folder.Replace("[","");
                $Folder = $Folder.Replace("]","");
                $Folder = $Folder.Replace("{","");
                $Folder = $Folder.Replace("}","");
                $Folder = $Folder.Replace("USA","US");
                $Folder = $Folder.Split("-")[0];
                $Folder = $Folder -replace ('\d\d\d\d',"");
                $Folder = $Folder -replace ('\d\d\d',"");
                $Folder = $Folder -replace ('\d\d',"");
                $Folder = $Folder.Replace("_","*");
                $Folder = $Folder.Replace(".","*");
                $Folder = $Folder.TrimEnd("*");
            }
            book {
                Write-Verbose "More hacking/cleanup of the $Folder Name...";
                $Folder = $Folder.Replace("(","");
                $Folder = $Folder.Replace(")","");
                $Folder = $Folder.Replace("[","");
                $Folder = $Folder.Replace("]","");
                $Folder = $Folder.Replace("{","");
                $Folder = $Folder.Replace("}","");
            }
            Default {}
        }

        # Check for files matching the $Extensions in the current directory, if not break
        $Extensions = @('pdf','epub','mobi','cbz','cbr')
        foreach ($Temp in $Extensions) {
            Write-Verbose "Check for .$Temp files in the current directory..."
            if ( Get-ChildItem -Recurse -Filter "*.$Temp" ) {
                Write-Verbose "Building a list of .$Temp files in the current directory..."
                $Files = Get-ChildItem -Recurse -Filter "*.$Temp"
                $Extension = $Temp
            } else {
                Write-Verbose "No .$Temp files found in current directory!"
            }
        }
        if ( $Files -eq $Null ) {
            Write-Error "Could not find any files matching any of the '$Extensions' file types listed in current directory!"
            Break
        }
    }

    process {
        switch ($Type) {
            magazine {
                # Determine the matching folder to use in the $Destination
                Write-Verbose "Finding a matching folder like $Folder, in $Destination"
                $Temp = (Get-ChildItem -Path $Destination | Where-Object { $_.BaseName -like "*$Folder*" }).BaseName
                if (Test-Path -Path "$Destination\$Temp\" -PathType 'Container') {
                    #Write-Output $Folder
                    foreach ($File in $Files) {
                        Write-Verbose "Moving $File to '$Destination\$Temp\', as '$Year - $Month.$Extension'"
                        #Write-Output $File.FullName
                        #Write-Output "$Destination\$Temp\$Year - $Month.$Extension"
                        Move-Item -Path "$File" -Destination "$Destination\$Temp\$Year - $Month.$Extension"
                    }
                }
            }
            book {
                foreach ($File in $Files) {
                    Write-Verbose "Moving $File to '$Destination\$Temp\', as '$Year - $Month.$Extension'"
                    Write-Output $File.FullName
                    Write-Output "$Destination\$Temp\$Year - $Month.$Extension"
                    Move-Item -Path "$File" -Destination "$Destination\"
                }
            }
            Default {}
        }
    }

    end {
        # Cleanup used Variables
        Write-Verbose "Cleaning up used Variables..."
        Remove-Variable -Name "Destination" -ErrorAction SilentlyContinue
        Remove-Variable -Name "CurrentDir" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Folder" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Months" -ErrorAction SilentlyContinue
        Remove-Variable -Name "MonthSet" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Month" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Year" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Temp" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Terms" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Extensions" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Extension" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Files" -ErrorAction SilentlyContinue
        Remove-Variable -Name "File" -ErrorAction SilentlyContinue
    }
}