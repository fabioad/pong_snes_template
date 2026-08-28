; Single assembly unit for the 32 KiB LoROM template.
; Later milestones add files here one at a time.

.INCLUDE "header.inc"
.INCLUDE "hardware.inc"
.INCLUDE "ram.inc"
.INCLUDE "vectors.asm"
.INCLUDE "reset.asm"
.INCLUDE "nmi.asm"
.INCLUDE "ppu.asm"
.INCLUDE "input.asm"
.INCLUDE "title.asm"
.INCLUDE "game.asm"
.INCLUDE "sprites.asm"
.INCLUDE "assets.asm"
