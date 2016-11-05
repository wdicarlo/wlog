


local mock_plugin = {
    is_wlog_plugin = true,
    wlog_plugin_name = "mock plugin",
}


local   enums = {
    WLOG_LEVELS = {
        LOG_FATAL    =  1,
        LOG_ERROR    =  2,
        LOG_WARNING  =  3,
        LOG_INFO     =  4,
        LOG_TRACE    =  5,
        LOG_DEBUG    =  6,
    },
    WLOG_FUNCTS = {
        LOG_GEN = 1,
        LOG_SYS = 2,
        LOG_SQL = 3,
        LOG_GUI = 4,
    }
}

local defaults = {
    module = "GEN",
    level  = "WARNING",
    writer = "ram",
}

local fromlevel = function (level)
    assert(type(level)=="string","Wrong level")
    if level=="LOG_FATAL" then return "CRIT" end
    return string.sub(level,5)

end

local tolevel = function (level)
    assert(type(level)=="string","Wrong level")
    if level == "CRIT" then return "LOG_FATAL" end
    return "LOG_"..level
end

local con = function (txt)
    if txt and type(txt) == "string" then
        print("pcon: "..txt) -- just proof its usage
    end
end
local ram = function (txt)
    if txt and type(txt) == "string" then
        print("pram: "..txt) -- just proof its usage
    end
end

-- plugin setup
local _wlog = nil
local setup = function (wlog)
    assert(type(wlog)=="table","Wrong wlog reference")
    -- TODO: add more assertion to make sure a ref to wlog is provided

    -- store a reference to the wlog
    _wlog = wlog
end


-- same as wlog.<def_mod>(<level>) and wlog<def_mod>()
local config = function(cfg)
    assert(_wlog,"Setup before config plugin")

    if cfg then
        assert(type(cfg) == "table","Wrong level: "..tostring(cfg))
        assert(cfg.name,"Missing level's name")
        assert(cfg.value,"Missing level's value")
        assert(enums.WLOG_LEVELS[cfg.name],"Unknown level")
        local tcfg = type(cfg)
        if tcfg == "table" then
            _wlog(cfg)
        end
    else
        return _wlog()
    end
end

-- compare current level with the level of the default module
local eval = function(module,level,tags,modules)
    if level.value > modules[defaults.module].level.value then
        local res = false
        if tags then
            for _,tag in ipairs(tags) do
                if modules[tag].level.value <= modules[defaults.module].level.value   then
                    res = true
                    break
                end
            end
        end
        if res == false then
            return false
        end
    end
    return true
end

mock_plugin.enums     =  enums
mock_plugin.defaults  =  defaults

mock_plugin.con       =  con
mock_plugin.ram       =  ram

mock_plugin.setup     =  setup
mock_plugin.config    =  config

mock_plugin.eval      =  eval

mock_plugin.fromlevel =  fromlevel
mock_plugin.tolevel   =  tolevel

return mock_plugin
