# Copyright 2009 the V8 project authors. All rights reserved.
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

# Load Splay tree and CodeMap implementations from <project root>/tools.
# Files: tools/splaytree.js tools/codemap.js
newCodeEntry = (size, name) ->
  new CodeMap.CodeEntry(size, name)
assertEntry = (codeMap, expected_name, addr) ->
  entry = codeMap.findEntry(addr)
  assertNotNull entry, "no entry at " + addr.toString(16)
  assertEquals expected_name, entry.name, "at " + addr.toString(16)
  return
assertNoEntry = (codeMap, addr) ->
  assertNull codeMap.findEntry(addr), "at " + addr.toString(16)
  return
(testLibrariesAndStaticCode = ->
  codeMap = new CodeMap()
  codeMap.addLibrary 0x1500, newCodeEntry(0x3000, "lib1")
  codeMap.addLibrary 0x15500, newCodeEntry(0x5000, "lib2")
  codeMap.addLibrary 0x155500, newCodeEntry(0x10000, "lib3")
  assertNoEntry codeMap, 0
  assertNoEntry codeMap, 0x1500 - 1
  assertEntry codeMap, "lib1", 0x1500
  assertEntry codeMap, "lib1", 0x1500 + 0x100
  assertEntry codeMap, "lib1", 0x1500 + 0x1000
  assertEntry codeMap, "lib1", 0x1500 + 0x3000 - 1
  assertNoEntry codeMap, 0x1500 + 0x3000
  assertNoEntry codeMap, 0x15500 - 1
  assertEntry codeMap, "lib2", 0x15500
  assertEntry codeMap, "lib2", 0x15500 + 0x100
  assertEntry codeMap, "lib2", 0x15500 + 0x1000
  assertEntry codeMap, "lib2", 0x15500 + 0x5000 - 1
  assertNoEntry codeMap, 0x15500 + 0x5000
  assertNoEntry codeMap, 0x155500 - 1
  assertEntry codeMap, "lib3", 0x155500
  assertEntry codeMap, "lib3", 0x155500 + 0x100
  assertEntry codeMap, "lib3", 0x155500 + 0x1000
  assertEntry codeMap, "lib3", 0x155500 + 0x10000 - 1
  assertNoEntry codeMap, 0x155500 + 0x10000
  assertNoEntry codeMap, 0xffffffff
  codeMap.addStaticCode 0x1510, newCodeEntry(0x30, "lib1-f1")
  codeMap.addStaticCode 0x1600, newCodeEntry(0x50, "lib1-f2")
  codeMap.addStaticCode 0x15520, newCodeEntry(0x100, "lib2-f1")
  assertEntry codeMap, "lib1", 0x1500
  assertEntry codeMap, "lib1", 0x1510 - 1
  assertEntry codeMap, "lib1-f1", 0x1510
  assertEntry codeMap, "lib1-f1", 0x1510 + 0x15
  assertEntry codeMap, "lib1-f1", 0x1510 + 0x30 - 1
  assertEntry codeMap, "lib1", 0x1510 + 0x30
  assertEntry codeMap, "lib1", 0x1600 - 1
  assertEntry codeMap, "lib1-f2", 0x1600
  assertEntry codeMap, "lib1-f2", 0x1600 + 0x30
  assertEntry codeMap, "lib1-f2", 0x1600 + 0x50 - 1
  assertEntry codeMap, "lib1", 0x1600 + 0x50
  assertEntry codeMap, "lib2", 0x15500
  assertEntry codeMap, "lib2", 0x15520 - 1
  assertEntry codeMap, "lib2-f1", 0x15520
  assertEntry codeMap, "lib2-f1", 0x15520 + 0x80
  assertEntry codeMap, "lib2-f1", 0x15520 + 0x100 - 1
  assertEntry codeMap, "lib2", 0x15520 + 0x100
  return
)()
(testDynamicCode = ->
  codeMap = new CodeMap()
  codeMap.addCode 0x1500, newCodeEntry(0x200, "code1")
  codeMap.addCode 0x1700, newCodeEntry(0x100, "code2")
  codeMap.addCode 0x1900, newCodeEntry(0x50, "code3")
  codeMap.addCode 0x1950, newCodeEntry(0x10, "code4")
  assertNoEntry codeMap, 0
  assertNoEntry codeMap, 0x1500 - 1
  assertEntry codeMap, "code1", 0x1500
  assertEntry codeMap, "code1", 0x1500 + 0x100
  assertEntry codeMap, "code1", 0x1500 + 0x200 - 1
  assertEntry codeMap, "code2", 0x1700
  assertEntry codeMap, "code2", 0x1700 + 0x50
  assertEntry codeMap, "code2", 0x1700 + 0x100 - 1
  assertNoEntry codeMap, 0x1700 + 0x100
  assertNoEntry codeMap, 0x1900 - 1
  assertEntry codeMap, "code3", 0x1900
  assertEntry codeMap, "code3", 0x1900 + 0x28
  assertEntry codeMap, "code4", 0x1950
  assertEntry codeMap, "code4", 0x1950 + 0x7
  assertEntry codeMap, "code4", 0x1950 + 0x10 - 1
  assertNoEntry codeMap, 0x1950 + 0x10
  assertNoEntry codeMap, 0xffffffff
  return
)()
(testCodeMovesAndDeletions = ->
  codeMap = new CodeMap()
  codeMap.addCode 0x1500, newCodeEntry(0x200, "code1")
  codeMap.addCode 0x1700, newCodeEntry(0x100, "code2")
  assertEntry codeMap, "code1", 0x1500
  assertEntry codeMap, "code2", 0x1700
  codeMap.moveCode 0x1500, 0x1800
  assertNoEntry codeMap, 0x1500
  assertEntry codeMap, "code2", 0x1700
  assertEntry codeMap, "code1", 0x1800
  codeMap.deleteCode 0x1700
  assertNoEntry codeMap, 0x1700
  assertEntry codeMap, "code1", 0x1800
  return
)()
(testDynamicNamesDuplicates = ->
  codeMap = new CodeMap()
  
  # Code entries with same names but different addresses.
  codeMap.addCode 0x1500, newCodeEntry(0x200, "code")
  codeMap.addCode 0x1700, newCodeEntry(0x100, "code")
  assertEntry codeMap, "code", 0x1500
  assertEntry codeMap, "code {1}", 0x1700
  
  # Test name stability.
  assertEntry codeMap, "code", 0x1500
  assertEntry codeMap, "code {1}", 0x1700
  return
)()
(testStaticEntriesExport = ->
  codeMap = new CodeMap()
  codeMap.addStaticCode 0x1500, newCodeEntry(0x3000, "lib1")
  codeMap.addStaticCode 0x15500, newCodeEntry(0x5000, "lib2")
  codeMap.addStaticCode 0x155500, newCodeEntry(0x10000, "lib3")
  allStatics = codeMap.getAllStaticEntries()
  allStatics = allStatics.map(String)
  allStatics.sort()
  assertEquals [
    "lib1: 3000"
    "lib2: 5000"
    "lib3: 10000"
  ], allStatics
  return
)()
(testDynamicEntriesExport = ->
  codeMap = new CodeMap()
  codeMap.addCode 0x1500, newCodeEntry(0x200, "code1")
  codeMap.addCode 0x1700, newCodeEntry(0x100, "code2")
  codeMap.addCode 0x1900, newCodeEntry(0x50, "code3")
  allDynamics = codeMap.getAllDynamicEntries()
  allDynamics = allDynamics.map(String)
  allDynamics.sort()
  assertEquals [
    "code1: 200"
    "code2: 100"
    "code3: 50"
  ], allDynamics
  codeMap.deleteCode 0x1700
  allDynamics2 = codeMap.getAllDynamicEntries()
  allDynamics2 = allDynamics2.map(String)
  allDynamics2.sort()
  assertEquals [
    "code1: 200"
    "code3: 50"
  ], allDynamics2
  codeMap.deleteCode 0x1500
  allDynamics3 = codeMap.getAllDynamicEntries()
  assertEquals ["code3: 50"], allDynamics3.map(String)
  return
)()
