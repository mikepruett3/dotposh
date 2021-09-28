function Get-CertificateExpirationReport {
    <#
    .SYNOPSIS
        Creates a Certificate Expiration Report in HTML format, and send it via email
    .DESCRIPTION
        Function that queries the Certificate Repository of the Local Server, and looks
        for Certificates that will expire in the next X ammount of days. Then creates a
        report, and emails it.
    .PARAMETER Days
        Number of Days to check for Expiration (Todays Date + X days)
    .PARAMETER Server
        Fully-Qualified Host Name of the SMTP Server
    .PARAMETER Recipient
        Recipient Email Address
    .EXAMPLE
        > Get-CertificateExpirationReport -Server smtp.example.com -Days 45 -Recipient myemail@example.com
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [Int]
        $Days,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $Server,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $Recipient
    )
    
    begin {
        Write-Verbose "Creating an Variables..."
        # Create ExpirationDate Variable
        $ExpirationDate = (Get-Date).AddDays($Days)

        # Create HTML Email Header
        $Header = @"
        <style>
        TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;} 
        TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
        TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
        </style>
"@

        # Ping the server
        Write-Verbose "Testing communication with the $Server server..."
        try { Test-Connection -ComputerName $Server -Count 1 -ErrorAction Stop > $null }
        catch {
            Write-Error "Count not communicate with $Server!!!"
            Break
        }
    }
    
    process {
        # Query local Certificate Store for expiring certificates
        try {
            $Report = Get-ChildItem CERT:LocalMachine\My | `
            Where-Object { $_.NotAfter -gt (Get-Date) -and $_.NotAfter -lt $ExpirationDate } | `
            Select-Object Subject, NotAfter, @{Label="Expires In (Days)"; Expression={ (New-TimeSpan -Start (Get-Date) -End $_.NotAfter).Days } } | `
            ConvertTo-Html -Head $Header
        }
        catch {
            Write-Error "Unable to collect report output!"
            Break
        }
        # Email Report
        Send-MailMessage `
            -From "Daily SSL Check <dailysslcheck@example.com>" `
            -To "$Recipient"`
            -Subject "SSL Expirations within 45 days" `
            -Body "$Report" `
            -BodyAsHtml `
            -Priority High `
            -SmtpServer "$Server"
    }
    
    end {
        # Cleanup Variables
        Write-Verbose "Cleaning up variables..."
        Remove-Variable -Name "Days" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Recipient" -ErrorAction SilentlyContinue
        Remove-Variable -Name "ExpirationDate" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Header" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Report" -ErrorAction SilentlyContinue
    }
}
