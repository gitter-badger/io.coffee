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
outstanding_reqs = 0
server = http.createServer((req, res) ->
  res.writeHead 200, [[
    "content-type"
    "text/plain"
  ]]
  res.addTrailers "x-foo": "bar"
  res.end "stuff" + "\n"
  return
)
server.listen common.PORT

# first, we test an HTTP/1.0 request.
server.on "listening", ->
  c = net.createConnection(common.PORT)
  res_buffer = ""
  c.setEncoding "utf8"
  c.on "connect", ->
    outstanding_reqs++
    c.write "GET / HTTP/1.0\r\n\r\n"
    return

  c.on "data", (chunk) ->
    
    #console.log(chunk);
    res_buffer += chunk
    return

  c.on "end", ->
    c.end()
    assert.ok not /x-foo/.test(res_buffer), "Trailer in HTTP/1.0 response."
    outstanding_reqs--
    if outstanding_reqs is 0
      server.close()
      process.exit()
    return

  return


# now, we test an HTTP/1.1 request.
server.on "listening", ->
  c = net.createConnection(common.PORT)
  res_buffer = ""
  tid = undefined
  c.setEncoding "utf8"
  c.on "connect", ->
    outstanding_reqs++
    c.write "GET / HTTP/1.1\r\n\r\n"
    tid = setTimeout(assert.fail, 2000, "Couldn't find last chunk.")
    return

  c.on "data", (chunk) ->
    
    #console.log(chunk);
    res_buffer += chunk
    if /0\r\n/.test(res_buffer) # got the end.
      outstanding_reqs--
      clearTimeout tid
      assert.ok /0\r\nx-foo: bar\r\n\r\n$/.test(res_buffer), "No trailer in HTTP/1.1 response."
      if outstanding_reqs is 0
        server.close()
        process.exit()
    return

  return


# now, see if the client sees the trailers.
server.on "listening", ->
  http.get
    port: common.PORT
    path: "/hello"
    headers: {}
  , (res) ->
    res.on "end", ->
      
      #console.log(res.trailers);
      assert.ok "x-foo" of res.trailers, "Client doesn't see trailers."
      outstanding_reqs--
      if outstanding_reqs is 0
        server.close()
        process.exit()
      return

    res.resume()
    return

  outstanding_reqs++
  return

