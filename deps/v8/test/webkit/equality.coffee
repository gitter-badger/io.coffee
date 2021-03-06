# Copyright 2013 the V8 project authors. All rights reserved.
# Copyright (C) 2005, 2006, 2007, 2008, 2009 Apple Inc. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1.  Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
# 2.  Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
description "Test for equality of many combinations types."
values = [
  "0"
  "1"
  "0.1"
  "2"
  "3"
  "4"
  "5"
  "6"
  "7"
  "-0"
  "\"0\""
  "\"1\""
  "\"0.1\""
  "\"-0\""
  "null"
  "undefined"
  "false"
  "true"
  "new String(\"0\")"
  "new Object"
]
exceptions = [
  "\"-0\" == false"
  "\"0\" == false"
  "\"0\" == new String(\"0\")"
  "\"1\" == true"
  "-0 == \"-0\""
  "-0 == \"0\""
  "-0 == false"
  "-0 == new String(\"0\")"
  "0 == \"-0\""
  "0 == \"0\""
  "0 == -0"
  "0 == false"
  "0 == new String(\"0\")"
  "0 === -0"
  "0.1 == \"0.1\""
  "1 == \"1\""
  "1 == true"
  "new Object == new Object"
  "new Object === new Object"
  "new String(\"0\") == false"
  "new String(\"0\") == new String(\"0\")"
  "new String(\"0\") === new String(\"0\")"
  "null == undefined"
]
exceptionMap = new Object
i = undefined
j = undefined
i = 0
while i < exceptions.length
  exceptionMap[exceptions[i]] = 1
  ++i
i = 0
while i < values.length
  j = 0
  while j < values.length
    expression = values[i] + " == " + values[j]
    reversed = values[j] + " == " + values[i]
    shouldBe expression, (if ((i is j) ^ (exceptionMap[expression] or exceptionMap[reversed])) then "true" else "false")
    ++j
  ++i
i = 0
while i < values.length
  j = 0
  while j < values.length
    expression = values[i] + " === " + values[j]
    reversed = values[j] + " === " + values[i]
    shouldBe expression, (if ((i is j) ^ (exceptionMap[expression] or exceptionMap[reversed])) then "true" else "false")
    ++j
  ++i
