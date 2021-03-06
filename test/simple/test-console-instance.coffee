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
Stream = require("stream")
Console = require("console").Console
called = false

# ensure the Console instance doesn't write to the
# process' "stdout" or "stderr" streams
process.stdout.write = process.stderr.write = ->
  throw new Error("write() should not be called!")return


# make sure that the "Console" function exists
assert.equal "function", typeof Console

# make sure that the Console constructor throws
# when not given a writable stream instance
assert.throws (->
  new Console()
  return
), /Console expects a writable stream/
out = new Stream()
err = new Stream()
out.writable = err.writable = true
out.write = err.write = (d) ->

c = new Console(out, err)
out.write = err.write = (d) ->
  assert.equal d, "test\n"
  called = true
  return

assert not called
c.log "test"
assert called
called = false
c.error "test"
assert called
out.write = (d) ->
  assert.equal "{ foo: 1 }\n", d
  called = true
  return

called = false
c.dir foo: 1
assert called

# ensure that the console functions are bound to the console instance
called = 0
out.write = (d) ->
  called++
  assert.equal d, called + " " + (called - 1) + " [ 1, 2, 3 ]\n"
  return

[
  1
  2
  3
].forEach c.log
assert.equal 3, called
