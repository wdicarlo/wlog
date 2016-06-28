-- =====================================================
-- wlog:   an example of lua logger
--
-- author: di carlo walter
-- 
-- date:   june 2016
-- =====================================================

local core = require"wlog.core"

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

---------------------------------------------------------------------------
-- sto is a wlog writer that rolls over the logfile
-- once it has reached a certain size limit. It also mantains a
-- maximum number of log files.
--
-- @author Tiago Cesar Katcipis (tiagokatcipis@gmail.com)
--
-- @copyright 2004-2013 Kepler Project
---------------------------------------------------------------------------
wlog.rollfile = {
    filename = "log.txt",
    maxSize = 50000,
    maxIndex = 5
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
    print("wlog: opened file: "..self.filename)
	return self.file
end

local rollOver = function (self)
	for i = self.maxIndex - 1, 1, -1 do
		-- files may not exist yet, lets ignore the possible errors.
        print("wlog: renaming file: "..self.filename.."."..i.." to "..self.filename.."."..i+1)
		os.rename(self.filename.."."..i, self.filename.."."..i+1)
	end

	self.file:close()
    print("wlog: closed file: "..self.filename)
	self.file = nil

    print("wlog: renaming file: "..self.filename.." to "..self.filename..".".."1")
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

local sto = function (module,txt)
    return function(txt)
        local f, err = openRollingFileLogger(wlog.rollfile)
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


