socketIO = require 'socket.io'
_        = require 'underscore'

slideBaseUtil = require './slideBaseUtil'
log           = console.log

# Config
config   = slideBaseUtil.getConfig()
store = slideBaseUtil.getSessionStore()

users = []
activeUser = 0

SlideBase =
  self: ->
    @

  createServer: ->
    server = require('./server.js')
    server.createServer store

  setUpSlideBase: (server) ->
    self = @self()
    # Listen sercer with socket.IO
    io = socketIO.listen server

    # Config
    io.configure ->
      io.set 'authorization', (handshakeData, callback) ->
        # Reference to http://www.pxsta.net/blog/?p=3568
        if handshakeData.headers.cookie
          singedCookie = slideBaseUtil.parseCookie decodeURIComponent(handshakeData.headers.cookie)
          cookie = slideBaseUtil.parseSignedCookies singedCookie
          sessionID = cookie['connect.sid']
          store.get sessionID ,(err,session) ->
            if err
              log "err", err
              callback err.message, false
            else if !session
              callback "session not found", false
            else
              log "session found"
              handshakeData.cookie = cookie
              handshakeData.sessionID = sessionID
              handshakeData.session = session
              callback null, true
        else
          callback "cookie not found", true

      io.enable 'browser client minification'
      io.enable 'browser client etag'
      io.set 'transports', ['websocket']
      io.set 'log level',1

    io.configure 'production', ->
      io.set 'log level',1
      io.set 'transports', [
                            'websocket'
                            'flashsocket'
                            'htmlfile'
                            'xhr-polling'
                            'jsonp-polling'
                          ]

    #Socket.io event handler
    io.sockets.on 'connection', (socket) ->
      log "new user is connected"

      self.activeUser++
      user =
        id: socket.id
        sts:"active"
      users.push user
      io.sockets.emit "users",users

      # Handle message
      socket.on 'message', (data) ->
        socket.broadcast.volatile.emit "message", data

      socket.on 'move', (data) ->
        # move method is enable only admin user
        if slideBaseUtil.isAdmin socket then socket.broadcast.volatile.emit "move", data

      socket.on 'plugin', (data) ->
        if data.plugin.name = 'gaya' then log data.data
        socket.broadcast.volatile.emit "plugin", data

      # Heartbeat
      socket.on 'heartbeat', ->
        log " #{socket.id} is alive"

      # Disconnect
      socket.on 'disconnect', ->
        log "user:#{socket.id} was disconnected"
        @users.socket.id = {}
        socket.broadcast.volatile.emit "users",users

      # Error
      socket.on 'error', (event)->
        console.error "Error occured", event

  startSlide: ->
    @setUpSlideBase(@createServer())

module.exports = exports = SlideBase