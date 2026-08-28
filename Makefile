# SNES LoROM template — 32 KiB, NTSC, ROM only.
# Current milestone: 10 (NMI + DMA OAM/VRAM).
#
#   make                # tela azul
#   make COLOR=black
#   make COLOR=blue
#   make COLOR=red
#   make colors         # as três ROMs de teste
#   make verify
#   make toolchain      # instala WLA-DX em tools/bin

WLA     ?= $(firstword $(wildcard tools/bin/wla-65816) $(shell command -v wla-65816 2>/dev/null))
WLALINK ?= $(firstword $(wildcard tools/bin/wlalink) $(shell command -v wlalink 2>/dev/null))

ifeq ($(strip $(WLA)),)
$(error wla-65816 not found. Run: make toolchain)
endif

COLOR   ?= blue
ROM     := build/pong-$(COLOR).sfc
OBJ     := build/main-$(COLOR).o
LINK    := build/link-$(COLOR)

SRC := \
	src/main.asm \
	src/header.inc \
	src/hardware.inc \
	src/ram.inc \
	src/vectors.asm \
	src/reset.asm \
	src/nmi.asm \
	src/ppu.asm \
	src/input.asm \
	src/title.asm \
	src/game.asm \
	src/sprites.asm \
	src/assets.asm

ifeq ($(COLOR),black)
	COLOR_FLAG := -D BACKDROP_LO=0 -D BACKDROP_HI=0
else ifeq ($(COLOR),blue)
	COLOR_FLAG := -D BACKDROP_LO=0 -D BACKDROP_HI=124
else ifeq ($(COLOR),red)
	COLOR_FLAG := -D BACKDROP_LO=31 -D BACKDROP_HI=0
else
	$(error COLOR must be black, blue, or red)
endif

.PHONY: all colors clean verify toolchain

all: $(ROM)
	@cp -f $(ROM) build/pong.sfc

$(OBJ): $(SRC)
	@mkdir -p build
	$(WLA) -o $@ -I src $(COLOR_FLAG) src/main.asm

$(LINK):
	@mkdir -p build
	@printf '[objects]\n%s\n' $(OBJ) > $@

$(ROM): $(OBJ) $(LINK)
	$(WLALINK) -S $(LINK) $@

colors:
	$(MAKE) COLOR=black
	$(MAKE) COLOR=red
	$(MAKE) COLOR=blue

verify: $(ROM)
	python3 tools/verify_rom.py $(ROM)

clean:
	rm -f build/*.o build/*.sfc build/*.sym build/link-*

toolchain:
	@mkdir -p tools
	@if [ ! -d tools/wla-dx/.git ]; then \
		git clone --depth 1 https://github.com/vhelin/wla-dx.git tools/wla-dx; \
	fi
	cmake -S tools/wla-dx -B tools/wla-dx/build -DCMAKE_BUILD_TYPE=Release
	cmake --build tools/wla-dx/build --target wla-65816 wlalink -j$$(nproc)
	mkdir -p tools/bin
	cp tools/wla-dx/build/binaries/wla-65816 tools/wla-dx/build/binaries/wlalink tools/bin/
	@echo "Installed WLA-DX to tools/bin"
