log = console.log
crypto = require 'crypto'
{ exec } = require 'child_process'

Coffee =
  cmd: "./node_modules/coffee-script/bin/coffee"
  options: [
    "-c"                                #compile option
    "-o ./lib"                          #dest
    "./src/coffee"                      #src
  ]
  callback: "mv ./lib/client/*.js ./public/javascripts/ && rm -rf ./lib/client"

Coffeelint =
  cmd: "./node_modules/coffeelint/bin/coffeelint"
  options: [
    "-f test/coffeelint.json"           #config file
    "-r"                                #recurisve
    "./src/coffee"                      #src
  ]

Uglifyjs =
  cmd: "./node_modules/uglify-js/bin/uglifyjs"
  options: [
    "--verbose"                                       #verbose
    "-o ./public/javascripts/slideBaseClient.min.js"  #output
    # "--overwrite"                                   #overwrite
    "./public/javascripts/slideBaseClient.js"         #src
  ]

Stylus =
  cmd: "./node_modules/stylus/bin/stylus"
  options: [
    "./src/styl"                        #src
    "--compress"                        #compress option
    "--include ./node_modules/nib/lib"  #use nib
    "--out ./public/stylesheets"        #dest
  ]

StylusTheme =
  cmd: "./node_modules/stylus/bin/stylus"
  options: [
    "./src/styl/theme"                  #src
    "--compress"                        #compress option
    "--include ./node_modules/nib/lib"  #use nib
    "--out ./public/stylesheets/theme"  #dest
  ]

Docco =
  cmd: "./node_modules/docco/bin/docco"
  options: [
    "-o ./public/docs"                  #dest
    "./src/coffee/*.coffee"             #src
    "./src/coffee/client/*.coffee"      #src
  ]  

task 'compile', (options) ->
  execGlobalCommand(Coffeelint)
  execGlobalCommand(Coffee)
  execGlobalCommand(Stylus)
  execGlobalCommand(StylusTheme)

task 'coffee', (options) ->
  execGlobalCommand(Coffeelint)
  execGlobalCommand(Coffee)

task 'lint', (options) ->
  execGlobalCommand(Coffeelint)

task 'uglify', (options) ->
  execGlobalCommand(Uglifyjs)

task 'lint', (options) ->
  execGlobalCommand(Coffeelint)

task 'doc', (options) ->
  execGlobalCommand(Docco)

option '-p', '--password [PASSWORD]', 'input password will be hashed'
task 'createHash', (options) ->
  log "set this parameter as 'pass' in /config/env.json\x1b[36m"
  log crypto.createHash('sha1').update(options.password).digest('hex') + "\x1b[39m"

task 'clean', (options) ->
  clean()

task 'server', (options) ->
  exec "open 'http://localhost:3000' && node app", (err, stdout, stderr)->
    throw err if err
    log stdout + stderr

execGlobalCommand = (command) ->
  exec "#{command.cmd} #{command.options.join(' ')}", (err, stdout, stderr)->
    log stdout + stderr
    throw err if err
    if (command.callback)
      exec "#{command.callback}", (err, stdout, stderr)->
        log stdout + stderr
        throw err if err

clean = ->
  exec 'rm -rf ./lib/*.js', (err, stdout, stderr)->
    log stdout + stderr
    throw err if err
  exec 'rm -rf ./public/javascripts/*.js', (err, stdout, stderr)->
    log stdout + stderr
    throw err if err
  exec 'rm -rf ./public/stylesheets/*.css', (err, stdout, stderr)->
    log stdout + stderr
    throw err if err
