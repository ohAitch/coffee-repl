# coffee-repl

Simple CoffeeScript REPL Bookmarklet for Safari on iOS


## Install

    javascript:(function(d,u,x,c,a){if(a[c]){(new REPL).start();return;}x=d.createElement("script");x.src=u;x.id=c;d.body.appendChild(x);}(document,"https://rawgit.com/ohAitch/coffee-repl/blob/master/coffee-repl.js",null,"eye_repl",this));

## Usage

    .exit / Exit the REPL
    .help / Show repl options
    .1 / last input
    .n / nth input
    .jquery / include("jQuery.js")
    .underscore / include("underscore.js")
    .prototype / include("prototype.js")

    word[space][OK] / autocomplete 

## todo
- LiveScript and prelude.js support

## original

https://github.com/yjerem/eye-repl
