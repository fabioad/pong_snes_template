; Playfield, integer PONG, and two-digit scores.

.BANK 0 SLOT 0
.SECTION "Game" FREE

InitGameState:
    sep #$20
    .ACCU 8
    rep #$10
    .INDEX 16
    ldx #PADDLE_START_Y.w
    stx paddle_left_y
    stx paddle_right_y
    ldx #BALL_START_X.w
    stx ball_x
    ldx #BALL_START_Y.w
    stx ball_y
    ldx #BALL_SPEED.w
    stx ball_dx
    stx ball_dy
    stz score_left
    stz score_right
    rts

DrawPlayfield:
    sep #$20
    .ACCU 8
    rep #$10
    .INDEX 16
    lda #VMAIN_INC_HIGH.b
    sta VMAIN
    stz draw_y
DrawPFRow:
    lda draw_y
    rep #$20
    .ACCU 16
    and #$00FF.w
    asl a
    asl a
    asl a
    asl a
    asl a
    clc
    adc #VRAM_BG1_MAP.w
    tax
    sep #$20
    .ACCU 8
    jsr SetVRAMAddress
    stz draw_x
DrawPFCol:
    lda draw_y
    beq DrawPFWall
    cmp #PLAYFIELD_BOTTOM_ROW.b
    beq DrawPFWall
    lda draw_x
    cmp #16.b
    bne DrawPFEmpty
    lda draw_y
    and #$01.b
    bne DrawPFEmpty
    lda #TILE_NET.b
    bra DrawPFStore
DrawPFWall:
    lda #TILE_SOLID.b
    bra DrawPFStore
DrawPFEmpty:
    lda #TILE_SPACE.b
DrawPFStore:
    sta VMDATAL
    stz VMDATAH
    inc draw_x
    lda draw_x
    cmp #TILEMAP_W.b
    bne DrawPFCol
    inc draw_y
    lda draw_y
    cmp #TILEMAP_W.b
    bne DrawPFRow
    rts

EnterGame:
    sep #$20
    .ACCU 8
    stz NMITIMEN
    lda #INIDISP_FORCEBLANK.b
    sta INIDISP
    lda #STATE_GAME.b
    sta game_state
    jsr ClearTilemap
    jsr InitGameState
    jsr DrawPlayfield
    jsr DrawScore
    jsr HideAllSprites
    jsr BuildOAM
    jsr DMAOAM
    lda #TM_BG1_OBJ.b
    sta TM
    lda #INIDISP_FULLBRIGHT.b
    sta INIDISP
    lda #NMITIMEN_NMI_JOY.b
    sta NMITIMEN
    rts

UpdatePaddleLeft:
    rep #$20
    .ACCU 16
    lda joy_current
    and #BUTTON_UP.w
    beq PaddleLeftDown
    lda paddle_left_y
    sec
    sbc #PADDLE_SPEED.w
    jsr ClampPaddleY
    sta paddle_left_y
PaddleLeftDown:
    lda joy_current
    and #BUTTON_DOWN.w
    beq PaddleLeftDone
    lda paddle_left_y
    clc
    adc #PADDLE_SPEED.w
    jsr ClampPaddleY
    sta paddle_left_y
PaddleLeftDone:
    sep #$20
    .ACCU 8
    rts

; Right paddle: AI in 1P, joy 2 in 2P.
UpdatePaddleRight:
    sep #$20
    .ACCU 8
    lda two_player
    bne UpdatePaddleRightHuman
    rep #$20
    .ACCU 16
    lda paddle_right_y
    clc
    adc #12.w
    sec
    sbc ball_y
    beq PaddleRightDone
    bmi PaddleRightDown
    lda paddle_right_y
    sec
    sbc #PADDLE_SPEED.w
    jsr ClampPaddleY
    sta paddle_right_y
    bra PaddleRightDone
PaddleRightDown:
    lda paddle_right_y
    clc
    adc #PADDLE_SPEED.w
    jsr ClampPaddleY
    sta paddle_right_y
    bra PaddleRightDone
UpdatePaddleRightHuman:
    rep #$20
    .ACCU 16
    lda joy2_current
    and #BUTTON_UP.w
    beq PaddleRightHumanDown
    lda paddle_right_y
    sec
    sbc #PADDLE_SPEED.w
    jsr ClampPaddleY
    sta paddle_right_y
PaddleRightHumanDown:
    lda joy2_current
    and #BUTTON_DOWN.w
    beq PaddleRightDone
    lda paddle_right_y
    clc
    adc #PADDLE_SPEED.w
    jsr ClampPaddleY
    sta paddle_right_y
PaddleRightDone:
    sep #$20
    .ACCU 8
    rts

; In: 16-bit A = paddle Y. Out: clamped A.
ClampPaddleY:
    cmp #PADDLE_MIN_Y.w
    bcs ClampPaddleMax
    lda #PADDLE_MIN_Y.w
    rts
ClampPaddleMax:
    cmp #PADDLE_MAX_Y.w
    bcc ClampPaddleOk
    lda #PADDLE_MAX_Y.w
ClampPaddleOk:
    rts

UpdateBall:
    rep #$20
    .ACCU 16
    lda ball_x
    clc
    adc ball_dx
    sta ball_x
    lda ball_y
    clc
    adc ball_dy
    sta ball_y
    sep #$20
    .ACCU 8
    rts

CollideWalls:
    rep #$20
    .ACCU 16
    lda ball_y
    cmp #BALL_MIN_Y.w
    bcs CollideWallBottom
    lda #BALL_MIN_Y.w
    sta ball_y
    jsr NegateBallDy
    bra CollideWallsDone
CollideWallBottom:
    cmp #BALL_MAX_Y.w
    bcc CollideWallsDone
    lda #BALL_MAX_Y.w
    sta ball_y
    jsr NegateBallDy
CollideWallsDone:
    sep #$20
    .ACCU 8
    rts

NegateBallDy:
    lda ball_dy
    eor #$FFFF.w
    inc a
    sta ball_dy
    rts

NegateBallDx:
    lda ball_dx
    eor #$FFFF.w
    inc a
    sta ball_dx
    rts

CollidePaddles:
    rep #$20
    .ACCU 16
    lda ball_dx
    bpl CollideRightPaddle
    lda ball_x
    cmp #(PADDLE_LEFT_X + PADDLE_W).w
    bcs CollidePaddlesDone
    clc
    adc #BALL_SIZE.w
    cmp #PADDLE_LEFT_X.w
    bcc CollidePaddlesDone
    lda paddle_left_y
    clc
    adc #PADDLE_H.w
    cmp ball_y
    beq CollideLeftY
    bcc CollidePaddlesDone
CollideLeftY:
    lda ball_y
    clc
    adc #BALL_SIZE.w
    cmp paddle_left_y
    bcc CollidePaddlesDone
    lda #(PADDLE_LEFT_X + PADDLE_W).w
    sta ball_x
    jsr NegateBallDx
    bra CollidePaddlesDone
CollideRightPaddle:
    lda ball_x
    cmp #PADDLE_RIGHT_X.w
    bcs CollideRightX
    clc
    adc #BALL_SIZE.w
    cmp #PADDLE_RIGHT_X.w
    bcc CollidePaddlesDone
CollideRightX:
    lda ball_x
    cmp #(PADDLE_RIGHT_X + PADDLE_W).w
    bcs CollidePaddlesDone
    lda paddle_right_y
    clc
    adc #PADDLE_H.w
    cmp ball_y
    beq CollideRightY
    bcc CollidePaddlesDone
CollideRightY:
    lda ball_y
    clc
    adc #BALL_SIZE.w
    cmp paddle_right_y
    bcc CollidePaddlesDone
    lda #(PADDLE_RIGHT_X - BALL_SIZE).w
    sta ball_x
    jsr NegateBallDx
CollidePaddlesDone:
    sep #$20
    .ACCU 8
    rts

; A = 0-99. VRAM address already set; writes tens then ones.
WriteScorePair:
    sep #$20
    .ACCU 8
    ldx #$0000.w
WriteScoreTens:
    cmp #10.b
    bcc WriteScoreOnes
    sec
    sbc #10.b
    inx
    bra WriteScoreTens
WriteScoreOnes:
    pha
    txa
    clc
    adc #TILE_DIGIT_0.b
    sta VMDATAL
    stz VMDATAH
    pla
    clc
    adc #TILE_DIGIT_0.b
    sta VMDATAL
    stz VMDATAH
    rts

DrawScore:
    sep #$20
    .ACCU 8
    rep #$10
    .INDEX 16
    lda #VMAIN_INC_HIGH.b
    sta VMAIN
    ldx #SCORE_LEFT_VRAM.w
    jsr SetVRAMAddress
    lda score_left
    jsr WriteScorePair
    ldx #SCORE_RIGHT_VRAM.w
    jsr SetVRAMAddress
    lda score_right
    jsr WriteScorePair
    rts

IncScore:
    cmp #SCORE_MAX.b
    bcs IncScoreDone
    inc a
IncScoreDone:
    rts

CheckGoal:
    rep #$20
    .ACCU 16
    lda ball_x
    bmi ServeFromLeft
    cmp #BALL_MAX_X.w
    bcs ServeFromRight
    sep #$20
    .ACCU 8
    rts
ServeFromLeft:
    jsr ResetBall
    ldx #BALL_SPEED.w
    stx ball_dx
    sep #$20
    .ACCU 8
    lda score_right
    jsr IncScore
    sta score_right
    rts
ServeFromRight:
    jsr ResetBall
    ldx #BALL_SPEED.w
    txa
    eor #$FFFF.w
    inc a
    tax
    stx ball_dx
    sep #$20
    .ACCU 8
    lda score_left
    jsr IncScore
    sta score_left
    rts

ResetBall:
    ldx #BALL_START_X.w
    stx ball_x
    ldx #BALL_START_Y.w
    stx ball_y
    rts

UpdateGame:
    jsr UpdatePaddleLeft
    jsr UpdatePaddleRight
    jsr UpdateBall
    jsr CollideWalls
    jsr CollidePaddles
    jsr CheckGoal
    rts

.ENDS
