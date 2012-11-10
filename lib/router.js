// Generated by CoffeeScript 1.3.3
(function() {
  var config, log, routingList, util;

  util = require('./slideBaseUtil');

  config = util.getConfig();

  log = console.log;

  routingList = {
    "GET": {
      "index": ["/", "/index", "/index.html", "/login", "login.html"]
    },
    "POST": {
      "login": ["/login"]
    }
  };

  exports.getRoutingList = function() {
    return routingList;
  };

  module.exports.index = function(req, res, next) {
    return res.render('index', {
      msg: "",
      msgClass: "hide",
      formClass: "",
      slides: util.getSlides()
    });
  };

  module.exports.login = function(req, res, next) {
    req.session.admin = false;
    if (util.adminAuth(req.body.user, req.body.pass)) {
      req.session.admin = true;
      util.setCookie(res, "admin", true);
      log("success login");
      return res.render('index', {
        msg: "Your Are Super User",
        msgClass: "successMsg",
        formClass: "hide",
        slides: util.getSlides()
      });
    } else {
      return res.render('index', {
        msg: "Login Error",
        msgClass: "errorMsg",
        formClass: "",
        slides: util.getSlides()
      });
    }
  };

}).call(this);