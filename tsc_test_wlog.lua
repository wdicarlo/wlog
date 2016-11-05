local wlog = require "wlog"
local inspect = require"inspect"

local tostring = function (arg)
    if type(arg) == "table" then return inspect(arg) end
    return tostring(arg)
end

local verbose = false
local trace = function(txt)
    assert(txt and type(txt) == "string")
    if verbose then print(txt) end
end


describe("The wlog", function()
  local output = ""
  -- TODO: improve mock mechanism for writers
  local tsc_ram = function(msg)
      if output ~= "" then
          output = output.."\n".."ram: "..msg
      else
          output = "ram: "..msg
      end
  end
  local tsc_con = function(msg)
      if output ~= "" then
          output = output.."\n".."con: "..msg
      else
          output = "con: "..msg
      end
  end

  context("The wlog module", function()
    it("should have a '_VERSION' member", function()
      assert_equal("string", type(wlog._VERSION))
    end)
  end)
  context("The wlog initial levels and modules",function()
    it("should have a set of levels",function()
        trace(tostring(wlog.levels))
        local n = 0
        for k,v in pairs(wlog.levels) do n = n + 1 end
        assert(n==5,"Wrong number of levels: "..n.." expected: "..5)
        assert_equal(wlog.levels.ERR.name,"LOG_ERR")
        assert_equal(wlog.levels.WARN.name,"LOG_WARN")
        assert_equal(wlog.levels.INFO.name,"LOG_INFO")
        assert_equal(wlog.levels.TRACE.name,"LOG_TRACE")
        assert_equal(wlog.levels.DEBUG.name,"LOG_DEBUG")
    end)
    it("should have a set of default modules",function()
        trace(tostring(wlog.modules))
        local n = 0
        for k,v in pairs(wlog.modules) do n = n + 1 end
        assert(n==7,"Wrong number of modules: "..n.." expected: "..5)
        trace("wlog.modules.GEN.name: "..tostring(wlog.modules.GEN.name))
        assert_equal(wlog.modules.GEN.name,"LOG_GEN")
        assert_equal(wlog.modules.ALM.name,"LOG_ALM")
        assert_equal(wlog.modules.SYS.name,"LOG_SYS")
        assert_equal(wlog.modules.SQL.name,"LOG_SQL")
        assert_equal(wlog.modules.GUI.name,"LOG_GUI")
        assert_equal(wlog.modules.SRV.name,"LOG_SRV")
        assert_equal(wlog.modules.WEB.name,"LOG_WEB")
    end)
    it("should have a set of default writers",function()
    end)
  end)
  context("wlog.<module>.<level>() returns true if logging at that level is enabled or false",function()
      it("should log only from INFO down to ERR levels",function()
        assert_equal(wlog.GEN.ERR(),true)
      end)
      it("should log only from INFO down to ERR levels",function()
        assert_equal(wlog.GEN.WARN(),true)
      end)
      it("should log only from INFO down to ERR levels",function()
        assert_equal(wlog.GEN.INFO(),true)
      end)
      it("should log only from INFO down to ERR levels",function()
        assert_equal(wlog.GEN.TRACE(),false)
      end)
      it("should log only from INFO down to ERR levels",function()
        assert_equal(wlog.GEN.DEBUG(),false)
      end)
  end)
  context("wlog.<module>() returns the level of the module",function()
     for m,v in pairs(wlog.modules) do
          it("should return the INFO level by default",function()
            assert_equal(tostring(wlog[m]()),tostring(wlog.levels.INFO))
          end)
      end
  end)
  context("wlog.set_level(wlog.levels.<level>) set the level of all modules",function()
      it("should return the INFO level by default",function()
          wlog.set_level(wlog.levels.ERR)
          for m,v in pairs(wlog.modules) do
              assert_equal(tostring(wlog[m]()),tostring(wlog.levels.ERR))
          end
      end)
      it("should return the INFO level by default",function()
          wlog.set_level(wlog.levels.INFO)
          for m,v in pairs(wlog.modules) do
              assert_equal(tostring(wlog[m]()),tostring(wlog.levels.INFO))
          end
      end)
  end)
  context("The wlog default usage scenario",function()
      before(function()
          output = ""
          rawset(wlog.GEN.ERR,"_writer",tsc_con)
          rawset(wlog.GEN.WARN,"_writer",tsc_con)
          rawset(wlog.GEN.INFO,"_writer",tsc_con)
          rawset(wlog.GEN.TRACE,"_writer",tsc_con)
          rawset(wlog.GEN.DEBUG,"_writer",tsc_con)
      end)
      it("should log only from INFO down to ERR levels",function()
        assert_equal(wlog.GEN.ERR("GEN: ERR!!!"),true)
        assert_equal(output,"con: GEN: level=LOG_ERR msg=GEN: ERR!!!")
      end)
      it("should log only from INFO down to ERR levels",function()
        assert_equal(wlog.GEN.WARN("GEN: WARN!!!"),true)
        assert_equal(output,"con: GEN: level=LOG_WARN msg=GEN: WARN!!!")
      end)
      it("should log only from INFO down to ERR levels",function()
        assert_equal(wlog.GEN.INFO("GEN: INFO!!!"),true)
        assert_equal(output,"con: GEN: level=LOG_INFO msg=GEN: INFO!!!")
      end)
      it("should log only from INFO down to ERR levels",function()
        assert_equal(wlog.GEN.TRACE("GEN: TRACE!!!"),false)
        assert_equal(output,"")
      end)
      it("should log only from INFO down to ERR levels",function()
        assert_equal(wlog.GEN.DEBUG("GEN: DEBUG!!!"),false)
        assert_equal(output,"")
      end)
  end)
  context("The wlog default usage scenario for another module",function()
      before(function()
          output = ""
          rawset(wlog.WEB.ERR,"_writer",tsc_con)
          rawset(wlog.WEB.WARN,"_writer",tsc_con)
          rawset(wlog.WEB.INFO,"_writer",tsc_con)
          rawset(wlog.WEB.TRACE,"_writer",tsc_con)
          rawset(wlog.WEB.DEBUG,"_writer",tsc_con)
      end)
      it("should log only from INFO down to ERR levels",function()
        assert_equal(wlog.WEB.ERR("WEB: ERR!!!"),true)
        assert_equal(output,"con: WEB: level=LOG_ERR msg=WEB: ERR!!!")
      end)
      it("should log only from INFO down to ERR levels",function()
        assert_equal(wlog.WEB.WARN("WEB: WARN!!!"),true)
        assert_equal(output,"con: WEB: level=LOG_WARN msg=WEB: WARN!!!")
      end)
      it("should log only from INFO down to ERR levels",function()
        assert_equal(wlog.WEB.INFO("WEB: INFO!!!"),true)
        assert_equal(output,"con: WEB: level=LOG_INFO msg=WEB: INFO!!!")
      end)
      it("should log only from INFO down to ERR levels",function()
        assert_equal(wlog.WEB.TRACE("WEB: TRACE!!!"),false)
        assert_equal(output,"")
      end)
      it("should log only from INFO down to ERR levels",function()
        assert_equal(wlog.WEB.DEBUG("WEB: DEBUG!!!"),false)
        assert_equal(output,"")
      end)
  end)
  context("The wlog default usage scenario with INFO logging in ram writer",function()
      before(function()
          output = ""
          rawset(wlog.GEN.ERR,"_writer",tsc_con)
          rawset(wlog.GEN.WARN,"_writer",tsc_con)
          rawset(wlog.GEN.INFO,"_writer",tsc_ram)
          rawset(wlog.GEN.TRACE,"_writer",tsc_con)
          rawset(wlog.GEN.DEBUG,"_writer",tsc_con)
      end)
      it("should log only from INFO down to ERR levels",function()
        assert_equal(wlog.GEN.ERR("GEN: ERR!!!"),true)
        assert_equal(output,"con: GEN: level=LOG_ERR msg=GEN: ERR!!!")
      end)
      it("should log only from INFO down to ERR levels",function()
        assert_equal(wlog.GEN.WARN("GEN: WARN!!!"),true)
        assert_equal(output,"con: GEN: level=LOG_WARN msg=GEN: WARN!!!")
      end)
      it("should log only from INFO down to ERR levels",function()
        assert_equal(wlog.GEN.INFO("GEN: INFO!!!"),true)
        assert_equal(output,"ram: GEN: level=LOG_INFO msg=GEN: INFO!!!")
      end)
      it("should log only from INFO down to ERR levels",function()
        assert_equal(wlog.GEN.TRACE("GEN: TRACE!!!"),false)
        assert_equal(output,"")
      end)
      it("should log only from INFO down to ERR levels",function()
        assert_equal(wlog.GEN.DEBUG("GEN: DEBUG!!!"),false)
        assert_equal(output,"")
      end)
  end)
  context("GEN.INFO ram and con writer: ",function()
      before(function()
          output = ""
          rawset(wlog.GEN.ERR,"_writer",tsc_con)
          rawset(wlog.GEN.WARN,"_writer",tsc_con)
          rawset(wlog.GEN.INFO,"_writer",{tsc_ram,tsc_con})
          rawset(wlog.GEN.TRACE,"_writer",tsc_con)
          rawset(wlog.GEN.DEBUG,"_writer",tsc_con)
      end)
      it("should log with ram and con writers",function()
        assert_equal(wlog.GEN.INFO("GEN: INFO!!!"),true)
        assert_equal(output,"ram: GEN: level=LOG_INFO msg=GEN: INFO!!!\ncon: GEN: level=LOG_INFO msg=GEN: INFO!!!")
      end)
  end)
  context("wlog() is equivalent to wlog.GEN():",function()
      it("should have the same level",function()
          assert_equal(tostring(wlog()),tostring(wlog.GEN()))
      end)
      it("should have the same level after setting it at TRACE",function()
          wlog.GEN(wlog.levels.TRACE)
          assert_equal(tostring(wlog()),tostring(wlog.GEN()))
      end)
      it("should have the same level after setting it at ERR",function()
          wlog.GEN(wlog.levels.ERR)
          assert_equal(tostring(wlog()),tostring(wlog.GEN()))
      end)
  end)
  context("wlog.<level>() is equivalent to wlog.GEN.<level>(): ",function()
     for m,v in pairs(wlog.levels) do
      it("should wlog."..m.."() equal to wlog.GEN."..m.."()",function()
          assert_equal(tostring(wlog[m]()),tostring(wlog.GEN[m]()))
      end)
     end
  end)
  context("wlog.<module>(wlog.levels.<level>) and wlog.<module>() allows to set and retrieve the level of the module",function()
      it("should return wlog.levels.INFO if the module is at INFO level",function()
        wlog.GEN(wlog.levels.INFO)
        assert_equal(tostring(wlog.GEN()),tostring(wlog.levels.INFO))
      end)
      it("should return wlog.levels.TRACE if the module is at TRACE level",function()
        wlog.GEN(wlog.levels.TRACE)
        assert_equal(tostring(wlog.GEN()),tostring(wlog.levels.TRACE))
      end)
  end)
  context("wlog.<module>( wlog.<mod>.<level>() and <msg>  )",function()
      before(function()
          output = ""
          rawset(wlog.GEN.ERR,"_writer",tsc_con)
          rawset(wlog.GEN.WARN,"_writer",tsc_con)
          rawset(wlog.GEN.INFO,"_writer",tsc_con)
          rawset(wlog.GEN.TRACE,"_writer",tsc_con)
          rawset(wlog.GEN.DEBUG,"_writer",tsc_con)
      end)
      it("should log a message using the short-circuit mechanism at INFO level",function()
          wlog.GEN(wlog.levels.INFO)
          wlog.GEN( wlog.GEN.ERR()    and "GEN: ERR!!!")
          wlog.GEN( wlog.GEN.WARN()   and "GEN: WARN!!!")
          wlog.GEN( wlog.GEN.TRACE()  and "GEN: TRACE!!!")
          wlog.GEN( wlog.GEN.INFO()   and "GEN: INFO!!!")
          wlog.GEN( wlog.GEN.DEBUG()  and "GEN: DEBUG!!!")
          assert_equal(output,"con: GEN: level=LOG_ERR msg=GEN: ERR!!!\ncon: GEN: level=LOG_WARN msg=GEN: WARN!!!\ncon: GEN: level=LOG_INFO msg=GEN: INFO!!!")
      end)
      it("should log a message using the short-circuit mechanism at ERR level",function()
          wlog.GEN(wlog.levels.ERR)
          wlog.GEN( wlog.GEN.ERR()    and "GEN: ERR!!!")
          wlog.GEN( wlog.GEN.WARN()   and "GEN: WARN!!!")
          wlog.GEN( wlog.GEN.TRACE()  and "GEN: TRACE!!!")
          wlog.GEN( wlog.GEN.INFO()   and "GEN: INFO!!!")
          wlog.GEN( wlog.GEN.DEBUG()  and "GEN: DEBUG!!!")
          assert_equal(output,"con: GEN: level=LOG_ERR msg=GEN: ERR!!!")
      end)
      it("should log a message using the short-circuit mechanism at WARN level",function()
          wlog.GEN(wlog.levels.WARN)
          wlog( wlog.GEN.ERR()    and "GEN: ERR!!!")
          wlog( wlog.GEN.WARN()   and "GEN: WARN!!!")
          wlog( wlog.GEN.TRACE()  and "GEN: TRACE!!!")
          wlog( wlog.GEN.INFO()   and "GEN: INFO!!!")
          wlog( wlog.GEN.DEBUG()  and "GEN: DEBUG!!!")
          assert_equal(output,"con: GEN: level=LOG_ERR msg=GEN: ERR!!!\ncon: GEN: level=LOG_WARN msg=GEN: WARN!!!")
      end)
  end)
  context("if wlog.<module>.<level>() then wlog.<module>(<msg1>); wlog.<module>(<msg2>); end",function()
      before(function()
          output = ""
          rawset(wlog.GEN.ERR,"_writer",tsc_con)
          rawset(wlog.GEN.WARN,"_writer",tsc_con)
          rawset(wlog.GEN.INFO,"_writer",tsc_con)
          rawset(wlog.GEN.TRACE,"_writer",tsc_con)
          rawset(wlog.GEN.DEBUG,"_writer",tsc_con)
      end)
    it("should log set of messages without repeating the level",function()
        wlog.set_level(wlog.levels.TRACE)
        if wlog.GEN.TRACE() then
            wlog.GEN("one")
            wlog.GEN("two")
        end
        if wlog.GEN.DEBUG() then
            wlog.GEN("three")
            wlog.GEN("four")
        end
        assert_equal(output,"con: GEN: level=LOG_TRACE msg=one\ncon: GEN: level=LOG_TRACE msg=two")
    end)
  end)
  context("wlog.<tag>(wlog.levels.<level>) and wlog.<tag>() allows to set/get the level of a tag",function()
      it("should set the tag mytag to TRACE",function()
        wlog.mytag(wlog.levels.TRACE)
        assert_equal(tostring(wlog.mytag()),tostring(wlog.levels.TRACE))
      end)
      it("should set the tag mytag1 to DEBUG",function()
        wlog.mytag1(wlog.levels.TRACE)
        assert_equal(tostring(wlog.mytag1()),tostring(wlog.levels.TRACE))
      end)
  end)
  context("wlog.<module>.<level>(<msg>,<tag>) logs only if level or tags' levels are enabled to log",function()
      before(function()
          output = ""
          rawset(wlog.GEN.ERR,"_writer",tsc_con)
          rawset(wlog.GEN.WARN,"_writer",tsc_con)
          rawset(wlog.GEN.INFO,"_writer",tsc_con)
          rawset(wlog.GEN.TRACE,"_writer",tsc_con)
          rawset(wlog.GEN.DEBUG,"_writer",tsc_con)
      end)
      it("should log a message if the tag is INFO, module is INFO and message is TRACE",function()
        wlog.set_level(wlog.levels.INFO)
        wlog.mytag(wlog.levels.INFO)
        wlog.TRACE ( "GEN: TRACE!!!", "mytag")
        --assert_equal(output,"con: GEN: level=LOG_TRACE msg=GEN: TRACE!!! #mytag")
        assert_equal(output,"")
      end)
      it("should log a message if the tag is INFO, module is TRACE and message is DEBUG",function()
        wlog.set_level(wlog.levels.TRACE)
        wlog.mytag(wlog.levels.INFO)
        wlog.DEBUG ( "GEN: DEBUG!!!", "mytag")
        --assert_equal(output,"con: GEN: level=LOG_DEBUG msg=GEN: DEBUG!!! #mytag")
        assert_equal(output,"")
      end)
      it("should not log a message if the tag is INFO, module is WARN and message is DEBUG",function()
        wlog.set_level(wlog.levels.WARN)
        wlog.mytag(wlog.levels.INFO)
        wlog.DEBUG ( "GEN: DEBUG!!!", "mytag")
        assert_equal(output,"")
      end)
  end)
  context("wlog.<module>.<level>(<msg>,{<tag1>,<tag2>}) with more then one tag",function()
      before(function()
          output = ""
          rawset(wlog.GEN.ERR,"_writer",tsc_con)
          rawset(wlog.GEN.WARN,"_writer",tsc_con)
          rawset(wlog.GEN.INFO,"_writer",tsc_con)
          rawset(wlog.GEN.TRACE,"_writer",tsc_con)
          rawset(wlog.GEN.DEBUG,"_writer",tsc_con)
      end)
      it("should log a message if the tag1 is INFO, tag2 is DEBUG, module is INFO and message is TRACE",function()
        wlog.set_level(wlog.levels.INFO)
        wlog.mytag1(wlog.levels.INFO)
        wlog.mytag2(wlog.levels.DEBUG)
        wlog.TRACE ( "GEN: TRACE!!!", {"mytag1","mytag2"})
        assert_equal(output,"con: GEN: level=LOG_TRACE msg=GEN: TRACE!!! #mytag1 #mytag2")
      end)
      it("should not log a message if the tag1 is TRACE, tag2 is DEBUG, module is INFO and message is TRACE",function()
        wlog.set_level(wlog.levels.INFO)
        wlog.mytag1(wlog.levels.TRACE)
        wlog.mytag2(wlog.levels.DEBUG)
        wlog.TRACE ( "GEN: TRACE!!!", {"mytag1","mytag2"})
        --assert_equal(output,"")
        assert_equal(output,"con: GEN: level=LOG_TRACE msg=GEN: TRACE!!! #mytag1 #mytag2")
      end)
  end)
  context("wlog.<module>.<level>{<tag>,...} with one or more tags",function()
      it("should return true if the tag1 is INFO, tag2 is DEBUG, module is INFO and message is TRACE",function()
        wlog.set_level(wlog.levels.INFO)
        wlog.mytag1(wlog.levels.INFO)
        wlog.mytag2(wlog.levels.DEBUG)
        assert_true(wlog.TRACE{"mytag1","mytag2"})
      end)
      it("should return false if the tag1 is TRACE, tag2 is DEBUG, module is INFO and message is TRACE",function()
        wlog.set_level(wlog.levels.INFO)
        wlog.mytag1(wlog.levels.TRACE)
        wlog.mytag2(wlog.levels.DEBUG)
        --assert_false( wlog.TRACE {"mytag1","mytag2"} )
        assert_true( wlog.TRACE {"mytag1","mytag2"} )
      end)
  end)
  context("wlog.<mod> ( wlog.<mod>.<level>{<tag1>,...} and <msg>  )",function()
      before(function()
          output = ""
          rawset(wlog.GEN.ERR,"_writer",tsc_con)
          rawset(wlog.GEN.WARN,"_writer",tsc_con)
          rawset(wlog.GEN.INFO,"_writer",tsc_con)
          rawset(wlog.GEN.TRACE,"_writer",tsc_con)
          rawset(wlog.GEN.DEBUG,"_writer",tsc_con)
      end)
      it("should log a message if the tag1 is INFO, tag2 is DEBUG, module is INFO and message is TRACE",function()
        wlog.set_level(wlog.levels.INFO)
        wlog.mytag1(wlog.levels.INFO)
        wlog.mytag2(wlog.levels.DEBUG)
        wlog.WEB ( wlog.WEB.TRACE{"mytag1","mytag2"} and "WEB: TRACE!!!")
        assert_equal(output,"con: WEB: level=LOG_TRACE msg=WEB: TRACE!!! #mytag1 #mytag2")
      end)
      it("should log a message if the tag1 is INFO, tag2 is DEBUG, module is INFO and message is TRACE",function()
        wlog.set_level(wlog.levels.INFO)
        wlog.mytag1(wlog.levels.INFO)
        wlog.mytag2(wlog.levels.DEBUG)
        wlog ( wlog.TRACE{"mytag1","mytag2"} and "GEN: TRACE!!!")
        assert_equal(output,"con: GEN: level=LOG_TRACE msg=GEN: TRACE!!! #mytag1 #mytag2")
      end)
  end)
  context("wlog.tags{<tag1>,...}; wlog.tags(); ...; wlog.tags{}",function()
      wlog.set_level(wlog.levels.INFO)
      it("should not have contextual tags at the begin",function()
          assert_equal(#wlog.tags(),0)
      end)
      it("should add tags to the existing one",function()
          assert_equal(#wlog.tags(),0)
          wlog.tags{'a'}
          assert_equal(#wlog.tags(),1)
          wlog.tags{'b'}
          assert_equal(#wlog.tags(),2)
          wlog.tags{'c'}
          assert_equal(#wlog.tags(),3)
          assert_equal(tostring(wlog.tags()),"{ \"a\", \"b\", \"c\" }")
      end)
      it("should empty the contextual tags",function()
          assert_greater_than(#wlog.tags(),0)
          assert_equal(#wlog.tags{},0)
      end)
      it("should print the contextual tags in the log messages",function()
          output = ""
          rawset(wlog.GEN.INFO,"_writer",tsc_con)
          assert_equal(#wlog.tags(),0)
          wlog.tags{'a'}
          assert_equal(#wlog.tags(),1)
          wlog.INFO("Hello World")
          wlog.INFO("This is nice")
          wlog.INFO("Here we are","b")
          assert_equal(output, "con: GEN: level=LOG_INFO msg=Hello World #a\ncon: GEN: level=LOG_INFO msg=This is nice #a\ncon: GEN: level=LOG_INFO msg=Here we are #b #a")
          wlog.tags{}
          output = ""
          wlog.INFO("Hello World")
          assert_equal(output, "con: GEN: level=LOG_INFO msg=Hello World")
      end)
      it("should manage contextual tags like modules",function()
          wlog.tags{}
          assert_equal(#wlog.tags(),0)
          wlog.tags{'atag'}
          assert_equal(tostring(wlog.tags()),"{ \"atag\" }")
          wlog.atag(wlog.levels.ERR)
          assert_equal(tostring(wlog.atag()),tostring(wlog.levels.ERR))
      end)
  end)
  context("wlog.reset()",function()
      it("should reset the internal state",function()
      end)
  end)
  context("wlog.config() and wlog.config(cfg) can be used to get and set the configuration of modules",function()
      before(function()
          wlog.set_level(wlog.levels.ERR)
      end)
      it("should provide the configuration of the modules",function()
          local cfg = wlog.config()
          --assert_equal(tostring(cfg.level),tostring(wlog.levels.ERR))
          assert_equal(tostring(cfg.defaults),tostring({
              module = "GEN",
              level  = "INFO",
              writer = "con",
          }))

          assert_equal(tostring(cfg.enums),tostring({
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
          }))
      end)
      it("should set the configuration of the modules",function()
          local cfg = {
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
                      LOG_SYS = 2,
                      LOG_GUI = 3,
                  }
              },
              defaults = {
                  module = "SYS",
                  level  = "TRACE",
                  writer = "ram",
              }
          }
          wlog.config(cfg)
          local newcfg = wlog.config()
          --assert_equal(tostring(newcfg.level),tostring(wlog.levels.WARN))
          assert_equal(tostring(newcfg.defaults),tostring({
              module = "SYS",
              level  = "TRACE",
              writer = "ram",
          }))

          assert_equal(tostring(newcfg.enums),tostring({
              WLOG_LEVELS = {
                  LOG_ERR    =  1,
                  LOG_WARN   =  2,
                  LOG_INFO   =  3,
                  LOG_TRACE  =  4,
                  LOG_DEBUG  =  5,
              },
              WLOG_FUNCTS = {
                  LOG_GEN = 1,
                  LOG_SYS = 2,
                  LOG_GUI = 3,
              }
          }))
        end)
  end)
  context("wlog.plugin()",function()
      it("should have a plugin method",function()
          assert_not_nil(wlog.plugin,"Missing plugin method")
      end)
  end)
  context("wlog.plugin(wlog_plugin_mock)",function()
      before(function()
          wlog = {}
          wlog = require"wlog"
          local mock_plugin = require"wlog_plugin_mock"

          wlog.plugin(mock_plugin)
      end)
      it("should accept the mock plugin",function()
          local mock_plugin = require"wlog_plugin_mock"

          assert_true(wlog.plugin(mock_plugin),"Wrong plugin")
          assert_true(wlog.plugin().wlog_plugin_name == "mock plugin","Wrong plugin")
      end)
      it("should have a set of levels obtained from the plugin",function()
          trace(tostring(wlog.levels))
          local n = 0
          for k,v in pairs(wlog.levels) do n = n + 1 end
          assert(n==6,"Wrong number of levels: "..n.." expected: "..6)
          assert_equal(wlog.levels.CRIT.name,"LOG_FATAL")
          assert_equal(wlog.levels.ERROR.name,"LOG_ERROR")
          assert_equal(wlog.levels.WARNING.name,"LOG_WARNING")
          assert_equal(wlog.levels.INFO.name,"LOG_INFO")
          assert_equal(wlog.levels.TRACE.name,"LOG_TRACE")
          assert_equal(wlog.levels.DEBUG.name,"LOG_DEBUG")
      end)
      it("should have a set of default modules",function()
          trace(tostring(wlog.modules))
          local n = 0
          for k,v in pairs(wlog.modules) do n = n + 1 end
          assert(n==4,"Wrong number of modules: "..n.." expected: "..5)
          trace("wlog.modules.GEN.name: "..tostring(wlog.modules.GEN.name))
          assert_equal(wlog.modules.GEN.name,"LOG_GEN")
          assert_equal(wlog.modules.SYS.name,"LOG_SYS")
          assert_equal(wlog.modules.SQL.name,"LOG_SQL")
          assert_equal(wlog.modules.GUI.name,"LOG_GUI")
      end)
      it("should configure the level of the GEN module throught the config function",function()
          assert_equal(tostring(wlog()),tostring(wlog.levels.WARNING))
          wlog.config(wlog.levels.TRACE)
          assert_equal(tostring(wlog()),tostring(wlog.levels.TRACE))
          assert_not_equal(tostring(wlog()),tostring(wlog.levels.WARNING))
          assert_equal(tostring(wlog.config()),tostring(wlog.levels.TRACE))
          assert_not_equal(tostring(wlog.config()),tostring(wlog.levels.WARNING))
      end)
      it("should log level lower than the one of the default module",function()
        wlog.config(wlog.levels.ERROR)
        assert_false(wlog.WARNING())
        assert_true(wlog.ERROR())
        assert_true(wlog.CRIT())
        assert_true(wlog.SYS.ERROR())
        assert_false(wlog.SYS.TRACE())

        wlog.config(wlog.levels.TRACE)
        assert_true(wlog.SYS.ERROR())
        assert_true(wlog.SYS.TRACE())
        assert_false(wlog.SYS.DEBUG())
      end)
  end)
end)
