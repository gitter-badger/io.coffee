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
forwarder = (f, thisValue, args) ->
  g = ->
    f.apply thisValue, arguments
  g.apply null, args
recurseArguments = ->
  recurseArguments.apply null, arguments
  return
stackOverflowTest = ->
  try
    a = undefined
    b = undefined
    c = undefined
    d = undefined
    e = undefined
    f = undefined
    g = undefined
    h = undefined
    i = undefined
    j = undefined
    k = undefined
    l = undefined
    m = undefined
    n = undefined
    o = undefined
    p = undefined
    q = undefined
    r = undefined
    s = undefined
    t = undefined
    u = undefined
    v = undefined
    w = undefined
    x = undefined
    y = undefined
    z = undefined
    stackOverflowTest()
  catch e
    
    # Blow the stack with a sparse array
    shouldThrow "myFunction.apply(null, new Array(5000000))"
    
    # Blow the stack with a sparse array that is sufficiently large to cause int overflow
    shouldThrow "myFunction.apply(null, new Array(1 << 30))"
  return
description "This tests that we can correctly call Function.prototype.apply"
myObject = apply: ->
  [
    myObject
    "myObject.apply"
  ]

myFunction = (arg1) ->
  [
    this
    "myFunction"
    arg1
  ]

myFunctionWithApply = (arg1) ->
  [
    this
    "myFunctionWithApply"
    arg1
  ]

myFunctionWithApply.apply = (arg1) ->
  [
    this
    "myFunctionWithApply.apply"
    arg1
  ]

Function::aliasedApply = Function::apply
arg1Array = ["arg1"]
shouldBe "myObject.apply()", "[myObject, \"myObject.apply\"]"
shouldBe "forwarder(myObject)", "[myObject, \"myObject.apply\"]"
shouldBe "myFunction('arg1')", "[this, \"myFunction\", \"arg1\"]"
shouldBe "forwarder(myFunction, null, ['arg1'])", "[this, \"myFunction\", \"arg1\"]"
shouldBe "myFunction.apply(myObject, ['arg1'])", "[myObject, \"myFunction\", \"arg1\"]"
shouldBe "myFunction.apply(myObject, arg1Array)", "[myObject, \"myFunction\", \"arg1\"]"
shouldBe "forwarder(myFunction, myObject, arg1Array)", "[myObject, \"myFunction\", \"arg1\"]"
shouldBe "myFunction.apply()", "[this, \"myFunction\", undefined]"
shouldBe "myFunction.apply(null)", "[this, \"myFunction\", undefined]"
shouldBe "myFunction.apply(undefined)", "[this, \"myFunction\", undefined]"
shouldBe "myFunction.aliasedApply(myObject, ['arg1'])", "[myObject, \"myFunction\", \"arg1\"]"
shouldBe "myFunction.aliasedApply()", "[this, \"myFunction\", undefined]"
shouldBe "myFunction.aliasedApply(null)", "[this, \"myFunction\", undefined]"
shouldBe "myFunction.aliasedApply(undefined)", "[this, \"myFunction\", undefined]"
shouldBe "myFunctionWithApply.apply(myObject, ['arg1'])", "[myFunctionWithApply, \"myFunctionWithApply.apply\", myObject]"
shouldBe "myFunctionWithApply.aliasedApply(myObject, ['arg1'])", "[myObject, \"myFunctionWithApply\", \"arg1\"]"
shouldBe "myFunctionWithApply.apply(myObject, arg1Array)", "[myFunctionWithApply, \"myFunctionWithApply.apply\", myObject]"
shouldBe "forwarder(myFunctionWithApply, myObject, arg1Array)", "[myFunctionWithApply, \"myFunctionWithApply.apply\", myObject]"
shouldBe "myFunctionWithApply.aliasedApply(myObject, arg1Array)", "[myObject, \"myFunctionWithApply\", \"arg1\"]"
stackOverflowTest()

# Blow the stack recursing with arguments
shouldThrow "recurseArguments.apply(null, new Array(50000))"
