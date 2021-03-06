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
makeRequest = ->
  req = http.request(
    port: common.PORT
    path: "/"
    method: "POST"
  )
  common.error "pipe!"
  s = fs.ReadStream(filename)
  s.pipe req
  s.on "data", (chunk) ->
    console.error "FS data chunk=%d", chunk.length
    return

  s.on "end", ->
    console.error "FS end"
    return

  s.on "close", (err) ->
    throw err  if err
    clientReqComplete = true
    common.error "client finished sending request"
    return

  req.on "response", (res) ->
    console.error "RESPONSE", res.statusCode, res.headers
    res.resume()
    res.on "end", ->
      console.error "RESPONSE end"
      server.close()
      return

    return

  return
common = require("../common")
assert = require("assert")
fs = require("fs")
http = require("http")
path = require("path")
cp = require("child_process")
filename = path.join(common.tmpDir or "/tmp", "big")
clientReqComplete = false
count = 0
server = http.createServer((req, res) ->
  console.error "SERVER request"
  timeoutId = undefined
  assert.equal "POST", req.method
  req.pause()
  common.error "request paused"
  setTimeout (->
    req.resume()
    common.error "request resumed"
    return
  ), 1000
  req.on "data", (chunk) ->
    common.error "recv data! nchars = " + chunk.length
    count += chunk.length
    return

  req.on "end", ->
    clearTimeout timeoutId  if timeoutId
    console.log "request complete from server"
    res.writeHead 200,
      "Content-Type": "text/plain"

    res.end()
    return

  return
)
server.listen common.PORT
server.on "listening", ->
  cmd = common.ddCommand(filename, 10240)
  console.log "dd command: ", cmd
  cp.exec cmd, (err, stdout, stderr) ->
    throw err  if err
    console.error "EXEC returned successfully stdout=%d stderr=%d", stdout.length, stderr.length
    makeRequest()
    return

  return

process.on "exit", ->
  assert.equal 1024 * 10240, count
  assert.ok clientReqComplete
  return

