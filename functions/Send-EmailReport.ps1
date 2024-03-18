function Send-EmailReport {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [string]
        $Sender,
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [string]
        $Recipient,
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [string]
        $Subject,
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [string]
        $Server,
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [psobject]
        $Data
    )

    begin {
        #Ping $Server to see if avaliable
        if (!(Test-Connection -Count 1 -ComputerName $Server -Quiet )) {
            Write-Error "Cannot ping $Server!!!"
            Break
        }

        # Email Header
        $Header = @"
        <style>
        TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
        TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
        TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
        </style>
"@
    }

    process {
        $Report = $Data | ConvertTo-Html -Head $Header
        Send-MailMessage `
            -From $Sender `
            -To $Recipient `
            -Subject $Subject `
            -Body "$Report" `
            -BodyAsHtml `
            -SmtpServer $Server
    }

    end {
        # Cleanup
        Write-Verbose "Cleaning up used Variables..."
        Remove-Variable -Name "Sender" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Recipient" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Subject" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Server" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Data" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Header" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Report" -ErrorAction SilentlyContinue
    }
}