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
common = require("../common")
assert = require("assert")
http = require("http")
net = require("net")
connects = 0
parseErrors = 0

# Create a TCP server
net.createServer((c) ->
  console.log "connection"
  if ++connects is 1
    c.end "HTTP/1.1 302 Object Moved\r\nContent-Length: 0\r\n\r\nhi world"
  else
    c.end "bad http - should trigger parse error\r\n"
    @close()
  return
).listen common.PORT, "127.0.0.1", ->
  i = 0

  while i < 2
    http.request(
      host: "127.0.0.1"
      port: common.PORT
      method: "GET"
      path: "/"
    ).on("error", (e) ->
      console.log "got error from client"
      assert.ok e.message.indexOf("Parse Error") >= 0
      assert.equal e.code, "HPE_INVALID_CONSTANT"
      parseErrors++
      return
    ).end()
    i++
  return

process.on "exit", ->
  assert.equal connects, 2
  assert.equal parseErrors, 2
  return

