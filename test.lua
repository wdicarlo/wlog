local wlog = require"wlog"

local clog = wlog.WEB.con
local rlog = wlog.WEB.ram


function test_wlog()
    clog( ERR and "ERR!!!")
    clog( INFO and "INFO!!!")
    clog( TRACE and "TRACE!!!")
    clog( DEBUG and "DEBUG!!!")
    rlog( ERR and "ERR!!!")
    rlog( INFO and "INFO!!!")
    rlog( TRACE and "TRACE!!!")
    rlog( DEBUG and "DEBUG!!!")

    wlog.GEN.con( TRACE and "TRACE!!!")
    wlog.GEN.ram( TRACE and "TRACE!!!")
end

print("Testing wlog: DEBUG...")
wlog.set_level (wlog.DEBUG)
test_wlog()

print("Testing wlog: INFO...")
wlog.set_level ( wlog.INFO )
test_wlog()

print("Testing level: TRACE all in ram")
wlog.set_level ( wlog.TRACE )
wlog.WEB = wlog.writers(wlog.modules.WEB,wlog.ram)
clog = wlog.WEB.con
rlog = wlog.WEB.ram
test_wlog()

print("Testing level: DEBUG all in con")
wlog.set_level ( wlog.DEBUG )
wlog.WEB = wlog.writers(wlog.modules.WEB,wlog.con)
clog = wlog.WEB.con
rlog = wlog.WEB.ram
test_wlog()

print("Testing level: INFO reset output")
wlog.set_level ( wlog.INFO )
wlog.WEB = wlog.writers(wlog.modules.WEB)
clog = wlog.WEB.con
rlog = wlog.WEB.ram
test_wlog()

print("Testing level: INFO with rolling file")
wlog.WEB = wlog.writers(wlog.modules.WEB,wlog.sto)
clog = wlog.WEB.con
rlog = wlog.WEB.ram
for i=1,1000 do
    test_wlog()
end
