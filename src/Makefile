####################################
# From-80s-with love demo Makefile #
####################################

OS:=$(shell uname -s)
ARCH:=$(shell uname -p)
ifeq ($(OS),Linux)
    SNESC 		= ../bin/wla-65816-linux-x64
    SNESL		= ../bin/wlalink-linux-x64
    PCX2SNES    = ../bin/pcx2snes-linux-x64
else ifeq ($(OS),Darwin)
  ifeq ($(ARCH),powerpc)
    SNESC       = ../bin/wla-65816-darwin-ppc-i386
    SNESL       = ../bin/wlalink-darwin-ppc-i386
    PCX2SNES    = ../bin/pcx2snes-darwin-ppc-i386
  else
    SNESC		= ../bin/wla-65816-darwin-x64
    SNESL 		= ../bin/wlalink-darwin-x64
    PCX2SNES    = ../bin/pcx2snes-darwin-x64
  endif
endif

SNESC_FLAGS 	= -vo
SNESL_FLAGS 	= -r

SNES_SOURCES	= main.asm
OBJS 		= $(SNES_SOURCES:.asm=.o)

TARGET_ROM 	= from-80s-with-love.sfc

RED		= '\e[31;31m'
NC		= '\e[0m'

all: $(TARGET_ROM)

$(TARGET_ROM): $(OBJS)
	@echo "[+] Linking"
	@echo "[objects]" > link.txt
	@echo $(OBJS) >> link.txt
	$(SNESL) $(SNESL_FLAGS) link.txt $(TARGET_ROM) 
	@rm -rf link.txt 	

%.o: %.asm
	@echo "[+] Compiling"
	$(SNESC) $(SNESC_FLAGS) $<

ifneq ($(OS),Darwin)
	@echo -e $(NC)
endif

clean:
	rm -rf $(OBJS)

fullclean: clean
	rm -rf $(TARGET_ROM)

