Function Get-AutoDiscRecords {
    <#
    .SYNOPSIS
    Function to check NameServers for correctly configured Exchange and AutoDiscover records existance.
    .DESCRIPTION
    You can even specify the NameServer (Internal or External) for Split-DNS existance, Using nslookup tool.
    Currently configured to use Googles Free DNS Server (8.8.4.4) by default
    .PARAMETER domain
    The domain in question to check. (eg MyNewEmailDomain.com)
    .PARAMETER nameserver
    Sepcify a NameServer's IP or HostName to use for testing (OPTIONAL)
    .EXAMPLE
    Get-AutoDiscRecords -domain MyNewEmailDomain.com
    .EXAMPLE
    Get-AutoDiscRecords -domain MyNewEmailDomain.com -nameserver 4.2.2.1
    #>

    [CmdletBinding()]

    Param (
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='What domain would you like to check?')]
        [string]$domain,
        [string]$nameserver = "8.8.4.4"
    )

    Process {
        $mx = ((nslookup -q=MX $domain $nameserver 2> $NULL | Select -Last 1).toString().Split("") | Select -Last 1)
        $spf = (nslookup -q=TXT $domain $nameserver 2> $NULL | Select -Last 1).toString().Trim()
        $autodiscover = ((nslookup autodiscover.$domain $nameserver 2> $NULL).Split(":").Trim() | ? {$_.Trim() -ne ""} | Select -Last 1)
        $srv = ((nslookup -q=SRV _autodiscover._tcp.$domain $nameserver 2> $NULL | Select -Last 1).toString().Split("=").Trim() | Select -Last 1)

        if ($spf -like "*v=*") {
            $spfrecord = $spf
        }else{
            $spfrecord = "No SPF record found!!!"
        }

        if ($autodiscover -eq $nameserver) {
            $adrecord = "No AutoDiscover Host record found!!!"
        }else{
            $adrecord = "autodiscover.$domain points to $autodiscover"
        }

        if ( $srv -eq "" ) {
            $srvrecord = "No AutoDiscover SRV record found!!!"
        }else{
            $srvrecord = "_autodiscover._tcp.$domain points to $srv"
        }

        $result = [ordered]@{
            Domain          = $domain;
            MXRecord        = $mx;
            SPFRecord       = $spfrecord;
            AutoDiscover    = $adrecord;
            SRVRecord       = $srvrecord
        }

        Return $result
    }
}

