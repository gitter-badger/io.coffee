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

# this is the inverse of test-next-tick-starvation.
# it verifies that process.nextTick will *always* come before other
# events, up to the limit of the process.maxTickDepth value.

# WARNING: unsafe!
spin = ->
  ran = true
  now = +new Date()
  if now - start > 100
    console.log "The timer is starving, just as we planned."
    starved = true
    
    # now let it out.
    return
  process.nextTick spin
  return
onTimeout = ->
  throw new Error("The timer escaped!")  unless starved
  console.log "The timer ran once the ban was lifted"
  timerRan = true
  return
common = require("../common")
assert = require("assert")
process.maxTickDepth = Infinity
ran = false
starved = false
start = +new Date()
timerRan = false
spin()
setTimeout onTimeout, 50
process.on "exit", ->
  assert.ok ran
  assert.ok starved
  assert.ok timerRan
  return

