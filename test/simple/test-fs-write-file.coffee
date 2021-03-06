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
common = require("../common")
assert = require("assert")
fs = require("fs")
join = require("path").join
filename = join(common.tmpDir, "test.txt")
common.error "writing to " + filename
n = 220
s = "南越国是前203年至前111年存在于岭南地区的一个国家，国都位于番禺，疆域包括今天中国的广东、" + "广西两省区的大部份地区，福建省、湖南、贵州、云南的一小部份地区和越南的北部。" + "南越国是秦朝灭亡后，由南海郡尉赵佗于前203年起兵兼并桂林郡和象郡后建立。" + "前196年和前179年，南越国曾先后两次名义上臣属于西汉，成为西汉的“外臣”。前112年，" + "南越国末代君主赵建德与西汉发生战争，被汉武帝于前111年所灭。南越国共存在93年，" + "历经五代君主。南越国是岭南地区的第一个有记载的政权国家，采用封建制和郡县制并存的制度，" + "它的建立保证了秦末乱世岭南地区社会秩序的稳定，有效的改善了岭南地区落后的政治、##济现状。\n"
ncallbacks = 0
fs.writeFile filename, s, (e) ->
  throw e  if e
  ncallbacks++
  common.error "file written"
  fs.readFile filename, (e, buffer) ->
    throw e  if e
    common.error "file read"
    ncallbacks++
    assert.equal Buffer.byteLength(s), buffer.length
    return

  return


# test that writeFile accepts buffers
filename2 = join(common.tmpDir, "test2.txt")
buf = new Buffer(s, "utf8")
common.error "writing to " + filename2
fs.writeFile filename2, buf, (e) ->
  throw e  if e
  ncallbacks++
  common.error "file2 written"
  fs.readFile filename2, (e, buffer) ->
    throw e  if e
    common.error "file2 read"
    ncallbacks++
    assert.equal buf.length, buffer.length
    return

  return


# test that writeFile accepts numbers.
filename3 = join(common.tmpDir, "test3.txt")
common.error "writing to " + filename3
m = 0600
fs.writeFile filename3, n,
  mode: m
, (e) ->
  throw e  if e
  
  # windows permissions aren't unix
  if process.platform isnt "win32"
    st = fs.statSync(filename3)
    assert.equal st.mode & 0700, m
  ncallbacks++
  common.error "file3 written"
  fs.readFile filename3, (e, buffer) ->
    throw e  if e
    common.error "file3 read"
    ncallbacks++
    assert.equal Buffer.byteLength("" + n), buffer.length
    return

  return

process.on "exit", ->
  common.error "done"
  assert.equal 6, ncallbacks
  fs.unlinkSync filename
  fs.unlinkSync filename2
  fs.unlinkSync filename3
  return

