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
isBigEnough = (element, index, array) ->
  element >= 10
isBigEnoughAndPop = (element, index, array) ->
  array.pop()
  element >= 10
isBigEnoughAndChange = (element, index, array) ->
  array[array.length - 1 - index] = 5
  element >= 10
isBigEnoughAndPush = (element, index, array) ->
  array.push 131
  element >= 131
isBigEnoughAndException = (element, index, array) ->
  throw "exception from function"  if index is 1
  element >= 10
isBigEnoughShortCircuit = (element, index, array) ->
  accumulator.push element
  element >= 10
isNotUndefined = (element, index, array) ->
  typeof element isnt "undefined"
description "This test checks the behavior of the every() method on Array objects."
debug "1.0 Single Argument Testing"
shouldBeFalse "[12, 5, 8, 130, 44].every(isBigEnough)"
shouldBeTrue "[12, 54, 18, 130, 44].every(isBigEnough)"
debug ""
debug "2.0 Two Argument Testing"
predicate =
  comparison: 11
  isBigEnough: (s) ->
    s >= comparison

shouldBeFalse "[12, 5, 10, 130, 44].every(isBigEnough, predicate)"
shouldBeTrue "[12, 54, 18, 130, 44].every(isBigEnough, predicate)"
debug ""
debug "3.0 Array Mutation Tests"
debug ""
debug "3.1 Array Element Removal"
shouldBeFalse "[12, 5, 8, 130, 44].every(isBigEnoughAndPop)"
shouldBeTrue "[12, 54, 18, 130, 44].every(isBigEnoughAndPop)"
debug ""
debug "3.2 Array Element Changing"
shouldBeFalse "[12, 5, 8, 130, 44].every(isBigEnoughAndChange)"
shouldBeFalse "[12, 54, 18, 130, 44].every(isBigEnoughAndChange)"
debug ""
debug "3.3 Array Element Addition"
shouldBeFalse "[12, 5, 8, 130, 44].every(isBigEnoughAndPush)"
shouldBeFalse "[12, 54, 18, 130, 44].every(isBigEnoughAndPush)"
debug ""
debug "4.0 Exception Test"
shouldThrow "[12, 5, 8, 130, 44].every(isBigEnoughAndException)", "\"exception from function\""
shouldThrow "[12, 54, 18, 130, 44].every(isBigEnoughAndException)", "\"exception from function\""
debug ""
debug "5.0 Wrong Type for Callback Test"
shouldThrow "[12, 5, 8, 130, 44].every(5)"
shouldThrow "[12, 5, 8, 130, 44].every('wrong')"
shouldThrow "[12, 5, 8, 130, 44].every(new Object())"
shouldThrow "[12, 5, 8, 130, 44].every(null)"
shouldThrow "[12, 5, 8, 130, 44].every(undefined)"
shouldThrow "[12, 5, 8, 130, 44].every()"
debug ""
debug "6.0 Early Exit (\"Short Circuiting\")"
accumulator = new Array()
shouldBeFalse "[12, 5, 8, 130, 44].every(isBigEnoughShortCircuit)"
shouldBe "accumulator.toString()", "[12, 5].toString()"
accumulator.length = 0
shouldBeTrue "[12, 54, 18, 130, 44].every(isBigEnoughShortCircuit)"
shouldBe "accumulator.toString()", "[12, 54, 18, 130, 44].toString()"
debug ""
debug "7.0 Behavior for Holes in Arrays"
arr = [
  5
  5
  5
  5
]
delete arr[1]

shouldBeTrue "arr.every(isNotUndefined)"
arr = new Array(20)
shouldBeTrue "arr.every(isNotUndefined)"
