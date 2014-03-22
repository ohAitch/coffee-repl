
class window.REPL
  repl = null
  constructor: ->
    if repl? then return repl
    repl = @
    @run = false
    @env =
      log: (str)=>
        @printbuffer += str+"\n"
        undefined
      clear: =>
        @printbuffer = ""
        @printlogs = ["", "", "", "", ""]
        undefined
      dir: dir
      type: type
      grep: null
      include: include
      $_: undefined
    @history = []
    @printbuffer = ""
    @printlogs = ["", "", "", "", ""]
    @defaultInput = ""
    @prompt = "coffee> "
  help: """
      .exit / Exit the REPL
      .help / Show repl options
      . / last input
      .n / nth input
      .jQuery / include("jQuery.js")
      .underscore / include("underscore.js")
      .prototype / include("prototype.js")
      .livescript / include("livescript.js")

      word[space][OK] / autocomplete 

      log(str)
      clear()
      dir(obj [, maxCallNum])
      type(obj)
      include(url)
      $_
    """
  start: ->
    @run = true
    @loop()
  loop: -> # Void -> Void
    input = prompt(@printlogs.join("\n"), @defaultInput) or ".exit"
    console.log input
    @defaultInput = ""
    begin = @prompt + input + "\n"
    if /\.exit$/.test(input)
      @run = false
      @printlogs.unshift(begin + "\n")
    else if /\.help$/.test(input)
      @printlogs.unshift("#{begin + @help}\n")
    else if /\.jQuery$/i.test(input)
      @printlogs.unshift(begin)
      @run = false
      include "//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js", => @start()
    else if /\.underscore$/i.test(input)
      @printlogs.unshift(begin)
      @run = false
      include "http://underscorejs.org/underscore-min.js", => @start()
    else if /\.prototype$/i.test(input)
      @printlogs.unshift(begin)
      @run = false
      include "//ajax.googleapis.com/ajax/libs/prototype/1.7.1.0/prototype.js", => @start()
    else if /\.livescript$/i.test(input)
      @printlogs.unshift(begin)
      @run = false
      include "http://livescript.net/livescript-1.2.0.js", => @start()
    else if false != n = (/\.(\d*)$/.exec(input) or [false, false])[1] 
      @defaultInput = @history[n or 0]
    else if /\s$/.test(input)
      [pre, ary] = autocomplete(input, @env)
      if ary.length is 1
        @defaultInput = (pre+" "+ary[0]).replace(/^\s+/,"")
      else
        @defaultInput = input.replace(/\s+$/,"")
        @printlogs.unshift("#{@prompt + ary.join("\n")}\n")
    else
      @history.unshift(input)
      try
        @env.$_ = _eval(input, @env)
      catch err
        @env.$_ = ""+err
      @printlogs.unshift("#{@prompt + @printbuffer}#{dir(@env.$_)}")
      @printbuffer = ""
    console.log @printlogs[0]
    @printlogs.length = 5
    if @run then setTimeout => @loop()
    undefined

include = (url, next)->
  script = document.createElement("script")
  script.src = url
  script.onload = next
  document.body.appendChild(script)
  undefined

_eval = (code, env={})->
  args = Object.keys(env)
  oprs = args.map (key)=> env[key]
  Function.apply(null, args.concat(
    CoffeeScript.compile(
      "return do->\n  "+code.split("\n").join("\n  ")
      , {bare:true}))).apply(window, oprs)
###
console.assert(_eval("do->window") is window, "_eval")
###
getPropertys = (o)->
  if !o? then return []
  ary = [].concat Object.getOwnPropertyNames(o), (key for key of o)
  tmp = {}
  _ary = ary.filter (key)->
    if tmp[key]? then false
    else              tmp[key] = true
  _ary.sort()
###
console.assert(""+getPropertys({a:0}) is ""+getPropertys(Object.create({a:0})), "getPropertys")
###
suggest = (code, token, env={})->
  reg = new RegExp("^#{token}.*")
  try
    result = _eval(code, env)
  catch err
    result = {}
  getPropertys(result).filter (key)-> reg.test(key)
###
console.assert(suggest("window", "conso")[0] is "console", "suggest conso")
console.assert(suggest("console", "lo")[0]   is "log",     "suggest console.lo")
console.assert(suggest("Math", "p")[0]       is "pow",     "suggest Math.p")
###
autocomplete = (code, env={})->
  tokens = (code+" ").split(/\s+/).slice(0, -1)
  token = tokens.pop()
  pre = tokens.join(" ")
  if token.indexOf(".") is -1 # "wind"
    result = suggest("window", token, env).map (str)->
      str.replace(/\s+$/,"")
  else
    ary = token.split(".")
    obj = ary.slice(0, -1).join(".")
    key = ary[ary.length-1]
    result = suggest(obj, key, env).map (str)->
      obj+"."+str.replace(/\s+$/,"")
  [pre, result]
###
console.assert(autocomplete("conso")[0]         is "" and
               autocomplete("conso")[1][0]      is "console",      "autocomplete conso")
console.assert(autocomplete("console.lo")[0]    is "" and
               autocomplete("console.lo")[1][0] is "console.log",  "autocomplete console.lo")
console.assert(autocomplete("if {a:0}.")[0]     is "if"
               autocomplete("if {a:0}.")[1][0]  is "{a:0}.a",      "autocomplete {a:0}.")
###
type = (o)->
  if      o is null              then "null"
  else if o is undefined         then "undefined"
  else if o is window            then "global"
  else if o.nodeType             then "node"
  else if typeof o isnt "object" then typeof o
  else
    _type = Object.prototype.toString.call(o)
    if _type is "[object Object]"
      _type = ""+o.constructor
    (/^\[object (\w+)\]$/.exec(_type)   or
          /^\s*function\s+(\w+)/.exec(_type) or
          ["", "object"])[1].toLowerCase()
###
console.assert(type(null)      is "null",      "type null")
console.assert(type(undefined) is "undefined", "type undefined")
console.assert(type(true)      is "boolean",   "type boolean")
console.assert(type(0)         is "number",    "type number")
console.assert(type("string")  is "string",    "type string")
console.assert(type(->)        is "function",  "type function")
console.assert(type([])        is "array",     "type array")
console.assert(type({})        is "object",    "type object")
console.assert(type(new Date)  is "date",      "type date")
console.assert(type(Math)      is "math",      "type math")
console.assert(type(/0/)       is "regexp",    "type regexp")
console.assert(type(window)    is "global",    "type global")
console.assert(type(document.body) is "node",  "type node")
console.assert(type(new (class Foo)) is "foo", "type foo")
###
space = (i)-> [0..i].map(->"").join("  ")
###
console.assert(space(0) is "",   "space 0")
console.assert(space(1) is "  ", "space 1")
###
dir = (o, max=1, i=0) ->
  dumpObj = (o)->
    if getPropertys(o).length is 0 then "{}"
    else                           "{\n#{(getPropertys(o).map (k)->"#{space(i+1)}#{k}: #{dir(o[k], max, i+1)}").join(",\n")}\n#{space(i)}}"
  switch type(o)
    when "null", "undefined", "boolean",  "number" then ""+o
    when "string"                                  then "\"#{o}\""
    when "function"                                then Object.prototype.toString.call(o)
    when "date"                                    then JSON.stringify(o)
    when "array"
      if i < max                                   then "[#{(dir(v, max, i+1) for v in o).join(", ")}]" 
      else                                              Object.prototype.toString.call(o)
    else
      if i < max                                   then dumpObj(o)
      else                                              Object.prototype.toString.call(o)
###
console.assert(dir({a:0}) is dir(Object.create({a:0})), "dir")
###
if window.CoffeeScript? then setTimeout -> (new REPL).start()
else                         include "http://coffeescript.org/extras/coffee-script.js", -> (new REPL).start()
