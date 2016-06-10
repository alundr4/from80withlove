;;;;;;;;;;;;;;;;;;;;;;;;;
;     Scene 2 code      ;
;  sintext + starfield  ;
;      (mode 3)         ;
;;;;;;;;;;;;;;;;;;;;;;;;;


; Constants
.define SCN2_TILEMAP_VRAM_ADDR $6000
.define SCN2_BG1MAP_VRAM_ADDR  $400
.define SCN2_BG1CHR_VRAM_ADDR  $1000

; Scrolltext globals
SCROLLTEXT: .db "-OLDSKOOL 4EVER-",0
.define SCROLLTEXT_LEN  $10

ASCII_MAP: .db "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789()?-'."
.define WAVE_TIMING     $7F0000
.define WAVE_SIN_SHIFT  $7f0002
.define WAVE_COS_SHIFT  $7F0004

; Temp vars
.define WAVE_CHAR_POSX  $7F0006

; Mosaic effect
.define MOSAIC_FX       $7F0008
.define MOSAIC_TIMING   $7F000A

; Scrolltext cos/sin array
; start angle = 0
; step number = 256
; step size   = 1.4
; amplitude   = 86px for x, 92px for y
SCRTXT_SIN_X: .DBSIN 0.0,256,1.4,86,0
SCRTXT_COS_Y: .DBCOS 0.0,256,1.4,92,0

; OAM buffer (copy of hardware OAM)
.define OAM_BUF         $7f1000

SCN2_VB_PROCS:     .dw s2_fadein_proc,s2_main_proc
.define SCN2_CURRENT_PROC  $7F000C



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Initialize scene 2 video  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Scene2Init
    pha
    phx
    phy
    php

    rep #$10            ; set X/Y 16-bits

    ; Clean up vram & cgram from last scene
    jsr ResetVRAM
    jsr ResetCGRAM

    ; Load characters data in VRAM for BG1 and OBJ
    DMAVramWrite  S2BG1ChrDataBeg,SCN2_BG1CHR_VRAM_ADDR,S2BG1ChrDataEnd-S2BG1ChrDataBeg
    DMAVramWrite  S2ChrDataBeg,SCN2_TILEMAP_VRAM_ADDR,S2ChrDataEnd-S2ChrDataBeg

    ; Load tilemap for BG1
    DMAVramWrite  S2BG1TileMapBeg,SCN2_BG1MAP_VRAM_ADDR+10*32,S2BG1TileMapEnd-S2BG1TileMapBeg

    ; Load palette for OBJ (+128) and BG (+0) in CGRAM
    DMACGRamWrite S2BG1PalBeg,$00,S2BG1PalEnd-S2BG1PalBeg
    DMACGRamWrite S2BmpFontPalBeg,$80,S2BmpFontPalEnd-S2BmpFontPalBeg

    ; Set scrolltext parameters
    lda #$00
    sta WAVE_COS_SHIFT
    sta WAVE_TIMING

    ; Mosaic effect activated, 16x16 px
    lda #$0F
    sta MOSAIC_FX
    lda #$F1
    sta MOSAIC
    lda #$00
    sta MOSAIC_TIMING

    lda #$00
    sta SCN2_CURRENT_PROC 

    ; Init OAM tmp buffer with scrolltext font,
    jsr s2_init_OAM_buffer

    plp
    ply
    plx
    pla
    rts


; Init OAM with all chars from the bitmap
; font that match chars in SCROLLTEXT
s2_init_OAM_buffer
        
    pha
    phx
    phy
    php

    ; Load font characters in OAM for scrolltext 
    sep #$20            ; A 8 bit
    rep #$10            ; X/Y 16 bit

    ldy #0              ; string position
    ldx #0              ; position in OAM tmp buffer
    
    lda #0
    sta WAVE_CHAR_POSX  ; sprite posx - temp var

s2_init_sprites_next:
    lda SCROLLTEXT, Y
    beq s2_init_sprites_set_null_tile
    jsr s2_char_to_tilemap_ind
    jmp s2_init_sprites_set_tile
 
s2_init_sprites_set_null_tile:
    lda #0
    sta WAVE_CHAR_POSX
 
s2_init_sprites_set_tile:
    pha
    lda WAVE_CHAR_POSX 
    sta OAM_BUF, X      ; set sprite x = tile no * 16
    inx                
    lda #$F0
    sta OAM_BUF, X      ; set sprite y = off screen
    inx
    pla
    sta OAM_BUF, X      ; first sprite character no
    inx
    lda #%00000000
    sta OAM_BUF, X      ; 1st palette, no flip, priority 1 (BG is behind)

    lda WAVE_CHAR_POSX 
    adc #$10
    sta WAVE_CHAR_POSX  
    inx            
    cpx #512
    beq s2_init_sprites_done    
    cpy #SCROLLTEXT_LEN
    beq s2_init_sprites_next
    iny
    jmp s2_init_sprites_next

; clean extra 32 bytes
s2_init_sprites_done:
    lda #0 
    sta OAM_BUF, X   
    inx
    cpx #544
    bne s2_init_sprites_done   

    plp
    ply
    plx
    pla
    rts


; Bitmap font char to tilemap index
; params: A = ascii char, 8 bit
; return: A = index in tilemap
s2_char_to_tilemap_ind:
    phx
    phy
    php

    sep #$10        ; X/Y 8 bit
    ldy #0

; search char in ascii map
s2_char_to_tilemap_search_next:
    pha
    cmp ASCII_MAP,Y
    beq s2_char_to_tilemap_ind_found 
    lda ASCII_MAP,Y
    beq s2_char_to_tilemap_ind_blank
    iny
    pla
    bra s2_char_to_tilemap_search_next

; default char is space
s2_char_to_tilemap_ind_blank:
    ldy #42

; compute first tile position in vram
s2_char_to_tilemap_ind_found:
    pla
    phy
    pla
    and #$F8        ; get char pos on Y-axis
    asl
    asl             ; tiles line 1st address in VRAM
    tay
    lda 0, S
    and #$07        ; get char pos on X-axis
    rol             ; char tile pos relative to tiles line 1st address
    phy
    ply
    ora 0, S        ; tile number = (char posy * 32 )+ (char posx) * 2
                    ; posx / posy are coordinate in a 8 * 8 tiles map
s2_char_to_tilemap_ind_ret:
    plp
    ply
    plx
    rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Scene 2 Vblank period  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

Scene2Vblank
    phx

    lda SCN2_CURRENT_PROC
    asl
    tax
    jsr (SCN2_VB_PROCS,X)
    cmp #$01
    bne Scene2Vblank_exit
    lda SCN2_CURRENT_PROC
    ina 
    sta SCN2_CURRENT_PROC
Scene2Vblank_exit:
    plx
    lda #$00                ; scene 2 will never end actually
    rts


s2_fadein_proc:

    lda MOSAIC_TIMING
    and #$03
    bne s2_fadein_proc_nullend

    lda MOSAIC_FX
    dea
    sta MOSAIC_FX
    asl
    asl
    asl
    asl
    ora #$01
    sta MOSAIC
    cmp #$01
    beq s2_fadein_proc_end    

s2_fadein_proc_nullend:
    lda MOSAIC_TIMING
    ina
    sta MOSAIC_TIMING
    lda #$00
    rts    

s2_fadein_proc_end:
    lda #$00
    sta MOSAIC
    lda #$01
    rts


s2_main_proc:
    phx
    phy
    php

    sep #$20            ; A 8 bit
    rep #$10            ; X/Y 16 bit

    ; Slow down a bit
    lda WAVE_TIMING
    and #$1
    bne s2_main_proc_exit
 
    ldx #$0000          ; Start at offset 1 in OAM (= sprite x pos)
    ldy #$0000          ; sprite no in OAM

s2_vbl_update_sprites:
    tya
    cmp #SCROLLTEXT_LEN 
    beq s2_vbl_do_oam_dma

    pha
    asl
    asl
    asl
    adc WAVE_SIN_SHIFT
    and #$FF
    phy
    tay
    lda SCRTXT_SIN_X,Y  ; x shift with sin
    clc                 
    adc #(256/2 - 8)    ; add mid screen x
    sta OAM_BUF, X    
    ply
    pla

    inx

    tya
    adc WAVE_COS_SHIFT
    and #$FF
    phy
    tay
    lda SCRTXT_COS_Y,Y  ; y shift with cos
    clc                 
    adc #(224/2 - 8)    ; add mid screen y
    sta OAM_BUF, X    
    ply

    inx
    inx
    inx
    iny                 ; next char

    jmp s2_vbl_update_sprites


s2_vbl_do_oam_dma:
    DMAOAMWrite OAM_BUF>>16,OAM_BUF&$FFFF,$220

    lda WAVE_SIN_SHIFT
    clc
    adc #2
    sta WAVE_SIN_SHIFT
    lda WAVE_COS_SHIFT
    clc
    adc #3    
    sta WAVE_COS_SHIFT

s2_main_proc_exit:
    lda WAVE_TIMING
    ina
    sta WAVE_TIMING
    plp
    ply
    plx
    lda #$00
    rts

