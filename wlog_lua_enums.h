/*
 * =====================================================================================
 *
 *       Filename:  wlog_lua_enums.h
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
#ifndef __WLOG_LUA_ENUMS_H__
#define __WLOG_LUA_ENUMS_H__

#include "lua.h"

#define  LOG_LRAM   1
#define  LOG_LCON   2

#define  LOG_ERR    3
#define  LOG_WARN   4
#define  LOG_INFO   5
#define  LOG_TRACE  6
#define  LOG_DEBUG  7

#define  LOG_WEBAPP  1

#define  LOG_GEN    1
#define  LOG_ALM    2
#define  LOG_SYS    3
#define  LOG_SQL    4
#define  LOG_GUI    5
#define  LOG_SRV    6
#define  LOG_WEB    6


#define PUSH_ENUM(enum_item)  do {  \
   lua_pushstring(L, #enum_item);    /* Push the table index */ \
   lua_pushinteger(L, enum_item);  /* Push the cell value */ \
   lua_rawset(L, -3);      /* Stores the pair in the table */ \
} while(0)

extern void lua_push_enums(lua_State *L);
extern const char * wlog_getLevelName(const unsigned int level);

#endif // __WLOG_LUA_ENUMS_H__

