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

wlog.set_level(wlog.levels.TRACE)

wlog.INFO("Testing classic module")

classic.addCallback(classic.events.CLASS_INIT, function(name)
  wlog.DEBUG("A class was defined: "..name)
end)

classic.addCallback(classic.events.CLASS_SET_ATTRIBUTE, function(obj,attr_name,value)
  wlog.DEBUG("A class's attribute was set: ".. obj:name().."."..attr_name.." = "..tostring(value))
end)

classic.addCallback(classic.events.CLASS_DEFINE_METHOD, function(c,m,v)
  wlog.DEBUG("A class's method was set: "..c:name()..":"..tostring(m)..":"..tostring(v))
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

-- local a = A() -- error essentialmethod not implemented
print("A.myStaticMethod(): "..A.myStaticMethod())


wlog.TRACE("Creating B class")
local B,super = classic.class("B", A)
function B:_init(y)
  wlog.DEBUG("Iitializing B class")
  super._init(self) -- call the superconstructor, *passing in self*
  self._y = assert(y)
  self.p  = assert(y)
end
B._h = "hello"
B.w = "world"
B._z = "hello world"
function B:getY()
  return self._y
end
function B:getZ()
  return self._z
end

function B:_getYY()
  return self._y .. self._y
end

function B:essentialMethod()
  print("B:super().myFinalMethod(): "..B:super().myFinalMethod())
  return 2
end
B:final("essentialMethod")

-- OK: method is implemented.
local b = B("B")
b._y = 234

print("b:essentialMethod: "..b:essentialMethod())
print("b:getResult: "..b:getResult())
print("b:getX: "..b:getX())
print("b.p: "..b.p)
print("b._y: "..b._y)
print("b:getY: "..b:getY())
print("b:getZ: "..b:getZ())
print("b:_getYY: "..b:_getYY())
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

wlog.TRACE("Creating F class")
local F = classic.class("F",A)
function F:essentialMethod()
  print("F:super().myFinalMethod(): "..F:super().myFinalMethod())
  return 7
end
function F:_sayCiao()
  print("F:_sayCiao(): ciao")
end
local f = F()
-- local yy = f:_getYY() -- error - cannot call the private method _getYY() of A
f:_sayCiao() -- can call private methods :(

wlog.TRACE("Creating G class")
local G = classic.class("G")
function G:_init(attrs)
    wlog.DEBUG("G:_init: "..tostring(attrs))
    assert(attrs == nil or type(attrs)=="table","Wrong constructor")
    -- init private attributes
    for k,v in pairs(attrs or {}) do
        wlog.DEBUG("G:_init init attr: ",k,v)
        if string.sub(k,1,1) == "_" then
            rawset(self,"_"..k,v)
            -- init private attr
            wlog.DEBUG("G: creating function: get"..k.."()")
            rawset(self,"get"..k,function () 
                wlog.DEBUG("G:_init getting attr: "..k)
                return rawget(self,"_"..k); 
            end)
            wlog.DEBUG("G: creating function: set"..k.."(val)")
            rawset(self,"set"..k,function (val) 
                wlog.DEBUG("G:_init setting attr: "..k.." to "..tostring(val))
                rawset(self,"_"..k,val) 
            end)
        else
            rawset(self,k,v)
        end
    end
end
function G:__index(attr)
    wlog.DEBUG("G:__index: "..tostring(attr))
    assert(type(attr)=="string")
    assert(string.sub(attr,1,1) ~= "_","Cannot access private attributes")
    return rawget(self,attr)
end
function G:__newindex(attr,value)
    wlog.DEBUG("G:__newindex: "..tostring(attr).." = "..tostring(value))
    assert(type(attr)=="string")
    assert(string.sub(attr,1,1) ~= "_","Cannot access private attributes")
    rawset(self,attr,value)
end
function G:__call(attrs)
    wlog.DEBUG("G:__call: "..tostring(attrs))
end
function G:_sayCiao()
  print("G:_sayCiao(): ciao")
end
G.info = "G class" -- class attribute
local g = G{
    a = 1,
    k = 11,
    _v = 25,
}
g.k = 13 -- set public attribute

print("g.k:        "..g.k)
print("g._v:       -- error, setting private attribute")
-- g._v = 28
-- g._t = 28
print("g.get_v():  "..g.get_v().." -- accessed _v private attribute")
g.set_v(14)
print("g.get_v():  "..g.get_v().." -- accessed _v private attribute")
wlog.TRACE( "g: "..tostring(g) )
g._sayCiao()
print("G.info: "..G.info.." -- class attribute")

wlog.TRACE("Creating H class")
local H,super = classic.class("H", G)
function H:_init(cfg)
    wlog.DEBUG("Iitializing H class")
	super._init(self,cfg)
end
local h = H{
    q = 1,
    p = 11,
    _s = 25,
}
print("h.q:        "..h.q)
print("h._s:       -- error, setting private attribute")
print("h.get_s():  "..h.get_s().." -- accessed _s private attribute")
h.set_s(23)
print("h.get_s():  "..h.get_s().." -- accessed _v private attribute")
wlog.TRACE( "h: "..tostring(h) )
h._sayCiao() -- calling method of super class
print("H.info:     -- error class attributes are not inherithed")


wlog.DEBUG("classic: "..tostring(classic))

wlog.INFO("End of classic module test")
