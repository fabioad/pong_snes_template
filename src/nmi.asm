; Minimal NMI: ack, DMA OAM, copy auto-joy, bump frame, signal the main loop.
; Game logic stays in the main thread.

.BANK 0 SLOT 0
.SECTION "NMI" FREE

NMI:
    php
    rep #$30
    .ACCU 16
    .INDEX 16
    pha
    phx
    phy

    sep #$20
    .ACCU 8
    lda RDNMI

    jsr DMAOAM
    jsr CopyAutoJoy

    rep #$20
    .ACCU 16
    inc frame_counter
    sep #$20
    .ACCU 8
    lda #$01.b
    sta nmi_ready

    rep #$30
    .ACCU 16
    .INDEX 16
    ply
    plx
    pla
    plp
    rti

WaitNMI:
    sep #$20
    .ACCU 8
WaitNMILoop:
    lda nmi_ready
    beq WaitNMILoop
    stz nmi_ready
    rts

.ENDS
