
function Select-NSXEdge {
    param ()
    if (!($NSXEdge)) {
        $Edges = Get-NSXEdge | Select-Object id, name | Out-String
        Write-Output $Edges
        $NSXEdge = Read-Host "No NSX Edge selected, please select one from the list"
    }
}

