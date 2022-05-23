// Borrowed from https://towardsdatascience.com/quickly-extract-all-links-from-a-web-page-using-javascript-and-the-browser-console-49bb6f48127b

javascript: {
    var x = document.querySelectorAll("a");
    var links = [];
    var extensions = [".iso",".cue",".bin",".rar",".7z",".zip",".mp3",".wav",".flac",".ogg",".mkv"];
    for (let i = 0; i < x.length; i++){
        const element = x[i];
        var nametext = x[i].textContent;
        var cleanlink = x[i].href;
        for (let i = 0; i < extensions.length; i++) {
            const element = extensions[i];
            if ( cleanlink.match(extensions[i]) ) {
                links.push([cleanlink]);
            }
        }
    };
    var w = window.open("");
    var display = [];
    for (let i = 0; i < links.length; i++) {
        const element = links[i];
        display += links[i] + '</br>';
    }
    w.document.write(display);
};

// One-Liner for Bookmarklet
// Created here - https://www.scrapersnbots.com/blog/code/how-to-create-javascript-bookmarklet.php#createbookmark
javascript: { var x = document.querySelectorAll("a"); var links = []; var extensions = [".iso",".cue",".bin",".rar",".7z",".zip",".mp3",".wav",".flac",".ogg",".mkv"]; for (let i = 0; i < x.length; i++){ const element = x[i]; var nametext = x[i].textContent; var cleanlink = x[i].href; for (let i = 0; i < extensions.length; i++) { const element = extensions[i]; if ( cleanlink.match(extensions[i]) ) { links.push([cleanlink]); } } }; var w = window.open(""); var display = []; for (let i = 0; i < links.length; i++) { const element = links[i]; display += links[i] + '</br>'; } w.document.write(display);};
