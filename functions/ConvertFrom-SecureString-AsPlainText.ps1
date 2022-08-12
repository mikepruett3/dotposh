# https://swimburger.net/blog/powershell/convertfrom-securestring-a-parameter-cannot-be-found-that-matches-parameter-name-asplaintext
function ConvertFrom-SecureString-AsPlainText {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [System.Security.SecureString]
        $SecureString
    )
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
    $PlainTextString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    Return $PlainTextString
    Remove-Variable -Name "SecureString" -ErrorAction SilentlyContinue
    Remove-Variable -Name "BSTR" -ErrorAction SilentlyContinue
    Remove-Variable -Name "PlainTextString" -ErrorAction SilentlyContinue
}