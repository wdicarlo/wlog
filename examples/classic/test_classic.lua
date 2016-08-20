local wlog = require"wlog"

local classic = require 'classic'

wlog.set_level(wlog.levels.DEBUG)

wlog.INFO("Testing classic module")

wlog.TRACE("Creating A class")
local A = classic.class("A")

A:mustHave("essentialMethod")

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
  return 2
end
B:final("essentialMethod")

-- OK: method is implemented.
local b = B("B")

print("b:essentialMethod: "..b:essentialMethod())
print("b:getResult: "..b:getResult())
print("b:getX: "..b:getX())
print("b:getY: "..b:getY())

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
print(d:class():methods())


wlog.INFO("End of classic module test")
