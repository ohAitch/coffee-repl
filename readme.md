# eye-repl

Simple CoffeeScript REPL Bookmarklet for Safari on iOS


## Install

    javascript:(function(d,u,x,c,a){if(a[c]){(new REPL).start();return;}x=d.createElement("script");x.src=u;x.id=c;d.body.appendChild(x);}(document,"https://dl.dropboxusercontent.com/u/265158/GitHub/eye-repl/coffee-repl.js",null,"eye_repl",this));

## Usage

    .exit / Exit the REPL
    .help / Show repl options
    .1 / last input
    .n / nth input

    word[space][OK] / autocomplete 

## original

https://github.com/yjerem/eye-repl