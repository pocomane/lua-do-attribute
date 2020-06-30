
print("testing do-attribute patch")

local f, e

-- Proper attributes for do/local
f,e= load[[ local a <localonly> = loccall("BAD") ]] -- compile error: do attribute can no be used in a local
assert(e:match('unknown attribute'))
f,e= load[[ local a <autoglobal> = loccall("BAD") ]] -- compile error: do attribute can no be used in a local
assert(e:match('unknown attribute'))
f,e= load[[ local a <withupvalue> = loccall("BAD") ]] -- compile error: do attribute can no be used in a local
assert(e:match('unknown attribute'))
f,e= load[[ local a <defer> = loccall("BAD") ]] -- compile error: do attribute can no be used in a local
assert(e:match('unknown attribute'))
f,e= load[[ do <const> loccall("BAD") end ]] -- compile error: local attribute can no be used in a do
assert(e:match('unknown attribute'))
f,e= load[[ do <close> loccall("BAD") end ]] -- compile error: local attribute can no be used in a do
assert(e:match('unknown attribute'))

-- VISIBILITY 

glocall = function(...) end
local loccall = glocall

-- toplevel works as usual
glocall("ok")

-- clean do block works as usual
do
  glocall("ok")
end

-- "Hide the globals" block
do <withupvalue>
  loccall("ok") -- ok: loccall is local
 _ENV.glocall("ok") -- ok: _ENV is an upvalue
end
f,e= load[[ do <withupvalue> glocall("BAD") end ]] -- compile error: glocall is global
assert(e:match('free name found in a protected block near'))

-- "Hide all" block
do <localonly>
  loccall("ok") -- ok: loccall is local
end
f,e= load[[ do <localonly> _ENV.glocall("BAD") end ]] -- compile error: _ENV is an upvalue
assert(e:match('non local name in a protected block near'))
f,e= load[[ do <localonly> glocall("BAD") end ]] -- compile error: glocall is global
assert(e:match('non local name in a protected block near'))

-- "Hide all" blocks in functios
;(function()
  local yacall = glocall
  do <localonly>
    yacall("ok") -- ok: yacall is local here
  end
end)();
f,e= load[[
  local function yacall(...) end
  ;(function() do <localonly>
    yacall("BAD") -- compile error: here yacall is an upvalue
  end end)();
]]
assert(e:match('non local name in a protected block near'))

-- _ENV workaround
do
  local _ENV = _ENV
  do <localonly>
    _ENV.glocall"ok" -- ok: _ENV is local
  end
end
 
-- Restore old beviour outside the block
loccall("ok") -- ok: loccall is local
_ENV.glocall("ok") -- ok: _ENV is an upvalue
glocall("ok") -- ok: glocall is global

-- force default behaviour
do <autoglobal>
  loccall("ok") -- ok: loccall is local
  _ENV.glocall("ok") -- ok: _ENV is an upvalue
  glocall("ok") -- ok: glocall is global
end
 
-- inherit beaviour
f,e= load[[
  do <localonly>
    do
      _ENV.glocall("BAD") -- error: _ENV is upvalue
    end
  end
]]
assert(e:match('non local name in a protected block near'))

-- restore default form in a nested block
do <localonly>
  do <autoglobal>
    loccall("ok") -- ok: loccall is local
    _ENV.glocall("ok") -- ok: _ENV is an upvalue
    glocall("ok") -- ok: glocall is global
  end
end

-- DEFER

local app_check = ''
local function app(...)
  for k, a in ipairs{...} do
    if k ~= 1 then app_check = app_check .. ' ' end
    app_check = app_check .. a
  end
  app_check = app_check .. '\n'
end
local function check(str)
  if app_check ~= str then
    print(string.format("%q",str):gsub('\n','\\n'))
    print('------------ vs -----------')
    print(string.format("%q",app_check):gsub('\n','\\n'))
  end
  assert(app_check == str)
  app_check = ''
end

-- defer blocks are called at end of the scope
for i = 1, 100 do
  do
    do <defer> app'b' end
    app'a'
  end
  app'c'
  check'a\nb\nc\n'
end

-- defer blocks are called in reverse order
for i = 1, 100 do
  do
    do <defer> app'd' end
    do <defer> app'c' end
    app'a'
    app'b'
  end
  app'e'
  check'a\nb\nc\nd\ne\n'
end

-- defer in functions
for i = 1, 100 do
  ;(function()
    do <defer> app'b' end
    app'a'
  end)();
  app'c'
  check'a\nb\nc\n'
end

-- defer and order of locals
for i = 1, 100 do
  do
    local d = 'd'
    do <defer> app(d) end
    local c = 'c'
    do <defer> app(c) end
    local c = 'b'
    do <defer> app(c) end
    app'a'
  end
  app'e'
  check'a\nb\nc\nd\ne\n'
end

-- nested defer
for i = 1, 100 do
  do
    do <defer>
      do <defer>
        app'd'
      end
      app'c'
    end
    do <defer> app'b' end
    app'a'
  end
  app'e'
  check'a\nb\nc\nd\ne\n'
end

-- DEFER complex - todo : split in multiple simpler ones ?

app[[M 2]]
function close(x)
  local m = getmetatable(x)
  if m then m = m.__close end
  if not m then error("tying to close a non-closeable value") end
  m(x)
end
do
  local x = setmetatable({},{__close=function() app'yhea' end})
  do<defer>close(x)end
  local y = {}
  -- do<defer>close(y)end

  local function i()
    app[[u]]
    if true then
      local bb <close> = defer(function() app[[B]] end)
      do<defer> app[[b]] end
    end
    app[[y]]
  end
  i()i()i()

  do
    local function j()
      local x <close> = setmetatable({},{__close=function() app'x<close>called' end})
      return x
    end
    local x <close> = j()
  end
end

check[[
M 2
u
b
B
y
u
b
B
y
u
b
B
y
x<close>called
x<close>called
yhea
]]


print('OK')
