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
unless process.versions.openssl
  console.error "Skipping because node compiled without OpenSSL."
  process.exit 0
common = require("../common")
assert = require("assert")
https = require("https")
fs = require("fs")
path = require("path")
options =
  key: fs.readFileSync(path.join(common.fixturesDir, "test_key.pem"))
  cert: fs.readFileSync(path.join(common.fixturesDir, "test_cert.pem"))

bufSize = 1024 * 1024
sent = 0
received = 0
server = https.createServer(options, (req, res) ->
  res.writeHead 200
  req.pipe res
  return
)
server.listen common.PORT, ->
  resumed = false
  req = https.request(
    method: "POST"
    port: common.PORT
    rejectUnauthorized: false
  , (res) ->
    send = ->
      if req.write(new Buffer(bufSize))
        sent += bufSize
        assert.ok sent < 100 * 1024 * 1024 # max 100MB
        return process.nextTick(send)
      sent += bufSize
      common.debug "sent: " + sent
      resumed = true
      res.resume()
      common.debug "resumed"
      timer = setTimeout(->
        process.exit 1
        return
      , 1000)
      return
    timer = undefined
    res.pause()
    common.debug "paused"
    send()
    res.on "data", (data) ->
      assert.ok resumed
      if timer
        clearTimeout timer
        timer = null
      received += data.length
      if received >= sent
        common.debug "received: " + received
        req.end()
        server.close()
      return

    return
  )
  req.write "a"
  ++sent
  return

process.on "exit", ->
  assert.equal sent, received
  return

