local wlog = require"wlog"

local  INFO   =  wlog.INFO
local  TRACE  =  wlog.TRACE
local  DEBUG  =  wlog.DEBUG


function test_wlog()
    wlog.mod1.con( INFO() and "Here is the info")
    wlog.mod1.con( TRACE() and "Here is the trace")
    wlog.mod1.ram( DEBUG() and "Here is the debug")


    wlog.mod2.con( INFO() and "Here is the info")
    wlog.mod2.con( TRACE() and "Here is the trace")
    wlog.mod2.ram( TRACE() and "Here is the trace")
    wlog.mod2.con( DEBUG() and "Here is the debug")
end


print("Testing level: INFO")
wlog.level = wlog.LOG_LEVEL_INFO
test_wlog()

print("Testing level: TRACE")
wlog.level = wlog.LOG_LEVEL_TRACE
test_wlog()

print("Testing level: DEBUG")
wlog.level = wlog.LOG_LEVEL_DEBUG
test_wlog()

print("Testing level: NONE")
wlog.level = wlog.LOG_LEVEL_NONE
test_wlog()

print("Testing level: TRACE all in ram")
wlog.level = wlog.LOG_LEVEL_TRACE
wlog.mod1 = wlog.writers(wlog.modules.mod1,wlog.ram)
wlog.mod2 = wlog.writers(wlog.modules.mod2,wlog.ram)
test_wlog()

print("Testing level: DEBUG all in con")
wlog.level = wlog.LOG_LEVEL_DEBUG
wlog.mod1 = wlog.writers(wlog.modules.mod1,wlog.con)
wlog.mod2 = wlog.writers(wlog.modules.mod2,wlog.con)
test_wlog()

print("Testing level: INFO mod1 in ram and mod2 in con")
wlog.level = wlog.LOG_LEVEL_INFO
wlog.mod1 = wlog.writers(wlog.modules.mod1,wlog.ram)
wlog.mod2 = wlog.writers(wlog.modules.mod2,wlog.con)
test_wlog()

-- ======================================================== 
-- Example of output using command: lua test.lua
--
-- Testing level: INFO
-- mod1.con: Here is the info
-- mod2.con: Here is the info
-- Testing level: TRACE
-- mod1.con: Here is the info
-- mod1.con: Here is the trace
-- mod2.con: Here is the info
-- mod2.con: Here is the trace
-- mod2.ram: Here is the trace
-- Testing level: DEBUG
-- mod1.con: Here is the info
-- mod1.con: Here is the trace
-- mod1.ram: Here is the debug
-- mod2.con: Here is the info
-- mod2.con: Here is the trace
-- mod2.ram: Here is the trace
-- mod2.con: Here is the debug
-- Testing level: NONE
-- Testing level: TRACE all in ram
-- mod1.ram: Here is the info
-- mod1.ram: Here is the trace
-- mod2.ram: Here is the info
-- mod2.ram: Here is the trace
-- mod2.ram: Here is the trace
-- Testing level: DEBUG all in con
-- mod1.con: Here is the info
-- mod1.con: Here is the trace
-- mod1.con: Here is the debug
-- mod2.con: Here is the info
-- mod2.con: Here is the trace
-- mod2.con: Here is the trace
-- mod2.con: Here is the debug
-- Testing level: INFO mod1 in ram and mod2 in con
-- mod1.ram: Here is the info
-- mod2.con: Here is the info
-- ======================================================== 
