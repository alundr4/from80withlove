;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; From 80's with love SNES demo  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


.include "rom_header.inc"   ; SNES rom header

.bank 0 slot 0              ; code will be located at 00:8000
.org 0                      ; (see rom header for slot starting address)
.16BIT                      ; 16 bits as default for opcodes

.include "sneshw.inc"       ; SNES hardware cstes (CPU registers, PPU,...)
.include "sneslib.asm"      ; low-level API
.include "scene1.asm"       ; \ 
.include "scene2.asm"       ;  | SNES pr0n \o/
.include "scene3.asm"       ; /

SCN_INIT_PROC:  .dw Scene1Init,Scene2Init,Scene3Init
SCN_VB_PROC:    .dw Scene1Vblank,Scene2Vblank,Scene3Vblank

.define CURRENT_SCN $7F0100

.section "MainCode"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Entry point (RESET interrupt)  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Start:
    
    ResetSNES               ; reset console state with forced vblank


    jsr InitBGMode3         ; Init mode 3, 256*224, 8x8 tiles, 32x32 tilemap
                            ; BG1 tile map at 0x400 & chr data at 0x1000

    jsr InitObjects         ; Initialize OBJs (= sprites)
    
    lda #$00
    sta CURRENT_SCN         ; begin at scene 1
    tax
    jsr (SCN_INIT_PROC,X)   ; initialize scene 1

    lda #$0F
    sta INIDISP             ; disable forced vblank and set full brightness
    
    lda #$80
    sta NMITIMEM            ; Enable V-blank interrupt (NMI)

loop:
    wai                     ; wait for vblank / reduce CPU usage
    jmp loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  NMI interrupt (Vblank)  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ProcVblank:
    pha
    phx
    phy
    php

    rep #$10                ; 16-bit X/Y

    ; execute current scene vblank proc
    lda CURRENT_SCN
    tax
    jsr (SCN_VB_PROC,X)
    cmp #$00
    beq ProcVblank_exit
    inx
    inx
    txa
    sta CURRENT_SCN

    ; disable forced vblank and call new scene init proc
    ; next force vblank again
    lda #$80
    sta INIDISP
    jsr (SCN_INIT_PROC,X)
    lda #$0F
    sta INIDISP

ProcVblank_exit:
    lda RDNMI               ; clear NMI flag by read op (see nintendo dev book 1)

    plp
    ply
    plx
    pla
    rti                     ; back from an interruption


.ends


.emptyfill $00




;;;;;;;;;;;;;;;;;;;;;;;;;
;  DEMO DATA RESOURCES  ;
;;;;;;;;;;;;;;;;;;;;;;;;;

.bank 1 slot 0
.org 8000

.section "CharacterData1"


; Background for BG1 scene 1 (tilemap + 256 col pal + chr data)
S1BG1TileMapBeg
    .incbin "data/scene1_logo.map"
S1BG1TileMapEnd

S1BG1ChrDataBeg
    .incbin "data/scene1_logo.pic"
S1BG1ChrDataEnd

S1BG1PalBeg
    .incbin "data/scene1_logo.clr"
S1BG1PalEnd

.ends


.bank 2 slot 0
.org 8000

.section "CharacterData2"


; Bitmap font for scene 2 (chr data + pal), 4bpp
S2ChrDataBeg:
    .incbin "data/demo_sprites.pic"
S2ChrDataEnd

S2BmpFontPalBeg:
    .incbin "data/demo_sprites.clr"
S2BmpFontPalEnd

; Background for BG1 scene 2 (tilemap + 128 col pal + chr data)
S2BG1TileMapBeg
    .incbin "data/scene2_bg.map"
S2BG1TileMapEnd

S2BG1ChrDataBeg
    .incbin "data/scene2_bg.pic"
S2BG1ChrDataEnd

S2BG1PalBeg
    .incbin "data/scene2_bg.clr"
S2BG1PalEnd


.ends

