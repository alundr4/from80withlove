;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  SNES Low level API        ;
;  Hardware init, basic ops  ;
;  (DMA copy to CGRam/VRAM   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; CPU initialization
.macro InitCPU
    
    clc                 ; clear CF
    xce                 ; dwitch to 65816 native mode
                        ; 6502 emulation mode is now disabled
    cld                 ; disable decimal mode
    rep #$D3            ; 16-bits X/Y, clear CF, NF, OF, ZF         
    sep #$20            ; 8-bit A
    ldx #$1FFF           
    txs                 ; set stack to hihest WRAM memory available in bank 0

.endm


; Reset CPU / PPU / clear memory
.macro ResetSNES 

    sei                 ; disable interrupts

    InitCPU
    jsr ResetPPU
    jsr ResetCPU
    jsr ResetVRAM
    jsr ResetCGRAM
    jsr ResetOAM
    ;lda #$00
    ;jsr ResetWRAM      ; reset 7E0000 -> 7EFFFF
    lda #$01              
    jsr ResetWRAM       ; reset 7F0000 -> 7FFFFF

    phk                 ; \ äata bank = ðrogramm bank
    plb                 ; /

    cli                 ; enable interrupts

.endm


; CPU initialization (see nintendo dev book 1 ch.26)
ResetCPU
    php
    sep #$20            ; set A size to 8-bit
    pha

    stz NMITIMEM        ; Disable vblank, timer and standard controller interrupts
    lda #$FF
    sta WRIO            ; No info about out 0xFF in programmable IO port
    stz WRMPYA
    stz WRMPYB
    stz WRDIVL
    stz WRDIVB
    stz WRDIVH
    stz HTIMEL
    stz HTIMEH
    stz VTIMEL
    stz VTIMEH
    stz MDMAEN
    stz HDMAEN
    stz MEMSEL

    pla
    plp
    rts


; PPU initialization (see nintendo dev book 1 ch.26)
ResetPPU
    php
    sep #$20            ; set A size to 8-bits
    pha

    ; Screen, BG &  OAM
    lda #$80
    sta INIDISP         ; force V-Blank, zero brightness
    stz OBJSEL
    stz OAMADDL
    stz OAMADDH
    stz BGMODE
    stz MOSAIC
    stz BG1SC
    stz BG2SC
    stz BG3SC
    stz BG4SC
    stz BG12NBA
    stz BG34NBA
    stz BG1H0FS
    stz BG1V0FS
    stz BG2H0FS
    stz BG2V0FS
    stz BG3H0FS
    stz BG3V0FS
    stz BG4H0FS
    stz BG4V0FS

    ; VRAM
    lda #$80
    sta VRAMINC         ; VRAM address incremented after write
    stz VRAMADDL
    stz VRAMADDH

    ; Mode 7
    stz  M7SEL
    stz M7A
    lda #$01
    sta M7A             ; identity matrix (mode 7)
    stz M7B
    stz M7B
    stz M7C
    stz M7C
    stz M7D
    sta M7D             ; identity matrix (mode 7)
    stz M7X
    stz M7X
    stz M7Y
    stz M7Y

    ; CGRAM write
    stz CGADD

    ; Window Mask
    stz W12SEL
    stz W34SEL
    stz WOBJSEL
    stz WH0
    stz WH1
    stz WH2
    stz WH3
    stz WBGLOG
    stz WOBJLOG

    ; Screen, add/sub/col
    stz TM
    stz TS
    stz TMW
    stz TSW
    lda #$30
    sta CGSWSEL         ; Fixed color add/sub OFF     
    stz CGADSUB
    lda #$E0
    sta COLDATA         ; black color

    stz  SETINI

    pla
    plp 
    rts


; VRAM reset (clear memory) with DMA
ResetVRAM
    pha
    php

    sep #$20            ; set A to 8-bits size
    
    lda #$80
    sta VRAMINC         ; increase 2 bytes VRAM address on write

    lda #%00001001      ; CPU -> PPU, fixed address, VRAM write L/H
    sta DMAPARAM0       ; set DMA parameters for channel 0
    lda #$18
    sta DMABBUSADDR0    ; set DMA B bus address dst to 2118/2119 (L/H)
                        ; (data VRAM write)

    stz VRAMADDL        ; dst address in VRAM
    stz VRAMADDH        ; at 0x0000

    lda #$00            ; black 
    sta $0000           ; fill pixel stored in RAM 
    stz DMAABUSADDR0L   ; set DMA A bus address src to 00 (low)
    stz DMAABUSADDR0H   ; set DMA A bus address src to 00 (high)
    stz DMABANK0        ; set source bank to 00

    lda #$FF
    sta DMADATASIZE0L   ; FFFFh bytes
    sta DMADATASIZE0H   ; to transfer (64 Kb of VRAM - 1 byte)

    lda #$1
    sta MDMAEN          ; execute DMA transfer for channel 0
    
    stz VMDATAHW        ; do not forget to clear last byte

    plp
    pla    
    rts


; Palette reset (CGRAM clear memory) with DMA
ResetCGRAM
    pha
    php

    sep #$20            ; set 8-bit A

    lda #%00001000      ; set DMA parameters for channel 0
    sta DMAPARAM0       ; CPU -> PPU, fixed address, 1 byte address

    lda #$22            ; set DMA B bus address dst to 2122
    sta DMABBUSADDR0    ; (data CGRAM write)

    stz $0000           ; black fill color stored in RAM 
    stz DMAABUSADDR0L   ; set DMA A bus address src to 00 (low)
    stz DMAABUSADDR0H   ; set DMA A bus address src to 00 (high)
    stz DMABANK0        ; set source bank to 00

    stz DMADATASIZE0L   ; 100h * 2 bytes (BG + FG)
    lda #$02            ; to transfer (512 bytes of CGRAM)
    sta DMADATASIZE0H

    lda #$1
    sta MDMAEN          ; execute DMA transfer for channel 0

    plp
    pla    
    rts


; OAM reset (make all sprites off screen)
ResetOAM
    pha
    phx
    php

    sep #$20            ; set 8-bit A
    rep #$10

    stz OAMADDL         ; \ Start from OAM
    stz OAMADDH         ; / address 0
    
    ldx #128            ; Loop through 128 sprites
    lda #$F0
ResetOAM_clear:
    stz OAMDATAW        ; set sprite x = 0
    sta OAMDATAW        ; set sprite y = 240
    stz OAMDATAW        ; first sprite character is 0
    stz OAMDATAW        ; 1st palette, no flip, priority 0
    dex                 ; next sprite
    bne ResetOAM_clear
    
    ldx #32             ; loop though extra obj properties (2 bits / obj, 128 obj)
ResetOAM_clear_extra:
    stz OAMDATAW        ; small size, extra x coord = 0
    dex
    bne ResetOAM_clear_extra
    
    plp
    plx
    pla
    rts


stx ResetWRAM_ret: .dw $0000

; Reset WRAM with null bytes
; parameter: A = 1 bit (0=7E0000,1=7F0000 starting address)
; TODO: fix if A=0 as we will erase our own stack in 7E0000-7E1FFF
ResetWRAM
    pha
    phx
    php

    sep #$20            ; set 8-bit A
    rep #$10            ; set 16-bit X/Y
    pha

    lda #%00001000      ; A bus -> B bus, fixed address, 1 addr write
    sta DMAPARAM0       ; set DMA parameters for channel 0
    lda #$80
    sta DMABBUSADDR0    ; set DMA B bus address dst to CPU, WRAM

    stz WMADDL          ; \
    stz WMADDM          ;  | destination address in WRAM = 0x0000
    pla                 ;  | 7E0000, 7F0000 depending of arg bit
    sta WMADDH          ; /

    ldx #wram_zero_byte
    stx DMAABUSADDR0L   ; set DMA A bus address src to 00 (low+high)
    lda #:wram_zero_byte
    sta DMABANK0        ; set source bank to 00

    stz DMADATASIZE0L   ; 10000h bytes
    stz DMADATASIZE0H   ; to transfer (64 Kb of WRAM)

    lda #$1
    sta MDMAEN          ; execute DMA transfer for channel 0

    plp
    plx
    pla
    rts

wram_zero_byte: .db $00

; Copy palette data to CGRAM using DMA
; destination offset in CGRAM must be set prior in CGADD
; arguments: A = src bank, X = src bank offset, Y = count 
DMACGRamWrite_
    pha
    php

    sep #$20                ; set 8-bit A
    rep #$10                ; set 16-bit X/Y
    
    stz DMAPARAM0           ; set DMA parameters for channel 0
                            ; CPU -> PPU, auto inc, 1 byte address
    stx DMAABUSADDR0L       ; set DMA A bus address dst (low + high)

    sta DMABANK0            ; set source bank
    lda #$22                ; set DMA B bus address source to 2122 (CGDATAW)
    sta DMABBUSADDR0        ; (data CGRAM write)


    sty DMADATASIZE0L       ; nb bytes to copy

    lda #$01
    sta MDMAEN              ; execute DMA transfer

    plp
    pla
    rts

.macro DMACGRamWrite ARGS src,dst_offset,count

    lda #\2
    sta CGADD               ; write at given address in CGRAM

    lda #:\1
    ldx #\1
    ldy #\3
    jsr DMACGRamWrite_

.endm


; Copy data to VRAM using DMA
; destination offset in VRAM must be set prior in VRAMADDL
; arguments: A = src bank, X = src bank offset, Y = count 
DMAVramWrite_
    pha
    php

    sep #$20                ; set 8-bit A
    rep #$10                ; set 16-bit X/Y

    sta DMABANK0            ; set source bank

    lda #$80
    sta VRAMINC             ; increase 2 bytes VRAM address on write

    lda #%00000001          ; CPU -> PPU, fixed address, VRAM write L/H
    sta DMAPARAM0           ; set DMA parameters for channel 0
    lda #$18
    sta DMABBUSADDR0        ; set DMA B bus address source to 2118/2119 (L/H)
                            ; (data VRAM write)
       
    stx DMAABUSADDR0L       ; set DMA A bus address src (low+high)
    
    sty DMADATASIZE0L       ; n bytes to transfer

    lda #$1
    sta MDMAEN              ; execute DMA transfer for channel 0

    plp
    pla
    rts


.macro DMAVramWrite ARGS src,dst_offset,count

    ldx #\2
    stx VRAMADDL            ; write at given address in VRAM

    lda #:\1
    ldx #\1
    ldy #\3

    jsr DMAVramWrite_       ; Do DMA
.endm


; Copy data to OAM using DMA
; arguments: A = src bank, X = src bank offset, Y = count 
DMAOAMWrite_
    pha
    php

    sep #$20                ; set 8-bit A
    rep #$10                ; set 16 bit X/Y

    stz DMAPARAM0           ; set DMA parameters for channel 0
                            ; CPU -> PPU, auto inc, 1 byte address
    pha
    lda #$04
    sta DMABBUSADDR0        ; set DMA A bus address dst to $2104 (OAM write)
    stz OAMADDL             ; \ OAM dst address
    stz OAMADDH             ; / to 0

    pla
    sta DMABANK0            ; set src bank
    stx DMAABUSADDR0L       ; src offset in bank

    sty DMADATASIZE0L       ; nb bytes to copy

    lda #$01
    sta MDMAEN              ; execute DMA transfer
      
    plp
    pla
    rts


.macro DMAOAMWrite ARGS src_bank,src_offset,count
    lda #\1
    ldx #\2
    ldy #\3

    jsr DMAOAMWrite_       ; Do DMA
.endm


; VRAM write function
; arguments: X = value to store, Y = dst in VRAM
VramWrite
    pha
    php

    sep #$20                ; set 8-bit A

    lda #$80
    sta VRAMINC             ; increase 2 bytes VRAM address on write
    sty VRAMADDL            ; dst address in VRAM
    stx VMDATALW

    plp
    pla
    rts


; Initialize BG mode 3
; BG1 tile map at 0x4000 in VRAM
; BG1 chr data at 0x0000 in VRAM
; BG1 is activated before return
InitBGMode3
    pha
    php

    sep #$20                ; set 8-bit A

    lda #$03
    sta BGMODE              ; set bg mode 3, 8x8 tiles, 32x32 tilemap, SCO-SC1
    
    lda #%00000101
    sta BG1SC               ; set BG tilemap at 0x400 in VRAM
 
    lda #$01
    sta BG12NBA             ; set BG character data at 0x1000 in VRAM  

    stz BG1H0FS             ; \
    stz BG1H0FS             ;  | No BG1
    stz BG1V0FS             ;  | scroll
    stz BG1V0FS             ; /

    lda #%00000001
    sta TM                  ; activate BG1 on main screen

    plp
    pla
    rts


; Initialize snes OBJs (or sprites)
; 32x32 (small) + 64x64 (large) sprites
InitObjects
    pha
    php
    
    sep #$20                ; set 8-bit A

    lda #%01100011          ;
    sta OBJSEL              ; intialize OBJ subsytem
                            ; set sprite 16x16 / 32x32
                            ; character data (name base) at 0x6000 in VRAM

    lda TM
    ora #%00010000
    sta TM                  ; enable sprites on main screen

    plp
    pla
    rts

