;;;;;;;;;;;;;;;;;;;;;;;;;
;     Scene 1 code      ;
;     logo + TODO :p    ;
;      (mode 3)         ;
;;;;;;;;;;;;;;;;;;;;;;;;;


; Constants
.define SCN1_BG1MAP_VRAM_ADDR  $400
.define SCN1_BG1CHR_VRAM_ADDR  $1000

.define S1_TIMING   $7F0000
.define S1_SCROLLX  $7F0002
.define S1_BG_WAVE  $7F0004

; Background wave sin table
; start angle = 0
; step number = 256
; step size   = 1.4
; amplitude   = 86px
BG_SIN_Y_TBL: .DBSIN 0.0,256,1.4,46,0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Initialize scene 1 video  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Scene1Init
    pha

    ; Load characters data in VRAM for BG1 and OBJ
    DMAVramWrite  S1BG1ChrDataBeg,SCN1_BG1CHR_VRAM_ADDR,S1BG1ChrDataEnd-S1BG1ChrDataBeg

    ; Load tilemap for BG1
    DMAVramWrite  S1BG1TileMapBeg,SCN1_BG1MAP_VRAM_ADDR+10*16,S1BG1TileMapEnd-S1BG1TileMapBeg

    ; Load palette for BG (+0) in CGRAM (256 entries and no space for OBJ)
    DMACGRamWrite S1BG1PalBeg,$00,S1BG1PalEnd-S1BG1PalBeg

    ; Scroll BG1 to make logo invisible
    lda #$FE
    sta S1_SCROLLX
    sta BG1H0FS
    stz BG1H0FS
    stz BG1V0FS
    stz BG1V0FS


    lda #$00
    sta S1_TIMING
    sta S1_BG_WAVE

    pla
    rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Scene 1 Vblank period  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
Scene1Vblank
    lda S1_TIMING
    ina
    sta S1_TIMING
    cmp #$CF                        ; just wait a bit
    beq Scene1Vblank_exit_forever

    lda S1_SCROLLX
    cmp #$00
    beq Scene1Vblank_exit
    dea
    dea
    sta S1_SCROLLX  
    sta BG1H0FS 
    stz BG1H0FS

    phy
    lda S1_BG_WAVE
    tay
    lda BG_SIN_Y_TBL,Y
    sta BG1V0FS
    stz BG1V0FS
    ply
    lda S1_BG_WAVE
    ina
    ina
    sta S1_BG_WAVE

Scene1Vblank_exit:
    lda #$00
    rts
    
Scene1Vblank_exit_forever:
    lda #$01
    rts

