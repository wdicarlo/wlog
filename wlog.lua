-- =====================================================
-- wlog:   an example of lua logger
--
-- author: di carlo walter
-- 
-- date:   june 2016
-- =====================================================

local core = require"wlog.core"
local rollfile = require"wlog_rollfile"

local openRollingFileLogger = rollfile.openRollingFileLogger

local wlog = {}

local function set_level(level)
    wlog.level = level
    for k,v in pairs(core.enums.WLOG_LEVELS)
    do
        local lvl = string.sub(k,5)
        _G[lvl] = wlog[lvl] <= wlog.level
    end
end

for k,v in pairs(core.enums.WLOG_LEVELS)
do
    local lvl = string.sub(k,5)
    wlog[lvl] = v
end

set_level(wlog.INFO)


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


local sto = function (module,txt)
    return function(txt)
        local f, err = openRollingFileLogger(rollfile.config)
        if not f then
            print("ERROR: "..err)
            return nil
        end
        if txt and type(txt) == "string" then
            f:write(txt.."\n")
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
wlog.sto = sto

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
wlog.set_level = set_level

return wlog


