# coffee-repl

Simple CoffeeScript REPL Bookmarklet for Safari on iOS


## Install

    javascript:(function(d,u,x,c,a){if(a[c])return;x=d.createElement("script");x.src=u;x.id=c;d.body.appendChild(x);}(document,"https://dl.dropboxusercontent.com/u/265158/GitHub/eye-repl/coffee-repl.js",null,"coffee-repl",this));

## Usage

### exit
    coffee> exit

### $0,$1,$2
    coffee> "foo"
    "foo"
    coffee> $0 is "foo"
    true
    coffee> [$0, $1]
    [true, "foo"]

## original

https://github.com/yjerem/eye-repl