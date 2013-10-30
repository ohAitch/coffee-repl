if !CoffeeScript?
  script = document.createElement("script")
  script.src = "http://coffeescript.org/extras/coffee-script.js"
  script.onload = -> (new REPL).loop()
  document.body.appendChild(script)
else
  setTimeout -> (new REPL).loop()

class REPL
  constructor: ->
    window.eye_repl = @
    @done = false
    @history =
      inputs: []
      outputs: []
      add: (input, output)->
        @inputs.unshift(input)
        @outputs.unshift(output)
        window.$0 = @outputs[0]
        window.$1 = @outputs[1]
        window.$2 = @outputs[2]
        window.$3 = @outputs[3]
        window.$4 = @outputs[4]
        if @inputs.length > 5 then @inputs.length = @outputs.length = 5
  loop: ->
    input = @read()
    output = @eval(input)
    console.log output
    @history.add(input, output)
    if !@done then setTimeout => @loop()
  read: -> prompt @print()
  eval: (code)->
    if /^exit/.test(code)
      @done = true
      return undefined
    try
      eval CoffeeScript.compile(code, {bare:true})
    catch err
      ""+err
  print: (input, output) ->
    for v,i in @history.inputs
      "coffee> #{@history.inputs[i]}\n#{dump(@history.outputs[i])}"
  dump = (o, i=0) ->
    switch type(o)
      when "null", "number", "boolean", "undefined" then ""+o
      when "function"                               then (""+o).split("{")[0]+"{ [native code] }"
      when "date","string"                          then JSON.stringify(o)
      when "array"  then if i <= 3                  then "["+(dump(v) for v in o).join(", ")+"]"
      else
        if i <= 2
          if Object.keys(o).length is 0 then "{}"
          else                               "{\n"+("#{space(i+1)}#{k}: #{dump(v, i+1)}" for k, v of o).join(",\n")+"\n#{space(i)}}"
        else                                 Object.prototype.toString.apply(o)
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