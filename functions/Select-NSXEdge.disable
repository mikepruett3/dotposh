
function Select-NSXEdge {
    # Clear previously set $NSXEdge Global Variable
    Clear-Variable -Name "NSXEdge" -Scope Global -ErrorAction SilentlyContinue

    # Query NSX for list of Edges (Global or Local)
    $Edges = Get-NSXEdge | Select-Object id, name | Out-String
    Write-Output $Edges

    # User input of desired NSX Edge
    $RH = Read-Host "No NSX Edge selected, please select one from the list"

    # Set $NSXEdge Global Variable to new value
    Set-Variable -Name "NSXEdge" -Value $RH -Scope Global -ErrorAction SilentlyContinue
}

