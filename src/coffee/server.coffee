# module dependencies
express  = require 'express'
http     = require 'http'
path     = require 'path'
connect  = require 'connect'
_        = require 'underscore'

util     = require './slideBaseUtil'
router   = require './router'
log      = console.log

# Config
config   = util.getConfig()

Server =
  createServer: (sessionStore) ->
    # create express instance
    app = express()
    app.configure ->
      app.set 'title','SlideBase'
      app.set 'port', process.env?.PORT || config.server?.port || 3000
      app.use express.favicon()
      app.set 'views', __dirname + '/../views'
      app.set 'view engine', 'ejs'
      app.use util.parallel(
        express.bodyParser(),
        express.cookieParser()
        )
      app.use util.parallel(
        express.methodOverride(),
        express.session
          store: sessionStore
          secret: config.session.secret
          maxAge: false
          cookie:
            httpOnly: false
        )
      # session logging middleware
      # app.use (req, res, next) ->
      # log req.session
      #  next()
      app.use express.logger('dev')
      # .styl file is compiled by Cakefile
      # stylus   = require 'stylus'
      # nib      = require 'nib'
      # app.use stylus.middleware(
      #   src: __dirname + '/../src/styl'
      #   dest: __dirname + '/../public'
      #   log "compile"
      #     stylus(str)
      #       .set('filename', path)
      #       .set('compress', true)
      #       .use(nib())
      # )
      app.use express.static(path.join(__dirname, '/../public'))
      app.use app.router


      app.use (err, req, res, next) ->
        console.error err.stack
        res.status 500
        res.render "err", status :500,title:"500 Internal Server Error"

      app.use (req, res, next) ->
        res.status 404
        res.render "err", status :404,title:"404 Page Not Found"

    app.configure 'development', ->
      app.use express.errorHandler({ dumpExceptions: true, showStack: true })

    app.configure 'production', ->
      app.use express.errorHandler()


    # Routing
    routingList = router.getRoutingList()

    # set GET routing
    _.each routingList["GET"], (pathList,route)->
      _.each pathList, (path) ->
        app.get path, router[route]

    # set POST routing
    _.each routingList["POST"], (pathList,route)->
      _.each pathList, (path) ->
        app.post path, router[route]

    log "Express server listening on port #{app.get('port')} in #{app.settings.env}"
    log "Go http://#{process.env.VCAP_APP_HOST || 'localhost'}:#{app.get('port')}/"
    http.createServer(app).listen(app.get('port'))

module.exports = exports = Server