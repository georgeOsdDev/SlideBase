util    = require 'util'
fs      = require 'fs'
_       = require 'underscore'
express = require 'express'
connect = require 'connect'
cookie  = require 'cookie'
crypto  = require 'crypto'
RedisStore = require('connect-redis')(express)

# Env Setting
env = process.env.NODE_ENV
config = if env then require "../config/#{env}.json" else require "../config/default.json"

Util =

  getConfig: ->
    config

  encrypt: (input) ->
    cipher = crypto.createCipher 'aes192', getConfig.encKey
    encrypted = cipher.update input, 'utf8', 'hex'
    encrypted +=cipher.final 'hex'

  decrypt: (encrypted) ->
    decipher = crypto.createDecipher 'aes192', getConfig.encKey
    decrypted = decipher.update encrypted, 'hex', 'utf8'
    decrypted += decipher.final 'utf8'

  getHash: (input) ->
    crypto.createHash('sha1').update(input).digest('hex')

  adminAuth: (user, pass) ->
    user is config.admin.user and @getHash(pass) is config.admin.pass

  isAdmin: (socket) ->
    if socket.handshake.session and socket.handshake.session.admin
      return true
    else
      return false

  setCookie: (res, key, val) ->
    option =
      path: "/"
      expires: new Date(Date.now() + 1000 * 60 * 60 * 24 * 1)
    res.cookie key,val,option

  getSessionStore: ->
    switch env
      when "development" , "test"
        # new RedisStore db: 1, prefix: 'session:'
        new (connect.session.MemoryStore)()
      when "production"
        new RedisStore db: 1, prefix: 'sessions'
      # else new RedisStore db: 1, prefix: 'session:'
      else new (connect.session.MemoryStore)()

  parseCookie: (target) ->
    cookie.parse target

  parseSignedCookies: (singedCookie) ->
    connect.utils.parseSignedCookies singedCookie, config.session.secret

  serializeCookie: (obj) ->
    cookie.serialize obj

  getAuthCookie: ->
    connect.utils.uid 32

  getSlides: ->
    fs.readdirSync __dirname + '/../public/slides'

  parallel: ->
    list = arguments
    (req, res, next)->
      current = 0
      for func in list
        func req,res,->
          if ++current is list.length
            next()


module.exports = exports = Util
