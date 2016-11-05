-- =====================================================
-- wlog:   an example of lua logger
--
-- author: di carlo walter
--
-- date:   july/august 2016
--
-- wlog.set_level( <level> )                                                          -- set level of all modules to <level>
-- wlog.<mod>.<level> ( <msg> )                                                       -- log <msg> if <level> is active
-- wlog.<mod>.<level>.writer = wlog.writers.<writer>                                  -- set single writer
-- wlog.<mod>.<level>.writer = { wlog.writers.<writer1>, wlog.writers.<writer2>, ...} -- set group of writers
-- wlog.<mod>.<level> ( )                                                             -- true if <level> is active, otherwise false
-- wlog.<mod> ( <level> )                                                             -- set <mod>'s level to <level>
-- wlog.<mod> ( )                                                                     -- get <mod>'s level
-- wlog.<level> ()                                                                    -- is equivalent to wlog.GEN.<level> ()
-- wlog.<mod>.<level> ( wlog.<mod>.<level>() and <msg>  )                             -- log <msg> if <level> is active
-- wlog.<mod> ( wlog.<mod>.<level>() and <msg>  )                                     -- log <msg> if <level> is active
-- if wlog.<mod>.<level>() then wlog.<mod>(<msg1>); wlog.<mod>(<msg2>); end           -- log set of messages using contextual level
-- if wlog.<mod>.<level>{"tag1",...} then wlog.<mod>(<msg1>); wlog.<mod>(<msg2>); end -- log set of messages using contextual level
-- wlog.<mod> ( wlog.<mod>.<level>{"tag1",...} and <msg>  )                           -- log <msg> if <level> is active
-- wlog.<mod>.<level> ( msg, "tag" )                                                  .. single tag
-- wlog.<mod>.<level> ( msg, {"tag1","tag2", ...} )                                   -- tags in or expression
-- wlog.<mod>.<level> {"tag1","tag2", ...}                                            -- tags in or expression
-- wlog()                                                                             -- equivalent to wlog.GEN() which return level of GEN module
-- wlog(<level>)                                                                      -- equivalent to wlog.GEN(<level>)
-- wlog.tags{<tag1>,...}                                                              -- start logging section associated to <tag1>,...
-- wlog.tags()                                                                        -- get logging section's tags
-- wlog.tags{}                                                                        -- stop logging section with associated tags <tag1>,...
-- wlog.config{<config>}                                                              -- set configuration
-- wlog.config()                                                                      -- get configuration
-- wlog.plugin(<plugin>)                                                              -- set wlog plugin
-- wlog.fromlevel(<internal_level)                                                    -- get external representation of level
-- wlog.tolevel  (<external_level)                                                    -- get internal representation of level
-- wlog.frommodule(<internal_module)                                                  -- get external representation of module
-- wlog.tomodule  (<external_module)                                                  -- get internal representation of module
--
-- TODO:
-- wlog.<mod>.set_level ( level )
-- wlog.<mod>.<level> ( msg, "tag expression" )
-- wlog.<mod>.<level> { tags="tag expression", msg }
-- =====================================================

local ok,dbg = pcall(require,"debugger")
if not ok  then
    dbg = function() end 
end
dbg = function() end  -- disable debugger
local debug = false

local _plugin = nil

local function prequire(m) 
  local ok, res = pcall(require, m) 
  if not ok then return nil, res end -- return error
  return res
end

local core = prequire("wlog.core")
local inspect = prequire("inspect")

local tostring = inspect and function (arg)
    if type(arg) == "table" then return inspect(arg) end
    return tostring(arg)
end or tostring

if core == nil then
    core = {
        enums = {
            WLOG_LEVELS = {
                LOG_ERR    =  1,
                LOG_WARN   =  2,
                LOG_INFO   =  3,
                LOG_TRACE  =  4,
                LOG_DEBUG  =  5,
            },
            WLOG_FUNCTS = {
                LOG_GEN = 1,
                LOG_ALM = 2,
                LOG_SYS = 3,
                LOG_SQL = 4,
                LOG_GUI = 5,
                LOG_SRV = 6,
                LOG_WEB = 7,
            }
        }
    }
end

local defaults = {
    module = "GEN",
    level  = "INFO",
    writer = "con",
}


local wlog = {}
local ctags = {} -- contextual tags
local levels = {}
local modules = {}
local writers = {}



local function is_level( level )
    for k,v in pairs(levels) do
        if v == level then return true end
    end
    return false
end

local function is_module(module)
    return modules[module] ~= nil
end
local function add_module(module)
    assert(type(module) == "string")
    local max = 0
    for k,v in pairs(modules) do
        if k == module then
            return modules[module]
        end
        if v.id > max then max = v.id end
    end
    modules[module] = {
        id = max + 1,
        name = module
    }
    if debug then print("Added module: "..tostring(modules[module])) end
    return modules[module]
end

local fromlevel = function (level)
    assert(type(level)=="string","Wrong level")
    return string.sub(level,5)

end

local tolevel = function (level)
    assert(type(level)=="string","Wrong level")
    return "LOG_"..level
end

local frommodule = function (module)
    assert(type(module)=="string","Wrong module")
    return string.sub(module,5)

end

local tomodule = function (module)
    assert(type(module)=="string","Wrong module")
    return "LOG_"..module
end
local function is_in(tags,tag)
    assert(type(tags) == "table")
    assert(type(tag) == "string")
    for _,t in ipairs(tags) do
        if t == tag then return true end
    end
    return false
end

local con = function (txt)
    if txt and type(txt) == "string" then
        print("con: "..txt)
    end
end
local ram = function (txt)
    if txt and type(txt) == "string" then
        print("ram: "..txt)
    end
end

---------------------------------------------------------------------------
-- sto is a wlog writer that rolls over the logfile
-- once it has reached a certain size limit. It also mantains a
-- maximum number of log files.
--
-- sto is based on code present in the module rollfile
--
-- @author Tiago Cesar Katcipis (tiagokatcipis@gmail.com)
--
-- @copyright 2004-2013 Kepler Project
---------------------------------------------------------------------------
--

local rollfile = {
    config = {
        filename = "log.txt",
        maxSize = 50000,
        maxIndex = 5
    }
}

local function openFile(self)
    if self.file then
        return nil, string.format("file `%s' is already open", self.filename)
    end

    self.file = io.open(self.filename, "a")
    if not self.file then
        return nil, string.format("file `%s' could not be opened for writing", self.filename)
    end
    self.file:setvbuf ("line")
    return self.file
end

local rollOver = function (self)
    for i = self.maxIndex - 1, 1, -1 do
        -- files may not exist yet, lets ignore the possible errors.
        os.rename(self.filename.."."..i, self.filename.."."..i+1)
    end

    self.file:close()
    self.file = nil

    local _, msg = os.rename(self.filename, self.filename..".".."1")

    if msg then
        return nil, string.format("error %s on log rollover", msg)
    end

    return openFile(self)
end


local openRollingFileLogger = function (self)
    if not self.file then
        return openFile(self)
    end

    local filesize = self.file:seek("end", 0)

    if (filesize < self.maxSize) then
        return self.file
    end

    return rollOver(self)
end
local sto = function (txt)
    local f, err = openRollingFileLogger(rollfile.config)
    if not f then
        print("ERROR: "..err)
        return nil
    end
    if txt and type(txt) == "string" then
        f:write("sto: "..txt.."\n")
    end
end
---------------------------------------------------------------------------
--

local nul = function (txt)
end

local function is_writer(func)
    for name,writer in pairs(writers) do
        if func == writer then return true end
    end
    return false
end

local eval = function (module,level,tags,modules,context)
    if module.level.value >= level.value then
        local wrt = rawget(context,"_writer")
        return true, wrt
    end
    local res = false
    local writer = nil
    if tags then
        for _,tag in ipairs(tags) do
            -- if any tag has level lower than the current one then the text can be logged
            --if modules[tag].level.value <= module.level.value   then
            if modules[tag].level.value >= level.value   then
                res = true
                writer = rawget(context,"_writer")
                break
            end
        end
    end
    return res, writer
end

local level_mt = {
    __call = function(self,...)
        rawset(self.module,"_last",self.level)
        rawset(self.module,"_last_tags",nil)
        local n = select("#",...)
        if n == 0 then
            local eval_res, eval_writer =  eval(self.module,self.level,nil,wlog,self)
            return eval_res
        end
        local tags = nil
        local ntags = 0
        if n == 1 then
            local par = select(1,...)
            local tpar = type(par)
            if tpar == "table" then
                -- add modules
                ntags = 0
                tags = {}
                for _,tag in ipairs(par) do
                    if tags == nil then tags = {} end
                    add_module(tag)
                    if is_in(tags,tag) == false then
                        tags[#tags + 1] = tag
                        ntags = ntags + 1
                    end
                end
            end
        elseif n > 1 then
            tags = select(2,...)
            local ttags = type(tags)
            if ttags == "string" then
                -- add module
                ntags = 1
                add_module(tags)
                tags = { tags } -- put in an array
            elseif ttags == "table" then
                -- add modules
                ntags = 0
                for _,tag in ipairs(tags) do
                    add_module(tag)
                    ntags = ntags + 1
                end
            end
        end
        if ctags and #ctags > 0 then
            for _,tag in ipairs(ctags) do
                add_module(tag)
                if tags == nil then tags = {} end
                if is_in(tags,tag) == false then
                    tags[#tags + 1] = tag
                    ntags = ntags + 1
                end
            end
        end
        if tags then
            rawset(self.module,"_last_tags",tags)
        end
        -- evaluate status considering also the tags
        local eval_res, eval_writer = eval(self.module,self.level,tags,wlog,self) 
        if eval_res == false then 
            return false 
        end

        -- ok, the text can be logged
        local par = select(1,...)
        local tpar = type(par)
        if tpar == "string" then
            local msg = self.module.name..": level="..self.level.name.." msg="..par
            if ntags > 0 then
                for _,tag in ipairs(tags) do
                    msg = msg .. " #"..tag
                end
            end
            -- use writers of the module
            local writer = rawget(self,"_writer")
            local writer = eval_writer 
            if type(writer) == "function" then
                writer(msg)
            elseif type(writer) == "table" then
                for _,out in ipairs(writer) do
                    if out then out(msg)
                    end
                end
            end
            return true
        elseif tpar == "boolean" then
            return par
        elseif tpar == "table" and ntags > 0 then
            return true
        end
        return false
    end,
    __index = function(self,key)
        --assert(writers[key] or key == "writer","Wrong writer: "..key)

        if key == "writer" and rawget(self,"_writer") == nil then
            rawset(self,"_writer",writers[defaults.writer])
        end

        --return self._writer
        local writer = rawget(self,"_writer") -- self._writer
        if type(writer) == "table" then
            writer = writer[1]
        end
        return writer
    end,
    __newindex = function(self,key,val)
        assert(type(key)=="string","Wrong key: "..tostring(key))
        assert(key=="module" or key=="writer" or key=="level","Wrong key: "..tostring(key))
        --assert(val~=nil,"Wrong value: nil")
        if key=="writer" then
            local wt = type(val)
            --assert(wt=="function" or wt=="table")
            assert(wt=="function" or wt=="table" or wt=="nil")
            -- check it is a valid writer
            if wt == "function" then
                assert(is_writer(val),"Wrong writer")
            elseif wt == "table" then
                for _,w in ipairs(val) do
                    assert(type(w) == "function", "Wrong writer")
                    assert(is_writer(w), "Wrong writer")
                end
            --else
            --    assert(false,"Wrong writer type")
            end
            rawset(self,"_writer", val)
            return
        end

        if debug then print("key="..tostring(key).. " val="..tostring(val)) end


        rawset(self,key,val)
    end
}
local module_mt = {
    __call = function(self,...)
        local n = select("#",...)
        if debug then print("Module: "..self.name.." Level: "..tostring(self.level)) end
        if n == 0 then
            return self.level
        end
        local par = select(1,...)
        local tpar = type(par)
        if tpar == "table" then
            assert( is_level(par), "wrong level: "..tostring(par))
            self.level = par
        elseif tpar == "string" then
            -- message to log using the last level/tags
            local level = rawget(self,"_last")
            local tags = rawget(self,"_last_tags")
            if level == nil then return end -- no know message level

            local lvl = fromlevel(level.name)

            if tags then
                self[lvl](par,tags)
            else
                self[lvl](par)
            end
            return self.level
        end
    end,
    __index = function(self,key)
        assert(type(key)=="string","Wrong key type for: "..tostring(key))
        assert(levels[key]~=nil,"Wrong level: "..tostring(key))
        self[key] = setmetatable({}, level_mt)
        self[key].level = levels[key]
        --self[key].writer = writers[defaults.writer]
        self[key].writer = nil
        self[key].module = self
        return self[key]
    end,
}
local wlog_mt = {
    __call = function(self,...)
        local n = select("#",...)
        if n == 0 then
            return rawget(self[defaults.module],"level")
        end
        local par = select(1,...)
        return self[defaults.module](par)
    end,
    __index = function(self,key)
        assert(type(key)=="string","Wrong key type for: "..tostring(key))
        if is_module(key) == false then
            add_module(key)
        end
        self[key] = setmetatable({}, module_mt)
        self[key].level = levels[defaults.level]
        self[key].name = key
        self[key].id = modules[key]["id"]
        return self[key]
    end,
}

local function is_ctag(tag)
    for _,t in ipairs(ctags) do
        if t == tag then return true end
    end
    return false
end

local function tags(list)
    assert(list == nil or type(list)=="table","Wrong list of tags")
    if list == nil then
        return ctags
    end
    if #list == 0 then
        ctags = {}
        return ctags
    end
    -- check if list of modules need to be updated
    for _,tag in ipairs(list) do
        if is_ctag(tag) == false then 
            ctags[#ctags+1] = tag
        end
    end
end

local function set_level(level)
    assert(type(level) == "table","Wrong level: "..tostring(level))
    assert(level.name,"Missing level's name")
    assert(level.value,"Missing level's value")
    assert(core.enums.WLOG_LEVELS[level.name],"Unknown level")
    assert(core.enums.WLOG_LEVELS[level.name] == level.value,
        "Wrong level - expected "..core.enums.WLOG_LEVELS[level.name].." got "..level.value)

    rawset(wlog,"level",level)
    if debug then print("wlog.level = "..wlog.level.name) end
    for k,v in pairs(wlog.modules)
    do
        --local mod = frommodule(k)
        --if wlog[mod] then
        --    rawset(wlog[mod],"level",level)
        --end
        if wlog[k] then
            rawset(wlog[k],"level",level)
        end
    end
end

local _reset = function()
    ctags = {} -- contextual tags
    levels = {}
    modules = {}
    writers = {}
    for k,v in pairs(wlog) do
        if type(v) == "table" then
            rawset(wlog,k,nil)
        end
    end
end
local function _init_enums()
    -- levels defaults
    for k,v in pairs(core.enums.WLOG_LEVELS)
        do
            local lvl = fromlevel(k)
dbg("k = "..tostring(k).." lvl = "..tostring(lvl))
            levels[lvl] = {
                name = k,
                value = v,
            }
        end
    if debug then print("levels:\n",tostring(levels)) end
    -- modules defaults
    for k,v in pairs(core.enums.WLOG_FUNCTS)
        do
            local mod = frommodule(k)
            modules[mod] = {
                id = v,
                name = k
            }
        end
    if debug then print("modules:\n",tostring(modules)) end

end
local function _init_writers()
    writers.con = con
    writers.ram = ram
    writers.sto = sto
    writers.nul = nul
    if debug then print("writers:\n",tostring(writers)) end

end
local function plugin(wlog_plugin)
dbg("begin of wlog_plugin")
    if wlog_plugin == nil then return _plugin end

    assert(wlog_plugin and type(wlog_plugin)=="table","Wrong plugin")
    assert(wlog_plugin.is_wlog_plugin,"Wrong plugin")
    assert(wlog_plugin.wlog_plugin_name,"Wrong plugin")

    _reset()

    --if wlog_plugin.setup then wlog_plugin.setup(wlog) end

    if wlog_plugin.enums then
        assert(wlog_plugin.enums.WLOG_FUNCTS,"Wrong enums")
        assert(wlog_plugin.enums.WLOG_LEVELS,"Wrong enums")
        core.enums = wlog_plugin.enums
dbg("after enums setup")
    end

    if wlog_plugin.fromlevel  then fromlevel  = wlog_plugin.fromlevel end
    if wlog_plugin.tolevel    then tolevel    = wlog_plugin.tolevel end
    if wlog_plugin.frommodule then frommodule = wlog_plugin.frommodule end
    if wlog_plugin.tomodule   then tomodule   = wlog_plugin.tomodule end

    wlog.fromlevel    =           fromlevel
    wlog.tolevel      =           tolevel
    wlog.frommodule   =           frommodule
    wlog.tomodule     =           tomodule

dbg("before _init_enums")
    _init_enums()

dbg("before _init_writers")
    _init_writers()
    if wlog_plugin.con then writers.con = wlog_plugin.con end
    if wlog_plugin.ram then writers.ram = wlog_plugin.ram end
    if wlog_plugin.sto then writers.sto = wlog_plugin.sto end

    --if wlog_plugin.setup then wlog_plugin.setup() end

    if wlog_plugin.config then config = wlog_plugin.config end
    if wlog_plugin.defaults then
        local defs = wlog_plugin.defaults
        if  defs.module  then  defaults.module  =  defs.module   end
        if  defs.level   then  defaults.level   =  defs.level    end
        if  defs.writer  then  defaults.writer  =  defs.writer   end
    end

    if wlog_plugin.eval then eval = wlog_plugin.eval end

    _plugin = wlog_plugin

    wlog.writers  =  writers
    wlog.levels   =  levels
    wlog.modules  =  modules
    wlog.tags     =  tags
    wlog.config   =  config

dbg("before set_level")
    set_level(levels[defaults.level])

    for k,v in pairs(core.enums.WLOG_LEVELS)
        do
            local lvl = fromlevel(k)
            wlog[lvl] = wlog[defaults.module][lvl]
        end

    if wlog_plugin.setup then wlog_plugin.setup(wlog) end

    if debug then print("wlog: pluged-in: "..wlog_plugin.wlog_plugin_name) end
    return true
end

local config = function (cfg)
    -- {
    --  enums = <wlog enums>,
    --  defaults = <wlog defaults>,
    -- }
    if cfg then
        assert(type(cfg) == "table", "Wrong config: "..tostring(cfg))
        _reset()
        if cfg.defaults then defaults = cfg.defaults end -- TODO: assert defaults struct
        if cfg.enums then core.enums = cfg.enums end -- TODO: assert enums struct
        _init_enums()

        _init_writers()
        wlog.writers  =  writers
        wlog.levels   =  levels
        wlog.modules  =  modules
        wlog.tags     =  tags
        for k,v in pairs(core.enums.WLOG_LEVELS)
            do
                local lvl = fromlevel(k)
                wlog[lvl] = wlog[defaults.module][lvl]
            end
        set_level(levels[defaults.level])
    else
        local cfg = {}
        cfg.defaults = defaults
        cfg.enums = core.enums

        return cfg
    end

end

local function _init()
    wlog = {}

    _init_enums()

    _init_writers()

    wlog = setmetatable(wlog,wlog_mt)

    wlog._VERSION = "1.0"

    wlog.set_level = set_level

    wlog.writers      =           writers
    wlog.levels       =           levels
    wlog.modules      =           modules
    wlog.tags         =           tags
    wlog.plugin       =           plugin
    wlog.config       =           config
    wlog.fromlevel    =           fromlevel
    wlog.tolevel      =           tolevel
    wlog.frommodule   =           frommodule
    wlog.tomodule     =           tomodule
    wlog.is_module    =           is_module
    wlog.is_writer    =           is_writer
    wlog.add_module   =           add_module

    set_level(levels[defaults.level])

    for k,v in pairs(core.enums.WLOG_LEVELS)
        do
            local lvl = fromlevel(k)
            wlog[lvl] = wlog[defaults.module][lvl]
        end
end


_init()

return wlog
