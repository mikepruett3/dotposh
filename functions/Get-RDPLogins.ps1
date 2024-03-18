function Get-RDPLogins {
  [CmdletBinding()]
  param ()

  begin {
    $LogName = 'Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational'
    $Filter = @'
    <QueryList><Query Id="0"><Select>
      *[System[EventID=1149]]
    </Select></Query></QueryList>
'@

    # Collect an object of RDP Auth connections
    $RDPAuths = Get-WinEvent -LogName $LogName -FilterXPath $Filter

    # Get specific properties from the event XML
    [xml[]]$xml=$RDPAuths|Foreach{$_.ToXml()}
  }

  process {
    # Process Event Data from the object of RDP Auth connections
    $EventData = Foreach ($event in $xml.Event) {
      # Create custom object for event data
      New-Object PSObject -Property @{
        TimeCreated = (Get-Date ($event.System.TimeCreated.SystemTime) -Format 'yyyy-MM-dd hh:mm:ss K')
        User   = $event.UserData.EventXML.Param1
        Domain = $event.UserData.EventXML.Param2
        Client = $event.UserData.EventXML.Param3
      }
    }

    Return $EventData
  }

  end {
    # Cleanup
    Write-Verbose "Cleaning up used Variables..."
    Remove-Variable -Name "LogName" -ErrorAction SilentlyContinue
    Remove-Variable -Name "Filter" -ErrorAction SilentlyContinue
    Remove-Variable -Name "RDPAuths" -ErrorAction SilentlyContinue
    Remove-Variable -Name "EventData" -ErrorAction SilentlyContinue
  }
}