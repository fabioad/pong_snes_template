; CPU bring-up. All of this stays in bank $00.
; NMI is enabled only after the vector and OAM buffer are valid.

.BANK 0 SLOT 0
.SECTION "Reset" FREE

Reset:
    sei                     ; 1. disable IRQ
    clc                     ; 2. native 65816
    xce

    rep #$38                ; A/X/Y 16-bit, binary mode
    .ACCU 16
    .INDEX 16

    ldx #$1FFF.w            ; 4. stack in WRAM
    txs

    lda #$0000.w            ; 5. direct page = $0000
    tcd

    sep #$20                ; 8-bit A for MMIO
    .ACCU 8

    phk                     ; 3. DBR = current program bank ($00)
    plb

    lda #INIDISP_FORCEBLANK.b
    sta INIDISP             ; 6. Force Blank

    stz NMITIMEN            ; 7. no NMI until init is done
    stz MDMAEN
    stz HDMAEN

    stz menu_index
    stz two_player

    jsr InitGraphics

    lda #STATE_TITLE.b
    sta game_state
    stz nmi_ready
    stz frame_counter
    stz frame_counter+1
    rep #$20
    .ACCU 16
    stz joy_current
    stz joy_previous
    stz joy_pressed
    stz joy2_current
    stz joy2_previous
    stz joy2_pressed
    sep #$20
    .ACCU 8

    lda #NMITIMEN_NMI_JOY.b
    sta NMITIMEN

MainLoop:
    jsr WaitNMI
    lda game_state
    cmp #STATE_TITLE.b
    bne GameFrame
    jsr UpdateTitle
    jmp MainLoop
GameFrame:
    jsr DrawScore
    jsr UpdateGame
    jsr BuildOAM
    jmp MainLoop

.ENDS
