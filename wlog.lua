-- =====================================================
-- wlog:   an example of lua logger
--
-- author: di carlo walter
-- 
-- date:   june 2016
-- =====================================================

local wlog = {}


local  LOG_LEVEL_NONE   =  0
local  LOG_LEVEL_INFO   =  1
local  LOG_LEVEL_TRACE  =  2
local  LOG_LEVEL_DEBUG  =  3


wlog.level = LOG_LEVEL_INFO

local mod1 = "mod1"
local mod2 = "mod2"
local mod3 = "mod3"


local level_check = function (level)
    local ref_level = level
    return function ()
        return wlog.level >= ref_level
    end
end

wlog.INFO = level_check(LOG_LEVEL_INFO)
wlog.TRACE = level_check(LOG_LEVEL_TRACE)
wlog.DEBUG = level_check(LOG_LEVEL_DEBUG)

local con = function (module,txt)
    return function(txt)
        if txt and type(txt) == "string" then
            print(module..".con: "..txt)
        end
    end
end
local ram = function (module,txt)
    return function(txt)
        if txt and type(txt) == "string" then
            print(module..".ram: "..txt)
        end
    end
end


local writers = function(module,writer)
    local w = {}
    if writer then
        w.con = writer(module)
        w.ram = writer(module)
    else
        w.con = con(module)
        w.ram = ram(module)
    end
    return w
end

wlog.writers = writers

wlog.con = con
wlog.ram = ram


wlog.mod1 = writers(mod1)
wlog.mod2 = writers(mod2)

wlog.LOG_LEVEL_NONE   =  LOG_LEVEL_NONE
wlog.LOG_LEVEL_INFO   =  LOG_LEVEL_INFO
wlog.LOG_LEVEL_TRACE  =  LOG_LEVEL_TRACE
wlog.LOG_LEVEL_DEBUG  =  LOG_LEVEL_DEBUG

local modules = {}
modules.mod1 = mod1
modules.mod2 = mod2

wlog.modules = modules

return wlog


