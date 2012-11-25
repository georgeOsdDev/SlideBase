log = console.log
crypto = require 'crypto'
fs     = require 'fs'
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
  uglify()

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

option '-l', '--length [PAGELENGTH]'
option '-s', '--slide [SLIDE]'
task 'png', 'build png', (options) ->
  pageLength = options.length
  command = 'phantomjs'
  script = 'rasterize.coffee'
  uri = "http://localhost:3000/slides/#{options.slide}"
  width = 1366
  height = 768
  paperwidth = '48.77cm'
  paperheight = '17.43cm'

  exec "#{command} #{script} #{uri} #{pageLength} png #{width} #{height} #{paperwidth} #{paperheight}", (err, stdout, stderr)->
    log stdout + stderr
    throw err if err

task 'pdf', 'build pdf', (options) ->
  exec "convert pdf/*.png pdf/slide.pdf",(err,stdout,stderr) ->
    log stdout + stderr
    throw err if err
    exec "rm -rf pdf/*.png",(err,stdout,stderr) ->
      log stdout + stderr
      throw err if err

execGlobalCommand = (command) ->
  exec "#{command.cmd} #{command.options.join(' ')}", (err, stdout, stderr)->
    log stdout + stderr
    throw err if err
    if (command.callback)
      exec "#{command.callback}", (err, stdout, stderr)->
        log stdout + stderr
        throw err if err

uglify = ->
  files = fs.readdirSync('./public/javascripts/')
  files.forEach (file,i) ->
    src = file.replace('.js','')
    dest = "#{src}.min.js"
    Uglifyjs =
      cmd: "./node_modules/uglify-js/bin/uglifyjs"
      options: [
        "--verbose"                            #verbose
        "-o ./public/javascripts/#{dest}"      #output
        "./public/javascripts/#{file}"         #src
      ]
    execGlobalCommand(Uglifyjs)

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
