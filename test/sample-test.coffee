require "./_helper"

assert  = require "assert"
request = require "request"
server  = require "../lib/server.js"

console.log "Should write Test"

# describe "/ test", ->
#   describe "GET / ", ->
#     body = null
#     before (done) ->
#       options =
#         uri: "http://localhost:#{server.settings.port}/"
#       request options, (err, response, _body) ->
#         body = _body
#         done()
#     it "has a test message", ->
#       assert.ok /respond/.test(body)