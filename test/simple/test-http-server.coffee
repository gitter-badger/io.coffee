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
net = require("net")
http = require("http")
url = require("url")
qs = require("querystring")
request_number = 0
requests_sent = 0
server_response = ""
client_got_eof = false
server = http.createServer((req, res) ->
  res.id = request_number
  req.id = request_number++
  if req.id is 0
    assert.equal "GET", req.method
    assert.equal "/hello", url.parse(req.url).pathname
    assert.equal "world", qs.parse(url.parse(req.url).query).hello
    assert.equal "b==ar", qs.parse(url.parse(req.url).query).foo
  if req.id is 1
    common.error "req 1"
    assert.equal "POST", req.method
    assert.equal "/quit", url.parse(req.url).pathname
  if req.id is 2
    common.error "req 2"
    assert.equal "foo", req.headers["x-x"]
  if req.id is 3
    common.error "req 3"
    assert.equal "bar", req.headers["x-x"]
    @close()
    common.error "server closed"
  setTimeout (->
    res.writeHead 200,
      "Content-Type": "text/plain"

    res.write url.parse(req.url).pathname
    res.end()
    return
  ), 1
  return
)
server.listen common.PORT
server.httpAllowHalfOpen = true
server.on "listening", ->
  c = net.createConnection(common.PORT)
  c.setEncoding "utf8"
  c.on "connect", ->
    c.write "GET /hello?hello=world&foo=b==ar HTTP/1.1\r\n\r\n"
    requests_sent += 1
    return

  c.on "data", (chunk) ->
    server_response += chunk
    if requests_sent is 1
      c.write "POST /quit HTTP/1.1\r\n\r\n"
      requests_sent += 1
    if requests_sent is 2
      c.write "GET / HTTP/1.1\r\nX-X: foo\r\n\r\n" + "GET / HTTP/1.1\r\nX-X: bar\r\n\r\n"
      
      # Note: we are making the connection half-closed here
      # before we've gotten the response from the server. This
      # is a pretty bad thing to do and not really supported
      # by many http servers. Node supports it optionally if
      # you set server.httpAllowHalfOpen=true, which we've done
      # above.
      c.end()
      assert.equal c.readyState, "readOnly"
      requests_sent += 2
    return

  c.on "end", ->
    client_got_eof = true
    return

  c.on "close", ->
    assert.equal c.readyState, "closed"
    return

  return

process.on "exit", ->
  assert.equal 4, request_number
  assert.equal 4, requests_sent
  hello = new RegExp("/hello")
  assert.equal true, hello.exec(server_response)?
  quit = new RegExp("/quit")
  assert.equal true, quit.exec(server_response)?
  assert.equal true, client_got_eof
  return
