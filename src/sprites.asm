; OAM buffer in WRAM, copied to the PPU by hand. No DMA.

.BANK 0 SLOT 0
.SECTION "Sprites" FREE

HideAllSprites:
    sep #$20
    .ACCU 8
    rep #$10
    .INDEX 16
    ldx #$0000.w
HideOAMLow:
    stz oam_buffer.w,x
    lda #OAM_Y_OFFSCREEN.b
    sta oam_buffer+1.w,x
    stz oam_buffer+2.w,x
    stz oam_buffer+3.w,x
    inx
    inx
    inx
    inx
    cpx #512.w
    bne HideOAMLow
    ldx #$0000.w
HideOAMHi:
    stz oam_hi.w,x
    inx
    cpx #OAM_HI_BYTES.w
    bne HideOAMHi
    rts

; X = sprite index. Uses spr_x / spr_y. Tile 0, priority 2.
WriteSprite:
    sep #$20
    .ACCU 8
    rep #$10
    .INDEX 16
    phx
    rep #$20
    .ACCU 16
    txa
    asl a
    asl a
    tax
    sep #$20
    .ACCU 8
    lda spr_x
    sta oam_buffer.w,x
    lda spr_y
    sta oam_buffer+1.w,x
    stz oam_buffer+2.w,x
    lda #OAM_ATTR_PRI2.b
    sta oam_buffer+3.w,x
    plx
    rts

; X = first sprite index. spr_x / spr_y = top of paddle.
DrawPaddle:
    sep #$20
    .ACCU 8
    lda #PADDLE_SEGMENTS.b
    sta spr_index
DrawPaddleLoop:
    jsr WriteSprite
    lda spr_y
    clc
    adc #$08.b
    sta spr_y
    inx
    dec spr_index
    bne DrawPaddleLoop
    rts

BuildOAM:
    lda paddle_left_y
    sta spr_y
    lda #PADDLE_LEFT_X.b
    sta spr_x
    ldx #$0000.w
    jsr DrawPaddle
    lda paddle_right_y
    sta spr_y
    lda #PADDLE_RIGHT_X.b
    sta spr_x
    ldx #$0004.w
    jsr DrawPaddle
    lda ball_x
    sta spr_x
    lda ball_y
    sta spr_y
    ldx #$0008.w
    jsr WriteSprite
    rts

; DMA channel 0, 8-bit writes only. Call in Force Blank or NMI.

DMAOAM:
    sep #$20
    .ACCU 8
    stz OAMADDL
    stz OAMADDH
    stz DMAP0
    lda #$04.b
    sta BBAD0
    rep #$20
    .ACCU 16
    lda #oam_buffer
    sep #$20
    .ACCU 8
    sta A1T0L
    xba
    sta A1T0H
    lda #$7E.b
    sta A1B0
    lda #$20.b
    sta DAS0L
    lda #$02.b
    sta DAS0H
    lda #$01.b
    sta MDMAEN
    rts

.ENDS
