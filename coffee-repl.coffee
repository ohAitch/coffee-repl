if !CoffeeScript? then include "http://coffeescript.org/extras/coffee-script.js", -> (new REPL).start()
else                   setTimeout -> (new REPL).start()


class REPL
  repl = null
  constructor: ->
    if repl? then return repl
    repl = @
    @run = false
    @commands =
      log: (str)=> @printbuffer += str+"\n"; undefined
      clear: => @printbuffer = @printlog = ""; undefined
      dir: dir
      type: type
      grep: null
      include: include
      $_: undefined
    @history = []
    @help = """
      .exit\tExit the REPL
      .help\tShow repl options
      [space]\tAutocomplete
    """
    @printbuffer = ""
    @printlog = ""
  start: -> @run = true; @loop()
  exit: ->  @run = false; undefined
  loop: ->
    @history.unshift @read()
    @commands.$_ = @eval(@history[0])
    if @run then setTimeout => @loop()
    undefined
  read: ->
    input = prompt "coffee> \n"+@printlog
    if input is null then ".exit"
    else                  input
  eval: (code)->
    if      /\.exit$/.test(code) then @exit()
    else if /\.help$/.test(code) then @help
    else if /\s$/.test(code)     then @autocomplete(code)
    else
      keys = Object.keys(@commands)
      vals = keys.map (key)-> @commands[key]
      try
        Function.apply(null, keys.concat(CoffeeScript.compile(code))).apply(window, vals)
      catch err
        ""+err
  print: ->
    @printlog = "coffee> #{@history[0]}\n#{@printbuffer}\n#{@commands.$_}\n#{@printlog}"
    @buffer = ""
    undefined
  autocomplete: (code)->
    if results = /([A-Za-z0-9_$]+)$/.exec(code)
      reg = new RegExp("^#{results[1]}.*")
      proposals = @eval("Object.getOwnPropertyNames(this)").filter (key)-> reg.test(key)
      proposals.join("\t")
    else if results = /([A-Za-z0-9_$.]+)\.([A-Za-z0-9_$]+)$/.exec(code)
      reg = new RegExp("^#{results[2]}.*")
      proposals = @eval("Object.getOwnPropertyNames(#{results[1]})").filter (key)-> reg.test(key)
    else ""


include = (url, next)->
  script = document.createElement("script")
  script.src = url
  script.onload = next
  document.body.appendChild(script)
  undefined

dir = (o, max=0, i=0) ->
  if i > max then return Object.prototype.toString.apply(o)
  switch type(o)
    when "null", "undefined", "boolean",  "number", "string" then ""+o
    when "function"                                        then (""+o).substr(0,20)+" ... "+"}"
    when "date"                                            then JSON.stringify(o)
    when "array"                                           then "[#{(dir(v, max, i+1) for v in o).join(", ")}]"
    when "node"                                            then dumpObj(o, max, i)
    when "object"                                          then dumpObj(o, max, i)
    else                                                        Object.prototype.toString.apply(o)

dumpObj = (o, max, i)->
  if Object.keys(o).length is 0 then "{}"
  else                               "{\n#{("#{space(i+1)}#{k}: #{dir(v, max, i+1)}" for k, v of o).join(",\n")}\n#{space(i)}}"

type = (o)->
  if      typeof o isnt "object" then typeof o
  else if o.nodeType?            then "node"
  else
    str = Object.prototype.toString.apply(o).split(" ")[1]
    str.substr(0, str.length-1).toLowerCase()

space = (i)-> [0..i].map(->"").join("  ")

