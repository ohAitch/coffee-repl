if !CoffeeScript?
  script = document.createElement("script")
  script.src = "http://coffeescript.org/extras/coffee-script.js"
  script.onload = -> (new REPL).loop()
  document.body.appendChild(script)
else
  setTimeout -> (new REPL).loop()

class REPL
  constructor: ->
    window.coffee_repl = @
    @done = false
    @history =
      inputs: [":help"]
      outputs: ["type ':exit' to exit prompt."]
      add: (input, output)->
        @inputs.unshift(input)
        @outputs.unshift(output)
        window.$0 = @outputs[0]
        window.$1 = @outputs[1]
        window.$2 = @outputs[2]
        if @inputs.length > 3 then @inputs.length = @outputs.length = 3
  start: ->
    @done = false
    @loop()
  loop: ->
    input = @read()
    output = @eval(input)
    @history.add(input, output)
    if !@done then setTimeout => @loop()
  read: -> prompt @print()
  eval: (code)->
    if /^\:exit/.test(code)
      @exit()
      return undefined
    else if /^\:help/.test(code)
      return """
        special variables:
          $0
          $1
          $2
          coffee_repl
        special commands:
          :help
          :exit
      """
    try
      eval CoffeeScript.compile(code, {bare:true})
    catch err
      ""+err
  exit: ->
    @done = true
  print: (input, output) ->
    "coffee> \n"+("coffee> #{@history.inputs[i]}\n#{dump(@history.outputs[i])}\n" for v,i in @history.inputs).join("")
  dump = (o, i=0) ->
    switch type(o)
      when "null", "number", "boolean", "undefined","string" then ""+o
      when "function"                                        then (""+o)#.split("{")[0]+"{ [native code] }"
      when "date"                                            then JSON.stringify(o)
      when "array"  then if i <= 3                           then "["+(dump(v) for v in o).join(", ")+"]"
      when "node"   then if i <= 1                           then "{\n"+("#{space(i+1)}#{k}: #{dump(v, i+1)}" for k, v of o).join(",\n")+"\n#{space(i)}}"
      when "node"                                            then Object.prototype.toString.apply(o)
      when "object" then if Object.keys(o).length is 0       then "{}"
      when "object" then if i <= 3                           then "{\n"+("#{space(i+1)}#{k}: #{dump(v, i+1)}" for k, v of o).join(",\n")+"\n#{space(i)}}"
      else
        if i <= 1                                            then "{\n"+("#{space(i+1)}#{k}: #{dump(v, i+1)}" for k, v of o).join(",\n")+"\n#{space(i)}}"
        else                                                      Object.prototype.toString.apply(o)
  space = (i)->
    [0..i].map(->"").join("  ")
  type = (o)->
    if      o is null              then "null"
    else if o is undefined         then "undefined"
    else if o.nodeType             then "node"
    else if Array.isArray o        then "array"
    else if typeof o isnt "object" then typeof o
    else if Object.prototype.toString.apply(o) is "[object Function]" then "function"
    else if Object.prototype.toString.apply(o) is "[object Object]" then "object"
    else                                ""