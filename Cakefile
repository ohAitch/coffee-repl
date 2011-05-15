sys = require "sys"
exec = require("child_process").exec
fs = require "fs"

task "build", "compile CoffeeScript source to JavaScript", ->
  exec "coffee -c eye-repl.coffee", (error, stdout, stderr) ->
    sys.puts stdout
    fs.readFile "eye-repl.js", (err, data) ->
      throw err if err
      data = "javascript:\n\n" + data
      fs.writeFile "eye-repl-post.js", data, "utf8", (err) ->
        throw err if err
        fs.unlink "eye-repl.js", ->
          fs.rename "eye-repl-post.js", "eye-repl.js"
