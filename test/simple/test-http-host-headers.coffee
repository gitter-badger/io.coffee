# Copyright Joyent, Inc. and other Node contributors.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the
# following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
# NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
# USE OR OTHER DEALINGS IN THE SOFTWARE.
reqHandler = (req, res) ->
  console.log "Got request: " + req.headers.host + " " + req.url
  if req.url is "/setHostFalse5"
    assert.equal req.headers.host, `undefined`
  else
    assert.equal req.headers.host, "localhost:" + common.PORT, "Wrong host header for req[" + req.url + "]: " + req.headers.host
  res.writeHead 200, {}
  
  #process.nextTick(function() { res.end('ok'); });
  res.end "ok"
  return
thrower = (er) ->
  throw erreturn
testHttp = ->
  cb = (res) ->
    counter--
    console.log "back from http request. counter = " + counter
    if counter is 0
      httpServer.close()
      testHttps()
    res.resume()
    return
  console.log "testing http on port " + common.PORT
  counter = 0
  httpServer.listen common.PORT, (er) ->
    console.error "listening on " + common.PORT
    throw er  if er
    
    #agent: false,
    http.get(
      method: "GET"
      path: "/" + (counter++)
      host: "localhost"
      port: common.PORT
      rejectUnauthorized: false
    , cb).on "error", thrower
    
    #agent: false,
    http.request(
      method: "GET"
      path: "/" + (counter++)
      host: "localhost"
      port: common.PORT
      rejectUnauthorized: false
    , cb).on("error", thrower).end()
    
    #agent: false,
    http.request(
      method: "POST"
      path: "/" + (counter++)
      host: "localhost"
      port: common.PORT
      rejectUnauthorized: false
    , cb).on("error", thrower).end()
    
    #agent: false,
    http.request(
      method: "PUT"
      path: "/" + (counter++)
      host: "localhost"
      port: common.PORT
      rejectUnauthorized: false
    , cb).on("error", thrower).end()
    
    #agent: false,
    http.request(
      method: "DELETE"
      path: "/" + (counter++)
      host: "localhost"
      port: common.PORT
      rejectUnauthorized: false
    , cb).on("error", thrower).end()
    return

  return
testHttps = ->
  cb = (res) ->
    counter--
    console.log "back from https request. counter = " + counter
    if counter is 0
      httpsServer.close()
      console.log "ok"
    res.resume()
    return
  console.log "testing https on port " + common.PORT
  counter = 0
  httpsServer.listen common.PORT, (er) ->
    throw er  if er
    
    #agent: false,
    https.get(
      method: "GET"
      path: "/" + (counter++)
      host: "localhost"
      port: common.PORT
      rejectUnauthorized: false
    , cb).on "error", thrower
    
    #agent: false,
    https.request(
      method: "GET"
      path: "/" + (counter++)
      host: "localhost"
      port: common.PORT
      rejectUnauthorized: false
    , cb).on("error", thrower).end()
    
    #agent: false,
    https.request(
      method: "POST"
      path: "/" + (counter++)
      host: "localhost"
      port: common.PORT
      rejectUnauthorized: false
    , cb).on("error", thrower).end()
    
    #agent: false,
    https.request(
      method: "PUT"
      path: "/" + (counter++)
      host: "localhost"
      port: common.PORT
      rejectUnauthorized: false
    , cb).on("error", thrower).end()
    
    #agent: false,
    https.request(
      method: "DELETE"
      path: "/" + (counter++)
      host: "localhost"
      port: common.PORT
      rejectUnauthorized: false
    , cb).on("error", thrower).end()
    https.get(
      method: "GET"
      path: "/setHostFalse" + (counter++)
      host: "localhost"
      setHost: false
      port: common.PORT
      rejectUnauthorized: false
    , cb).on("error", thrower).end()
    return

  return
http = require("http")
https = require("https")
fs = require("fs")
common = require("../common")
assert = require("assert")
options =
  key: fs.readFileSync(common.fixturesDir + "/keys/agent1-key.pem")
  cert: fs.readFileSync(common.fixturesDir + "/keys/agent1-cert.pem")

httpServer = http.createServer(reqHandler)
httpsServer = https.createServer(options, reqHandler)
testHttp()
