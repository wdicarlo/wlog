# Default prefix
PREFIX = .

# Lua includes directory
LUA_HOME = $(PREFIX)/../..
LUA_INC= $(LUA_HOME)/src/
LUA_CFLAGS= -I$(LUA_HOME)/src


# Compilation directives
WARN= -O2 -Wall -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -Wpointer-arith -pedantic
INCS= -I$(LUA_INC)
CFLAGS+= $(WARN) $(INCS) -g -std=c99 -fPIC
LDFLAGS=-shared

T= libwlog
V= 0.0.1
LIBNAME= $T-$V.so

SRC_DIR = .
OBJ_DIR = obj/linux

OBJS= \
		$(OBJ_DIR)/wlog_lua_enums.o \
		$(OBJ_DIR)/wlog.o


.SUFFIXES:
.PHONY: all clean 

all: $(OBJ_DIR) $(LIBNAME)

$(LIBNAME): $(OBJS)
	@echo " [LD] -- $@"
	$(LD) -t $^ $(LDFLAGS) -o $@ 
	@$(shell ln -s $@ wlog.so)

$(OBJ_DIR):
	@mkdir -p $(OBJ_DIR)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@echo " [CC] -- $<"
	@$(CC) -c $(CFLAGS) $(LUA_CFLAGS) $< -o $@

clean:
	rm -f $(OBJS) $(LIBNAME) $(OBJ_DIR)/*.o $(OBJ_DIR)/*.d wlog.so log.txt*
