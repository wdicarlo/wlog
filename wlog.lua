-- =====================================================
-- wlog:   an example of lua logger
--
-- author: di carlo walter
-- 
-- date:   june 2016
-- =====================================================

local core = require"wlog.core"

local wlog = {}


local level_mt ={
    __call = function (...)
        return arg[1].level <= wlog.level.level
    end
}

local levels = {}
for k,v in pairs(core.enums.WLOG_LEVELS)
do
    local lvl = string.sub(k,5)
    levels[lvl] = {
        level = v
    }
end
wlog.level = levels.INFO
for k,v in pairs(core.enums.WLOG_LEVELS)
do
    local lvl = string.sub(k,5)
    setmetatable(levels[lvl],level_mt)
    wlog[lvl] = levels[lvl]
end


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


for k,v in pairs(core.enums.WLOG_FUNCTS)
do
    local mod = string.sub(k,5)
    wlog[mod] = writers(mod)
end


local modules = {}
for k,v in pairs(core.enums.WLOG_FUNCTS)
do
    local mod = string.sub(k,5)
    modules[mod] = mod
end

wlog.modules = modules

wlog.demo = core.demo
wlog.enums = core.enums
wlog.levels = levels

return wlog


