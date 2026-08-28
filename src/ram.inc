; WRAM layout. Direct page $0000; OAM buffer at $0200 (below the stack).

.ENUM $0000
    frame_counter   dw          ; $0000
    game_state      db          ; $0002 STATE_TITLE or STATE_GAME
    _pad_joy        db          ; $0003 keep joy_* even-aligned
    joy_current     dw          ; $0004 held this frame
    joy_previous    dw          ; $0006 held last frame
    joy_pressed     dw          ; $0008 newly pressed this frame
    nmi_ready       db          ; $000A set by NMI, cleared by WaitNMI
    draw_x          db
    draw_y          db
    spr_x           db
    spr_y           db
    spr_index       db
    ball_x          dw
    ball_y          dw
    ball_dx         dw
    ball_dy         dw
    paddle_left_y   dw
    paddle_right_y  dw
    score_left      db
    score_right     db
    two_player      db          ; 0 = IA na direita, 1 = joy 2
    menu_index      db          ; 0 = 1 jogador, 1 = 2 jogadores
    joy2_current    dw
    joy2_previous   dw
    joy2_pressed    dw
.ENDE

.ENUM $0200
    oam_buffer      dsb 512
    oam_hi          dsb 32
.ENDE
