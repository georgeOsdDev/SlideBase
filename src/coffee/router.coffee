util    = require './slideBaseUtil'
config  = util.getConfig()
log     = console.log

routingList =
  "GET":
    "index":["/","/index","/index.html","/login","login.html"]
  "POST":
    "login":["/login"]

exports.getRoutingList = ->
  routingList

module.exports.index = (req, res, next) ->
  res.render 'index',
    msg: ""
    msgClass: "hide"
    formClass: ""
    slides: util.getSlides()

module.exports.login = (req, res, next) ->
  req.session.admin = false
  if util.adminAuth req.body.user,req.body.pass
    req.session.admin = true
    util.setCookie res, "admin", true
    log "success login"
    res.render 'index',
      msg: "Your Are Super User"
      msgClass: "successMsg"
      formClass: "hide"
      slides: util.getSlides()
  else
    res.render 'index',
      msg: "Login Error"
      msgClass: "errorMsg"
      formClass: ""
      slides: util.getSlides()
