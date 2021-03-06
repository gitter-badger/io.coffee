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

# tiny node-tap lookalike.
test = (name, fn) ->
  count++
  tests.push [
    name
    fn
  ]
  return
run = ->
  next = tests.shift()
  return console.error("ok")  unless next
  name = next[0]
  fn = next[1]
  console.log "# %s", name
  fn
    same: assert.deepEqual
    equal: assert.equal
    end: ->
      count--
      run()
      return

  return
assert = require("assert")
common = require("../common.js")
fromList = require("_stream_readable")._fromList
tests = []
count = 0

# ensure all tests have run
process.on "exit", ->
  assert.equal count, 0
  return

process.nextTick run
test "buffers", (t) ->
  
  # have a length
  len = 16
  list = [
    new Buffer("foog")
    new Buffer("bark")
    new Buffer("bazy")
    new Buffer("kuel")
  ]
  
  # read more than the first element.
  ret = fromList(6,
    buffer: list
    length: 16
  )
  t.equal ret.toString(), "foogba"
  
  # read exactly the first element.
  ret = fromList(2,
    buffer: list
    length: 10
  )
  t.equal ret.toString(), "rk"
  
  # read less than the first element.
  ret = fromList(2,
    buffer: list
    length: 8
  )
  t.equal ret.toString(), "ba"
  
  # read more than we have.
  ret = fromList(100,
    buffer: list
    length: 6
  )
  t.equal ret.toString(), "zykuel"
  
  # all consumed.
  t.same list, []
  t.end()
  return

test "strings", (t) ->
  
  # have a length
  len = 16
  list = [
    "foog"
    "bark"
    "bazy"
    "kuel"
  ]
  
  # read more than the first element.
  ret = fromList(6,
    buffer: list
    length: 16
    decoder: true
  )
  t.equal ret, "foogba"
  
  # read exactly the first element.
  ret = fromList(2,
    buffer: list
    length: 10
    decoder: true
  )
  t.equal ret, "rk"
  
  # read less than the first element.
  ret = fromList(2,
    buffer: list
    length: 8
    decoder: true
  )
  t.equal ret, "ba"
  
  # read more than we have.
  ret = fromList(100,
    buffer: list
    length: 6
    decoder: true
  )
  t.equal ret, "zykuel"
  
  # all consumed.
  t.same list, []
  t.end()
  return

