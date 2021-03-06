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

# a duplex stream is just a stream that is both readable and writable.
# Since JS doesn't have multiple prototypal inheritance, this class
# prototypally inherits from Readable, and then parasitically from
# Writable.
Duplex = (options) ->
  return new Duplex(options)  unless this instanceof Duplex
  Readable.call this, options
  Writable.call this, options
  @readable = false  if options and options.readable is false
  @writable = false  if options and options.writable is false
  @allowHalfOpen = true
  @allowHalfOpen = false  if options and options.allowHalfOpen is false
  @once "end", onend
  return

# the no-half-open enforcer
onend = ->
  
  # if we allow half-open state, or if the writable side ended,
  # then we're ok.
  return  if @allowHalfOpen or @_writableState.ended
  
  # no more data can be written.
  # But allow more writes to happen in this tick.
  process.nextTick @end.bind(this)
  return
"use strict"
module.exports = Duplex
util = require("util")
Readable = require("_stream_readable")
Writable = require("_stream_writable")
util.inherits Duplex, Readable
keys = Object.keys(Writable::)
v = 0

while v < keys.length
  method = keys[v]
  Duplex::[method] = Writable::[method]  unless Duplex::[method]
  v++
