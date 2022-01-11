
function Select-NSXEdge {
    param ()
    if (!($NSXEdge)) {
        Clear-Variable -Name "NSXEdge" -Scope Global -ErrorAction SilentlyContinue
        $Edges = Get-NSXEdge | Select-Object id, name | Out-String
        Write-Output $Edges
        $RH = Read-Host "No NSX Edge selected, please select one from the list"
        Set-Variable -Name "NSXEdge" -Value $RH -Scope Global -ErrorAction SilentlyContinue
    }
}

