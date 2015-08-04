<#
.SYNOPSIS
Downloads the latest Git for Windows build
.DESCRIPTION
Tool used to get the latest Git for Windows build
.EXAMPLE
.\Get-Git.ps1
#>
$url = "ftp://ftp.vim.org/pub/vim/pc/gvim74.exe"
$filename = "gvim74.exe"
Invoke-WebRequest $url -OutFile $filename

$sf = "http://sourceforge.net/projects/marslosvimgvim/files/7.4.671/"
$site = Invoke-WebRequest $sf
$url = $site.Links.href | Where {$_ -like "*gvim.exe*"} | Select -First 1
$url2 = Invoke-WebRequest $url
$referal = $url2.Links.href | Where {$_ -like "*gvim.exe*"} | Select -Last 1
$download = $url2.Links.href | Where {$_ -like "*gvim.exe*"} | Select -First 1
$slashpos = $referal.LastIndexOf("/")
$filename = $referal.SubString($slashpos + 1)
Invoke-WebRequest $download -OutFile $filename

$sf = "http://sourceforge.net/projects/marslosvimgvim/files/7.4.671/"
$site = Invoke-WebRequest $sf
$url = $site.Links.href | Where {$_ -like "*vim.exe*"} | Select -Index 2
$url2 = Invoke-WebRequest $url
$referal = $url2.Links.href | Where {$_ -like "*vim.exe*"} | Select -Last 1
$download = $url2.Links.href | Where {$_ -like "*vim.exe*"} | Select -First 1
$slashpos = $referal.LastIndexOf("/")
$filename = $referal.SubString($slashpos + 1)
Invoke-WebRequest $download -OutFile $filename

