<#
.SYNOPSIS
Downloads the latest Git for Windows build
.DESCRIPTION
Tool used to get the latest Git for Windows build
.EXAMPLE
.\Get-Git.ps1
#>
$msysgit = "https://msysgit.github.io"
$site = Invoke-WebRequest $msysgit
$url = $site.Links | Where {$_.href -like "*.exe"} | Select -First 1 -ExpandProperty href
$request = Invoke-WebRequest $url | Select -ExpandProperty Headers
$equalpos = $request.Get_Item("Content-Disposition").IndexOf("=")
$filename = $request.Get_Item("Content-Disposition").SubString($equalpos + 1)
Invoke-WebRequest $url -OutFile $filename
