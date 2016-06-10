;;;;;;;;;;;;;;;;;;;
;  Memory layout  ;
;;;;;;;;;;;;;;;;;;;

.MEMORYMAP
    SLOTSIZE $8000                  ; Slot size is $8000 bytes (LoROM)
    DEFAULTSLOT 0                   ; Only 1 slot on SNES
    SLOT 0 $8000                    ; Slot starting address
.ENDME

.ROMBANKSIZE $8000                  ; Each bank owns 32kb (LoROM)
.ROMBANKS 3                         ; 1 bank will be used at all


;;;;;;;;;;;;;;;;;;;;;
;  Snes ROM header  ;
;;;;;;;;;;;;;;;;;;;;;

.SNESHEADER
    ID "SNES"                       ; 1-4 letter string, just leave it as "SNES"
    NAME "From 80s with love :)"    ; ROM name (max 21 bytes)
    FASTROM	                        ; ROM chips are 120ns chips
    LOROM                           ; LoROM type

    CARTRIDGETYPE $00               ; ROM only
    ROMSIZE $08                     ; 2 Mbits
    SRAMSIZE $00                    ; No SRAM
    COUNTRY $02                     ; All Europe
    LICENSEECODE $00                ; We don't care :)
    VERSION $00                     ; 1.0
.ENDSNES


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Interruptions tables  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Define Native Mode interrupt vector table
.SNESNATIVEVECTOR
    BRK 	EmptyHandler
    ABORT 	EmptyHandler
    NMI 	ProcVblank      ; VBlank - NMI interrupt
    IRQ 	EmptyHandler
.ENDNATIVEVECTOR


; Define Emulation Mode interrupt vector table
.SNESEMUVECTOR
    COP 	EmptyHandler
    ABORT 	EmptyHandler
    NMI 	EmptyHandler
	RESET	Start           ; ROM code entry point
	IRQBRK	EmptyHandler
.ENDEMUVECTOR

.BANK 0 SLOT 0              ; ROM and slot used by code
.ORG 0                      ; equiv to = $8000 as the slot starts at $8000

.SECTION "EmptyVectors" SEMIFREE

EmptyHandler:
    rti

.ENDS

.EMPTYFILL $00              ; Fill unused areas with $00, opcode for BRK  
                            ; BRK will crash the snes if executed

