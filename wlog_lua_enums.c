/*
 * =====================================================================================
 *
 *       Filename:  wlog_lua_enums.c
 *
 *    Description:
 *
 *        Version:  1.0
 *        Created:  26/06/16 18:06:46
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Di Carlo Walter (DCW),
 *   Organization:
 *
 * =====================================================================================
 */
#include "wlog_lua_enums.h"
#include "wlog.h"


static void lua_push_enum_WLOG_LEVELS(lua_State *L)
{
   lua_getglobal(L,"wlog");
   lua_pushstring(L,"core");
   lua_rawget(L,-2);
   lua_pushstring(L,"enums");
   lua_rawget(L,-2);

   lua_pushstring(L, "WLOG_LEVELS");
   lua_newtable(L);    /* We will pass a table */

   PUSH_ENUM(LOG_ERR);
   PUSH_ENUM(LOG_WARN);
   PUSH_ENUM(LOG_INFO);
   PUSH_ENUM(LOG_TRACE);
   PUSH_ENUM(LOG_DEBUG);

   lua_rawset(L,-3);
   lua_pop(L, 2);
}

static void lua_push_enum_WLOG_FUNCS(lua_State *L)
{
    lua_getglobal(L,"wlog");
    lua_pushstring(L,"core");
    lua_rawget(L,-2);
    lua_pushstring(L,"enums");
    lua_rawget(L,-2);

    lua_pushstring(L, "WLOG_FUNCTS");
    lua_newtable(L);    /* We will pass a table */

    PUSH_ENUM(LOG_GEN);
    PUSH_ENUM(LOG_ALM);
    PUSH_ENUM(LOG_SYS);
    PUSH_ENUM(LOG_SQL);
    PUSH_ENUM(LOG_GUI);
    PUSH_ENUM(LOG_SRV);
    PUSH_ENUM(LOG_WEB);

    lua_rawset(L,-3);
    lua_pop(L, 2);
}

const char * wlog_getLevelName(const unsigned int level)
{
   switch(level) {

      case LOG_ERR:
      return "LOG_ERR";
      break;
      case LOG_WARN:
      return "LOG_WARN";
      break;
      case LOG_INFO:
      return "LOG_INFO";
      break;
      case LOG_TRACE:
      return "LOG_TRACE";
      break;
      case LOG_DEBUG:
      return "LOG_DEBUG";
      break;
      default:
      return "";    /* error */
   }
}


void wlog_push_enums(lua_State *L)
{

   lua_getglobal(L,"wlog");
   lua_pushstring(L,"core");
   lua_rawget(L,-2);
   lua_pushstring(L,"enums");
   lua_newtable(L);
   lua_rawset(L,-3);
   lua_pop(L,1);

   lua_push_enum_WLOG_LEVELS(L);
   lua_push_enum_WLOG_FUNCS(L);
}

