/*
 * =====================================================================================
 *
 *       Filename:  wlog.h
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

#ifndef __WLOG_H__
#define __WLOG_H__

#ifndef LUAPRELOAD_API
#define LUAPRELOAD_API
#endif
#ifndef LUALIB_API
#define LUALIB_API
#endif


#define WLOG_MODULE_NAME    "wlog.core"

extern int lua_wlog(lua_State *L);

LUALIB_API int luaopen_wlog_core(lua_State *L);
LUAPRELOAD_API int luapreload_wlog_core(lua_State *L);


#endif /* __WLOG_H__ */
