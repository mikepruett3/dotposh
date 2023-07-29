function Move-Books {
    foreach ( $i in (Get-ChildItem -Directory).BaseName ) {
        Push-Location $i;
        Move-eBooks -Type book -Destination Z:\eLibrary\Import -Verbose;
        Pop-Location;
    }
}