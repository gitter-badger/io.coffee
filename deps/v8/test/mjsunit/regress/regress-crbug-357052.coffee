# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
f = ->
  str = ""
  i = 0

  while i < 30
    str += "abcdefgh12345678" + str
    i++
  str
assertThrows f