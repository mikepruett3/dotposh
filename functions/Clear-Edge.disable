function Clear-Edge {
    param ()
    Write-Output "Removing Global Variable for NSX Edge. You will need to pick another NSX Edge when you run Get-PoolStatus!"
    Remove-Variable -Name "Edge" -Scope Global -ErrorAction SilentlyContinue
    Remove-Variable -Name "VirtualServer" -Scope Global -ErrorAction SilentlyContinue
}