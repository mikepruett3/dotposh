function Convert-MP3 {
    foreach ( $i in (Get-ChildItem -Directory).BaseName ) {
        Push-Location $i;
        Convert-Media -Type mp3 -Destination Z:\music-mp3\;
        Pop-Location;
    }
}