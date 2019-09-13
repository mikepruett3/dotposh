function Convert-HEXGUID {
    <#
    .SYNOPSIS
        Convert GUID to Hex, and Vice-Versa
    .DESCRIPTION
        Small function to convert ASCII-Based Microsoft GUID's to Hexadecimal for use with Active Directory
    .NOTES
        Code Snippet created by u/thankski-budski on r/PowerShell
        https://www.reddit.com/r/PowerShell/comments/bv5kx9/question_convert_hex_value_to_guid/eppt59d?utm_source=share&utm_medium=web2x
    .LINK
        https://www.reddit.com/r/PowerShell/comments/bv5kx9/question_convert_hex_value_to_guid/
    .PARAMETER HEX
        Hexadecimal value (No Spaces) to conver to ASCII-Based GUID
    .PARAMETER GUID
        ASCII-Based GUID value to convert to Hexadecimal
    .EXAMPLE
        > Convert-HEXGUID -Hex AC9170EEF223F344BA10B86F4045C430

        ee7091ac-23f2-44f3-ba10-b86f4045c430
    .EXAMPLE
        > Convert-HEXGUID -GUID 26a2a7e2-2c4c-43f5-bbb7-f2ad2e8b24cb
        e2a7a2264c2cf543bbb7f2ad2e8b24cb
    #>
    param (
        [CmdletBinding(DefaultParameterSetName='Hex')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Hex')]
        [GUID]$Hex,
        [Parameter(Mandatory = $true, ParameterSetName = 'GUID')]
        [GUID]$GUID
    )

    switch($PSBoundParameters.Keys) {
        'Hex'   { [GUID](($Hex.ToByteArray() | % { '{0:x}' -f $_ }) -join '') }
        'GUID'  { [String](($GUID.ToByteArray() | % { '{0:x}' -f $_ }) -join '') }
    }
}
