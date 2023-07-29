function Move-Magazines {
    foreach ( $i in (Get-ChildItem -Directory).BaseName ) {
        Push-Location $i;
        Move-Media -Type magazine -Destination Z:\eLibrary\Magazine -Verbose;
        Pop-Location;
    }
}