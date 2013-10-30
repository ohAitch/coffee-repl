script = document.createElement("script")
script.src = "http://coffeescript.org/extras/coffee-script.js"
script.onload = ->
  try
    repl.start()
  catch e
    alert "Internal error:\n" + e.message
document.body.appendChild(script)
repl =
  start: ->
    @callstack = 0
    @done = false
    @history =
      lines: ("" for i in [1..5])
      add: (lines...)->
        @lines.unshift lines
        @lines.pop()
      toString: -> @lines.join "\n"
    @prompt =
      read: "coffee> "
      read_continued: "coffee. "
      result: "=> "
    until @done
      input = @read()
      unless @preprocess input
        @history.add @prompt.read + input
        result = @eval input
        if result.success
          window._ = result.value;
          @print @prompt.result + @inspect(result.value)
        else
          @print result.error
        @callstack = 0
  read: ->
    prompt @prompt.read + "\n" + @history.toString()
  eval: (code) ->
    result = {}
    try
      result.value = eval CoffeeScript.compile code, {bare:true}
      result.success = true
    catch error
      result.error = error.message
      result.success = false
    result
  print: (line) ->
    @history.add line
  inspect: (obj) ->
    if @callstack++>10 then return obj
    switch typeof obj
      when "number", "boolean", "function"
        "" + obj
      when "undefined"
        "undefined"
      when "object"
        if obj == null
          "null"
        else if Object.prototype.toString.apply(obj) == "[object Array]"
          "[" + (@inspect el for el in obj).join(", ") + "]"
        else
          s = ("#{ @inspect key }: #{ @inspect value }" for own key, value of obj).join ", "
          if s == ""
            "{}"
          else
            "{ #{s} }"
      when "string"
        "\"#{ obj }\""
      else
        alert "Internal error"
        undefined
  preprocess: (input) ->
    input = ":exit" if input == null
    if matches = input.match /^:(\w+)$/
      this[matches[1]]()
      true
    else
      false
  exit: ->
    @done = true



