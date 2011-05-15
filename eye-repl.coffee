class EyeREPL
  constructor: ->
    @done = false
    @history = new History
    @prompt =
      read: "js> "
      read_continued: "js. "
      result: "=> "

  start: ->
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

  read: ->
    prompt @prompt.read + "\n" + @history.toString()

  eval: (code) ->
    result = {}
    try
      result.value = eval code
      result.success = true
    catch error
      result.error = error.message
      result.success = false
    result

  print: (line) ->
    @history.add line

  inspect: (obj) ->
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

class History
  constructor: ->
    @lines = []
    @add "" for i in [1..5]

  add: (lines...) ->
    @lines.unshift lines...

  toString: ->
    @lines.join "\n"

try
  repl = new EyeREPL
  repl.start()
catch error
  alert "Internal error:\n" + error.message

