# Copyright 2013 the V8 project authors. All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of Google Inc. nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
install = (name, value) ->
  Realm.shared[name] = value
  for i of realms
    Realm.eval realms[i], name + " = Realm.shared['" + name + "'];"
  return
realms = [
  Realm.current()
  Realm.create()
]
globals = [
  Realm.global(0)
  Realm.global(1)
]
Realm.shared = {}
install "return_this", ->
  this

install "return_this_strict", ->
  "use strict"
  this


# test behaviour of 'with' scope
for i of realms
  Realm.shared.results = []
  
  # in the second case, 'this' is found in the with scope,
  # so the receiver is 'this'
  Realm.eval realms[i], "                                                             with('irrelevant') {                                                             Realm.shared.results.push(return_this());                                      Realm.shared.results.push(return_this_strict());                             }                                                                              with(this) {                                                                     Realm.shared.results.push(return_this());                                      Realm.shared.results.push(return_this_strict());                             }                                                                            "
  assertSame globals[0], Realm.shared.results[0]
  assertSame `undefined`, Realm.shared.results[1]
  assertSame globals[i], Realm.shared.results[2]
  assertSame globals[i], Realm.shared.results[3]

# test 'apply' and 'call'
for i of realms
  
  # 'apply' without a receiver is a contextual call
  assertSame globals[0], Realm.eval(realms[i], "return_this.apply()")
  assertSame `undefined`, Realm.eval(realms[i], "return_this_strict.apply()")
  assertSame globals[0], Realm.eval(realms[i], "return_this.apply(null)")
  assertSame null, Realm.eval(realms[i], "return_this_strict.apply(null)")
  
  # 'call' without a receiver is a contextual call
  assertSame globals[0], Realm.eval(realms[i], "return_this.call()")
  assertSame `undefined`, Realm.eval(realms[i], "return_this_strict.call()")
  assertSame globals[0], Realm.eval(realms[i], "return_this.call(null)")
  assertSame null, Realm.eval(realms[i], "return_this_strict.call(null)")

# test ics
i = 0

while i < 4
  assertSame globals[0], return_this()
  assertSame `undefined`, return_this_strict()
  i++

# BUG(1547)
Realm.eval realms[0], "var name = 'o'"
Realm.eval realms[1], "var name = 'i'"
install "f", ->
  @name

install "g", ->
  "use strict"
  (if this then @name else "u")

for i of realms
  result = Realm.eval(realms[i], "                                                   (function(){return f();})() +                                                  (function(){return (1,f)();})() +                                              (function(){'use strict'; return f();})() +                                    (function(){'use strict'; return (1,f)();})() +                                (function(){return g();})() +                                                  (function(){return (1,g)();})() +                                              (function(){'use strict'; return g();})() +                                    (function(){'use strict'; return (1,g)();})();                               ")
  assertSame "oooouuuu", result
