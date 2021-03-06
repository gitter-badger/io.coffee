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
baz = ->
  
  # Do something that prevents inlining.
  ->
stuff = (z) ->
foo = (x, y) ->
  a = arguments # Force arguments to be captured, so that x is captured.
  baz()
  z = x
  stuff z # Force a Flush, and then a Phantom on the GetLocal of x.
  42
thingy = (o) ->
  p = {}
  result = undefined
  
  # Trick to delay control flow graph simplification until after the flush of x above gets turned into a phantom.
  p.f = true  if o.g
  
  # Basic block that stores to x in foo(), which is a captured variable, with
  # the predecessor block making no mention of x.
  result = foo("hello", 2)  if p.f
  result
description "Tests that attempts by the DFG simplification to short-circuit a Phantom to a GetLocal on a variable that is SetLocal'd in the same block, and where the predecessor block(s) make no mention of that variable, do not result in crashes."
o = g: (x) ->

i = 0

while i < 200
  shouldBe "thingy(o)", "42"
  ++i
