fs = require 'fs'
{puts} = require 'sys'
{exec} = require 'child_process'

task 'build', 'compile CoffeeScript source to JavaScript', ->
  exec 'coffee -cm ./', (error, stdout, stderr) ->
    puts stdout
