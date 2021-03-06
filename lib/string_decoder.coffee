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
assertEncoding = (encoding) ->
  throw new Error("Unknown encoding: " + encoding)  if encoding and not Buffer.isEncoding(encoding)
  return

# StringDecoder provides an interface for efficiently splitting a series of
# buffers into a series of JS strings without breaking apart multi-byte
# characters. CESU-8 is handled as part of the UTF-8 encoding.
#
# @TODO Handling all encodings inside a single object makes it very difficult
# to reason about this code, so it should be split up in the future.
# @TODO There should be a utf8-strict encoding that rejects invalid UTF-8 code
# points as used by CESU-8.

# CESU-8 represents each of Surrogate Pair by 3-bytes

# UTF-16 represents each of Surrogate Pair by 2-bytes

# Base-64 stores 3 bytes in 4 chars, and pads the remainder.

# Enough space to store all bytes of a single character. UTF-8 needs 4
# bytes, but CESU-8 may require up to 6 (3 bytes per surrogate).

# Number of bytes received for the current incomplete multi-byte character.

# Number of bytes expected for the current incomplete multi-byte character.

# write decodes the given buffer and returns it as JS string that is
# guaranteed to not contain any partial multi-byte characters. Any partial
# character found at the end of the buffer is buffered up, and will be
# returned when calling write again with the remaining bytes.
#
# Note: Converting a Buffer containing an orphan surrogate to a String
# currently works, but converting a String to a Buffer (via `new Buffer`, or
# Buffer#write) will replace incomplete surrogates with the unicode
# replacement character. See https://codereview.chromium.org/121173009/ .

# if our last write ended with an incomplete multibyte character

# determine how many remaining bytes this buffer has to offer for this char

# add the new bytes to the char buffer

# still not enough chars in this buffer? wait for more ...

# remove bytes belonging to the current character from the buffer

# get the character that was split

# CESU-8: lead surrogate (D800-DBFF) is also the incomplete character

# if there are no more bytes in this buffer, just emit our char

# determine and set charLength / charReceived

# buffer the incomplete character bytes we got

# CESU-8: lead surrogate (D800-DBFF) is also the incomplete character

# or just emit the charStr

# detectIncompleteChar determines if there is an incomplete UTF-8 character at
# the end of the given buffer. If so, it sets this.charLength to the byte
# length that character, and sets this.charReceived to the number of bytes
# that are available for this character.

# determine how many bytes we have to check at the end of this buffer

# Figure out if one of the last i bytes of our buffer announces an
# incomplete char.

# See http://en.wikipedia.org/wiki/UTF-8#Description

# 110XXXXX

# 1110XXXX

# 11110XXX
passThroughWrite = (buffer) ->
  buffer.toString @encoding
utf16DetectIncompleteChar = (buffer) ->
  @charReceived = buffer.length % 2
  @charLength = (if @charReceived then 2 else 0)
  return
base64DetectIncompleteChar = (buffer) ->
  @charReceived = buffer.length % 3
  @charLength = (if @charReceived then 3 else 0)
  return
"use strict"
StringDecoder = exports.StringDecoder = (encoding) ->
  @encoding = (encoding or "utf8").toLowerCase().replace(/[-_]/, "")
  assertEncoding encoding
  switch @encoding
    when "utf8"
      @surrogateSize = 3
    when "ucs2", "utf16le"
      @surrogateSize = 2
      @detectIncompleteChar = utf16DetectIncompleteChar
    when "base64"
      @surrogateSize = 3
      @detectIncompleteChar = base64DetectIncompleteChar
    else
      @write = passThroughWrite
      return
  @charBuffer = new Buffer(6)
  @charReceived = 0
  @charLength = 0
  return

StringDecoder::write = (buffer) ->
  charStr = ""
  while @charLength
    available = (if (buffer.length >= @charLength - @charReceived) then @charLength - @charReceived else buffer.length)
    buffer.copy @charBuffer, @charReceived, 0, available
    @charReceived += available
    return ""  if @charReceived < @charLength
    buffer = buffer.slice(available, buffer.length)
    charStr = @charBuffer.slice(0, @charLength).toString(@encoding)
    charCode = charStr.charCodeAt(charStr.length - 1)
    if charCode >= 0xd800 and charCode <= 0xdbff
      @charLength += @surrogateSize
      charStr = ""
      continue
    @charReceived = @charLength = 0
    return charStr  if buffer.length is 0
    break
  @detectIncompleteChar buffer
  end = buffer.length
  if @charLength
    buffer.copy @charBuffer, 0, buffer.length - @charReceived, end
    end -= @charReceived
  charStr += buffer.toString(@encoding, 0, end)
  end = charStr.length - 1
  charCode = charStr.charCodeAt(end)
  if charCode >= 0xd800 and charCode <= 0xdbff
    size = @surrogateSize
    @charLength += size
    @charReceived += size
    @charBuffer.copy @charBuffer, size, 0, size
    buffer.copy @charBuffer, 0, 0, size
    return charStr.substring(0, end)
  charStr

StringDecoder::detectIncompleteChar = (buffer) ->
  i = (if (buffer.length >= 3) then 3 else buffer.length)
  while i > 0
    c = buffer[buffer.length - i]
    if i is 1 and c >> 5 is 0x06
      @charLength = 2
      break
    if i <= 2 and c >> 4 is 0x0e
      @charLength = 3
      break
    if i <= 3 and c >> 3 is 0x1e
      @charLength = 4
      break
    i--
  @charReceived = i
  return

StringDecoder::end = (buffer) ->
  res = ""
  res = @write(buffer)  if buffer and buffer.length
  if @charReceived
    cr = @charReceived
    buf = @charBuffer
    enc = @encoding
    res += buf.slice(0, cr).toString(enc)
  res
