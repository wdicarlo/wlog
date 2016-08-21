local wlog = require"wlog"

local classic = require 'classic'

local function prequire(m) 
  local ok, res = pcall(require, m) 
  if not ok then return nil, res end -- return error
  return res
end

local inspect = prequire("inspect")

local tostring = inspect and function (arg)
    if type(arg) == "table" then return inspect(arg) end
    return tostring(arg)
end or tostring

wlog.set_level(wlog.levels.DEBUG)

wlog.INFO("Testing classic module")

classic.addCallback(classic.events.CLASS_INIT, function(name)
  wlog.DEBUG("A class was defined: "..name)
end)

classic.addCallback(classic.events.CLASS_SET_ATTRIBUTE, function(obj,attr_name,value)
  wlog.DEBUG("A class's attribute was set: ".. obj:class():name().."."..attr_name.." = "..tostring(value))
end)

wlog.TRACE("Creating A class")
local A = classic.class("A")

A:mustHave("essentialMethod")

-- static method
function A.static.myStaticMethod()
  return 123
end
function A:getResult()
  return self:essentialMethod() + 1
end
function A:_init()
  wlog.DEBUG("Iitializing A class")
  self._x = "A"
end

function A:getX()
  return self._x
end
function A:setX(x)
  self._x = x
  return self._x
end
function A:myFinalMethod()
  return "hello world"
end

A:final("myFinalMethod")

wlog.TRACE("Creating B class")
local B,super = classic.class("B", A)
function B:_init(y)
  wlog.DEBUG("Iitializing B class")
  super._init(self) -- call the superconstructor, *passing in self*
  self._y = assert(y)
end

function B:getY()
  return self._y
end

function B:essentialMethod()
  print("B:super().myFinalMethod(): "..B:super().myFinalMethod())
  return 2
end
B:final("essentialMethod")

-- OK: method is implemented.
local b = B("B")

print("A.myStaticMethod(): "..A.myStaticMethod())
print("b:essentialMethod: "..b:essentialMethod())
print("b:getResult: "..b:getResult())
print("b:getX: "..b:getX())
print("b:getY: "..b:getY())
print("b:setX(9): "..b:setX(9))
print("b:getX: "..b:getX())
--print("B.myStaticMethod(): "..B.myStaticMethod()) -- error
print("B:name(): "..tostring(B:name()))
print("B:parent():name(): "..tostring(B:parent():name()))
print("B:isClassOf(b): "..tostring(B:isClassOf(b)))
print("A:isClassOf(b): "..tostring(A:isClassOf(b)))
print("B:isSubclassOf(A): "..tostring(B:isSubclassOf(A)))

wlog.TRACE("Creating C class")
local C = classic.class("C", A)
-- Error: 'essentialMethod' is marked 'mustHave' but was not implemented.
--local c = C()
function C:essentialMethod()
  return 4
end

local c = C()
print("c:essentialMethod: "..c:essentialMethod())
print("c:getResult: "..c:getResult())


wlog.TRACE("Creating D class")
local D,super = classic.class("D",B)
function D:_init()
    wlog.DEBUG("Iitializing D class")
	super._init(self,"D")
end
local d = D()
-- Error: Attempted to define method 'essentialMethod' in class 'D', but 'essentialMethod' is marked as final.
--print("d:essentialMethod: "..d:essentialMethod())
--function D:essentialMethod()
--	return 5
--end
print("d:getResult: "..d:getResult())
print("d:getX: "..d:getX())
print("d:getY: "..d:getY())

print(d:class():name())
print(tostring(d:class():methods()))

wlog.TRACE("Creating E class")
local E = classic.class("E")
E:include(D) -- mixin
function E:sayHello()
  return "hello"
end
local e = E()
print("e:getResult: "..e:getResult())
print("e:getX: "     ..e:getX())
print("e:getY: "     ..e:getY())
print("e:sayHello: "     ..e:sayHello())

print(e:class():name())
print(tostring(e:class():methods()))


wlog.DEBUG("classic: "..tostring(classic))

wlog.INFO("End of classic module test")
