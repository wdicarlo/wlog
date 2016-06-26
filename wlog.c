/*
 * =====================================================================================
 *
 *       Filename:  wlog.c
 *
 *    Description:
 *
 *        Version:  1.0
 *        Created:  26/06/2016 17:31:18
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Walter Di Carlo (WDC),
 *   Organization:
 *
 * =====================================================================================
 */

#include "lua.h"
#include "lauxlib.h"

#define LOGGER(output,module,function,level,pattern,...) printf("%d:%d:%d:%d",LOG_##output,LOG_##module,LOG_##function,LOG_##level); printf(pattern,__VA_ARGS__)

#include "wlog.h"
#include "wlog_lua_enums.h"


int lua_wlog_core(lua_State *L);

int lua_wlog_core(lua_State *L)
{
    unsigned  char  *filename  =  NULL;
    unsigned  int   line       =  0;
    unsigned  int   mod        =  LOG_WEBAPP;
    unsigned  int   funct      =  0;
    unsigned  int   level      =  0;
    unsigned  int   output;
    unsigned  char  *message   =  NULL;

    if( L == NULL )
        return 0;

    /* get funct */

    /* get level */

    /* call logger */
    LOGGER(LRAM,WEBAPP,GEN,INFO,"hello %s...\n","world");
    LOGGER(LRAM,WEBAPP,GEN,INFO,"OK!!! %s\n","that's all");

    return 0;
}

/***************************************************
  Library setup data
 ***************************************************/

static const luaL_Reg wlog_lib[] = {
   {"demo", &lua_wlog_core},
   {NULL, NULL}
};

extern void wlog_push_enums(lua_State *L);

LUALIB_API int luaopen_wlog_core(lua_State *L)
{

   /* register library */
   luaL_register(L, WLOG_MODULE_NAME, wlog_lib);

   wlog_push_enums(L);

   return 0;
}

LUAPRELOAD_API int luapreload_wlog_core(lua_State *L)
{
	luaL_findtable(L, LUA_GLOBALSINDEX, "package.preload", 2);

	lua_pushcfunction(L, luaopen_wlog_core);
	lua_setfield(L, -2, WLOG_MODULE_NAME);

	lua_pop(L, 1);


	return 0;
}
