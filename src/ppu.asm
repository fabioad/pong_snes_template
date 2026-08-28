; PPU setup. MMIO stores use 8-bit A. Tile upload via DMA (Force Blank).

.BANK 0 SLOT 0
.SECTION "PPU" FREE

InitGraphics:
    sep #$20
    .ACCU 8
    rep #$10
    .INDEX 16

    lda #INIDISP_FORCEBLANK.b
    sta INIDISP

    lda #BGMODE_0.b
    sta BGMODE
    stz MOSAIC
    lda #OBJSEL_8X8_AT_4000.b
    sta OBJSEL
    lda #BG1SC_32X32_AT_0800.b
    sta BG1SC
    lda #BG12NBA_TILES_0000.b
    sta BG12NBA

    stz BG1HOFS
    stz BG1HOFS
    lda #$FF.b                  ; VOFS = -1 so tile row 0 is the top line
    sta BG1VOFS
    lda #$03.b
    sta BG1VOFS

    stz TM
    stz TS
    stz TMW
    stz TSW
    stz CGWSEL
    stz CGADSUB
    stz SETINI
    stz MEMSEL

    jsr LoadPalette
    jsr LoadTiles
    jsr LoadSpriteTiles
    jsr ClearTilemap
    jsr DrawTitleScreen
    jsr HideAllSprites

    lda #TM_BG1.b
    sta TM
    lda #INIDISP_FULLBRIGHT.b
    sta INIDISP
    rts

LoadPalette:
    sep #$20
    .ACCU 8
    stz CGADD
    lda #BACKDROP_LO.b
    sta CGDATA
    lda #BACKDROP_HI.b
    sta CGDATA
    lda #TILE_WHITE_LO.b
    sta CGDATA
    lda #TILE_WHITE_HI.b
    sta CGDATA
    lda #TILE_YELLOW_LO.b
    sta CGDATA
    lda #TILE_YELLOW_HI.b
    sta CGDATA
    lda #CGRAM_SPRITE0.b
    sta CGADD
    stz CGDATA
    stz CGDATA
    lda #TILE_WHITE_LO.b
    sta CGDATA
    lda #TILE_WHITE_HI.b
    sta CGDATA
    rts

; X = VRAM word address. Leaves A 8-bit.
SetVRAMAddress:
    rep #$20
    .ACCU 16
    txa
    sep #$20
    .ACCU 8
    sta VMADDL
    xba
    sta VMADDH
    rts

LoadTiles:
    sep #$20
    .ACCU 8
    lda #VMAIN_INC_HIGH.b
    sta VMAIN
    ldx #VRAM_BG1_TILES.w
    jsr SetVRAMAddress
    lda #$01.b
    sta DMAP0
    lda #$18.b
    sta BBAD0
    rep #$20
    .ACCU 16
    lda #TileData
    sep #$20
    .ACCU 8
    sta A1T0L
    xba
    sta A1T0H
    stz A1B0
    rep #$20
    .ACCU 16
    lda #TILE_BYTES
    sep #$20
    .ACCU 8
    sta DAS0L
    xba
    sta DAS0H
    lda #$01.b
    sta MDMAEN
    rts

LoadSpriteTiles:
    sep #$20
    .ACCU 8
    lda #VMAIN_INC_HIGH.b
    sta VMAIN
    ldx #VRAM_OBJ_TILES.w
    jsr SetVRAMAddress
    lda #$01.b
    sta DMAP0
    lda #$18.b
    sta BBAD0
    rep #$20
    .ACCU 16
    lda #SpriteTiles
    sep #$20
    .ACCU 8
    sta A1T0L
    xba
    sta A1T0H
    stz A1B0
    lda #SPRITE_TILE_BYTES.b
    sta DAS0L
    stz DAS0H
    lda #$01.b
    sta MDMAEN
    rts

ClearTilemap:
    sep #$20
    .ACCU 8
    rep #$10
    .INDEX 16
    lda #VMAIN_INC_HIGH.b
    sta VMAIN
    ldx #VRAM_BG1_MAP.w
    jsr SetVRAMAddress
    ldy #TILEMAP_WORDS.w
ClearTilemapLoop:
    stz VMDATAL
    stz VMDATAH
    dey
    bne ClearTilemapLoop
    rts

.ENDS
