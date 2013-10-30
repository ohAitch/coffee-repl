class window.REPL
  repl = null
  constructor: ->
    if repl? then return repl
    repl = @
    @run = false
    @env =
      log: (str)=> @printbuffer += str+"\n"; undefined
      clear: => @printbuffer = @printlog = ""; undefined
      dir: dir
      type: type
      grep: null
      include: include
      $_: undefined
    @history = []
    @help = """
      .exit / Exit the REPL
      .help / Show repl options
      .hist 1 / last input

      word[space][OK] / autocomplete 

      log(str)
      clear()
      dir(obj [, maxCallNum])
      type(obj)
      include(url)
      $_
    """
    @printbuffer = ""
    @printlog = ""
    @defaultInput = ""
  start: -> @run = true; @loop()
  exit: ->  @run = false; undefined
  loop: ->
    @print(@eval(@read()))
    if @run then setTimeout => @loop()
    undefined
  read: ->
    input = prompt "coffee> \n"+@printlog, @defaultInput
    if input is null then input = ".exit"
    @defaultInput = ""
    @history.unshift(input)
    input
  eval: (code)->
    if      /\.exit$/.test(code)    then @exit()
    else if /\.help$/.test(code)    then @help
    else if /\.hist (\d*)$/.test(code) then @defaultInput = @history[/\.history (\d*)$/.exec(code)[1]]
    else if /\s$/.test(code)        then @autocomplete(code)
    else
      keys = Object.keys(@env)
      vals = keys.map (key)=> @env[key]
      try
        @env.$_ = Function.apply(null, keys.concat(CoffeeScript.compile("return do->"+code.split("\n").join("\n  "), {bare:true}))).apply(window, vals)
      catch err
        ""+err
  print: (result)->
    if result?
      @printlog = "coffee> #{@history[0]}\n#{@printbuffer}#{result}\n#{@printlog}"
      @printbuffer = ""
    @printlog = @printlog.split("\n").splice(0, 50).join("\n")
    undefined
  propose: (code)->
    a = @eval("Object.getOwnPropertyNames(#{code})")
    b = @eval("(key for key of #{code})")
    if type(a) isnt "array" or type(b) isnt "array" then return []
    ary = [].concat a, b
    tmp = {}
    _ary = ary.filter (key)->
      if tmp[key]? then false
      else              tmp[key] = true
    _ary.sort()
  autocomplete: (code)->
    if results = /([A-Za-z0-9_$]+)\s$/.exec(code)
      reg = new RegExp("^#{results[1]}.*")
      proposals = @propose("this").filter (key)-> reg.test(key)
      if proposals.length is 1 then @defaultInput = proposals[0]; @history.shift(); null
      else                          @defaultInput = code.substr(0, code.length-1); proposals.join("\n")
    else if results = /([A-Za-z0-9_$.]+)\.\s$/.exec(code)
      proposals = @propose(results[1])
      if proposals.length is 1 then @defaultInput = proposals[0]; @history.shift(); null
      else                          @defaultInput = code.substr(0, code.length-1); proposals.join("\n")
    else if results = /([A-Za-z0-9_$.]+)\.([A-Za-z0-9_$]+)\s$/.exec(code)
      reg = new RegExp("^#{results[2]}.*")
      proposals = @propose(results[1]).filter (key)-> reg.test(key)
      if proposals.length is 1 then @defaultInput = results[1]+"."+proposals[0]; @history.shift(); null
      else                          @defaultInput = code.substr(0, code.length-1); proposals.join("\n")
    else null




include = (url, next)->
  script = document.createElement("script")
  script.src = url
  script.onload = next
  document.body.appendChild(script)
  undefined

dir = (o, max=1, i=0) ->
  if i >= max then return Object.prototype.toString.apply(o)
  switch type(o)
    when "null", "undefined", "boolean",  "number", "string" then ""+o
    when "function"                                        then (""+o).split("\n").join("").substr(0,20)+" ... "+"}"
    when "date"                                            then JSON.stringify(o)
    when "array"                                           then "[#{(dir(v, max, i+1) for v in o).join(", ")}]"
    when "object"                                          then dumpObj(o, max, i)
    else                                                        dumpObj(o, max, i)

dumpObj = (o, max, i)->
  if Object.keys(o).length is 0 then "{}"
  else                               "{\n#{("#{space(i+1)}#{k}: #{dir(v, max, i+1)}" for k, v of o).join(",\n")}\n#{space(i)}}"

type = (o)->
  if      typeof o isnt "object" then typeof o
  else
    str = Object.prototype.toString.apply(o).split(" ")[1]
    str.substr(0, str.length-1).toLowerCase()

space = (i)-> [0..i].map(->"").join("  ")


if !CoffeeScript? then include "http://coffeescript.org/extras/coffee-script.js", -> (new REPL).start()
else                   setTimeout -> (new REPL).start()
