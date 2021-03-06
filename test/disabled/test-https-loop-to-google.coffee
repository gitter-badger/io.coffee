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

# Failing test for https

# Will fail with "socket hang up" for 4 out of 10 requests
# Tested on node 0.5.0-pre commit 9851574
common = require("../common")
https = require("https")
i = 0

while i < 10
  https.get(
    host: "www.google.com"
    path: "/accounts/o8/id"
    port: 443
  , (res) ->
    data = ""
    res.on "data", (chunk) ->
      data += chunk
      return

    res.on "end", ->
      console.log res.statusCode
      return

    return
  ).on "error", (error) ->
    console.log error
    return

  ++i
