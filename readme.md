# coffee-repl

Simple CoffeeScript REPL Bookmarklet for Safari on iOS


## Install

    javascript:(function(d,u,x,c,a){if(c){c();return;}x=d.createElement("script");x.src=u;x.id=c;d.body.appendChild(x);}(document,"https://dl.dropboxusercontent.com/u/265158/GitHub/eye-repl/coffee-repl.js",null,coffee_repl.start));

## Usage

### exit

    coffee> :exit

### history

    coffee> "foo"
    "foo"
    coffee> $0 is "foo"
    true
    coffee> [$0, $1, $3]
    [true, "foo", undefined]



## original

https://github.com/yjerem/eye-repl