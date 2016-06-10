;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  SNES hardware information: CPU, PPU,...  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;
;  CPU  ;
;;;;;;;;;
.define NMITIMEM        $4200       ; enable flag for v-blank, timer int & controller
.define WRIO            $4201       ; programmable IO port (out)
.define WRMPYA          $4202       ; \ multiplier & multiplicand
.define WRMPYB          $4203       ; / for multiplication
.define WRDIVL          $4204       ; \
.define WRDIVB          $4205       ;  | Divisor / dividend
.define WRDIVH          $4206       ; /
.define HTIMEL          $4207       ; \ H-count timer
.define HTIMEH          $4208       ; / settings
.define VTIMEL          $4209       ; \ V-count timer
.define VTIMEH          $420A       ; / settings
.define MDMAEN          $420B       ; channel designation for DMA & trigger
.define HDMAEN          $420C       ; channel designation for HDMA
.define MEMSEL          $420D       ; access cycle designation in memory

.define RDNMI           $4210       ; NMI flag (vblank) & version number

; DMA specifics
.define DMAPARAM0       $4300       ; DMA transfer parameters channel 0
.define DMAPARAM1       $4310       ; DMA transfer parameters channel 1
.define DMAPARAM2       $4320       ; DMA transfer parameters channel 2
.define DMAPARAM3       $4330       ; DMA transfer parameters channel 3
.define DMAPARAM4       $4340       ; DMA transfer parameters channel 4
.define DMAPARAM5       $4350       ; DMA transfer parameters channel 5
.define DMAPARAM6       $4360       ; DMA transfer parameters channel 6
.define DMAPARAM7       $4370       ; DMA transfer parameters channel 7
.define DMABBUSADDR0    $4301       ; B bus addresss for DMA channel 0
.define DMABBUSADDR1    $4311       ; B bus addresss for DMA channel 1
.define DMABBUSADDR2    $4321       ; B bus addresss for DMA channel 2
.define DMABBUSADDR3    $4331       ; B bus addresss for DMA channel 3
.define DMABBUSADDR4    $4341       ; B bus addresss for DMA channel 4
.define DMABBUSADDR5    $4351       ; B bus addresss for DMA channel 5
.define DMABBUSADDR6    $4361       ; B bus address for DMA channel 6
.define DMABBUSADDR7    $4371       ; B bus address for DMA channel 7
.define DMAABUSADDR0L   $4302       ; B bus addresss for DMA channel 0 (low)
.define DMAABUSADDR1L   $4312       ; B bus addresss for DMA channel 1 (low)
.define DMAABUSADDR2L   $4322       ; B bus addresss for DMA channel 2 (low)
.define DMAABUSADDR3L   $4332       ; B bus addresss for DMA channel 3 (low)
.define DMAABUSADDR4L   $4342       ; B bus addresss for DMA channel 4 (low)
.define DMAABUSADDR5L   $4352       ; B bus address for DMA channel 5 (low)
.define DMAABUSADDR6l   $4362       ; B bus addresss for DMA channel 6 (low)
.define DMAABUSADDR7L   $4372       ; B bus address for DMA channel 7 (low)
.define DMAABUSADDR0H   $4303       ; B bus address for DMA channel 0 (high)
.define DMAABUSADDR1H   $4313       ; B bus address for DMA channel 1 (high)
.define DMAABUSADDR2H   $4323       ; B bus address for DMA channel 2 (high)
.define DMAABUSADDR3H   $4333       ; B bus address for DMA channel 3 (high)
.define DMAABUSADDR4H   $4343       ; B bus address for DMA channel 4 (high)
.define DMAABUSADDR5H   $4353       ; B bus address for DMA channel 5 (high)
.define DMAABUSADDR6H   $4363       ; B bus address for DMA channel 6 (high)
.define DMAABUSADDR7H   $4373       ; B bus address for DMA channel 7 (high)
.define DMABANK0        $4304       ; Bank for DMA channel 0
.define DMABANK1        $4314       ; Bank for DMA channel 1
.define DMABANK2        $4324       ; Bank for DMA channel 2
.define DMABANK3        $4334       ; Bank for DMA channel 3
.define DMABANK4        $4344       ; Bank for DMA channel 4
.define DMABANK5        $4354       ; Bank for DMA channel 5
.define DMABANK6        $4364       ; Bank for DMA channel 6
.define DMABANK7        $4374       ; Bank for DMA channel 7
.define DMADATASIZE0L   $4305       ; Data size to transfer for DMA channel 0 (low)
.define DMADATASIZE1L   $4315       ; Data size to transfer for DMA channel 1 (low)
.define DMADATASIZE2L   $4325       ; Data size to transfer for DMA channel 2 (low)
.define DMADATASIZE3L   $4335       ; Data size to transfer for DMA channel 3 (low)
.define DMADATASIZE4L   $4345       ; Data size to transfer for DMA channel 4 (low)
.define DMADATASIZE5L   $4355       ; Data size to transfer for DMA channel 5 (low)
.define DMADATASIZE6L   $4365       ; Data size to transfer for DMA channel 6 (low)
.define DMADATASIZE7L   $4375       ; Data size to transfer for DMA channel 7 (low)
.define DMADATASIZE0H   $4306       ; Data size to transfer for DMA channel 0 (high)
.define DMADATASIZE1H   $4316       ; Data size to transfer for DMA channel 1 (high)
.define DMADATASIZE2H   $4326       ; Data size to transfer for DMA channel 2 (high)
.define DMADATASIZE3H   $4336       ; Data size to transfer for DMA channel 3 (high)
.define DMADATASIZE4H   $4346       ; Data size to transfer for DMA channel 4 (high)
.define DMADATASIZE5H   $4356       ; Data size to transfer for DMA channel 5 (high)
.define DMADATASIZE6H   $4366       ; Data size to transfer for DMA channel 6 (high)
.define DMADATASIZE7H   $4376       ; Data size to transfer for DMA channel 7 (high)


;;;;;;;;;
;  PPU  ;
;;;;;;;;;

; Init
.define INIDISP     $2100       ; initial settings for screen
.define OBJSEL      $2101       ; object size & data area designation

; OAM write
.define OAMADDL     $2102       ; \ addresss for accessing
.define OAMADDH     $2103       ; / OAM
.define OAMDATAW    $2104       ; data for OAM write

; Backgrounds, scrolling & screen
.define BGMODE      $2105       ; BG mode & characters size settings
.define MOSAIC      $2106       ; size & screen designation for mosaic display
.define BG1SC       $2107       ; \
.define BG2SC       $2108       ;  \ addresss for storing sc-data of each
.define BG3SC       $2109       ;  / BG et SC size designation
.define BG4SC       $210A       ; /
.define BG12NBA     $210B       ; \ BG character data
.define BG34NBA     $210C       ; / area designation
.define BG1H0FS     $210D       ; \ H/V scroll value definition
.define BG1V0FS     $210E       ; / for BG1
.define BG2H0FS     $210F       ; \ H/V scroll value definition
.define BG2V0FS     $2110       ; / for BG2
.define BG3H0FS     $2111       ; \ H/V scroll value definition
.define BG3V0FS     $2112       ; / for BG3
.define BG4H0FS     $2113       ; \ H/V scroll value definition
.define BG4V0FS     $2114       ; / for BG4

; VRAM
.define VRAMINC     $2115       ; VRAM addresss increment value
.define VRAMADDL    $2116       ; \ addresss for VRAM
.define VRAMADDH    $2117       ; / read & write
.define VMDATALW    $2118       ; \ data for WRAM
.define VMDATAHW    $2119       ; / write

; Mode 7
.define M7SEL       $211A       ; Initial setting for mode 7
.define M7A         $211B       ; \
.define M7B         $211C       ;  \
.define M7C         $211D       ;   | Mode 7 rotation, enlargement & reduction mode 7
.define M7D         $211E       ;   | center coordinate settings & multiplier
.define M7X         $211F       ;  /
.define M7Y         $2120       ; /

; CGRAM write
.define CGADD       $2121       ; addresss for CGRAM read & write
.define CGDATAW     $2122       ; data for CGRAM write

; Window Mask
.define W12SEL      $2123       ; \
.define W34SEL      $2124       ;  | Window mask settings (BGX, obj & col)
.define WOBJSEL     $2125       ; /
.define WH0         $2126       ; Window 1 left
.define WH1         $2127       ; Window 1 right
.define WH2         $2128       ; Window 2 left
.define WH3         $2129       ; Window 2 right
.define WBGLOG      $212A       ; \ Mask logic settings for
.define WOBJLOG     $212B       ; / Window 1 & 2

; Scree, add/sub/col
.define TM          $212C       ; Main screen designation
.define TS          $212D       ; Sub-screen designation
.define TMW         $212E       ; Windows mask designation for main screen
.define TSW         $212F       ; Window masl designation for sub screen
.define CGSWSEL     $2130       ; Init settings for fixed color add or screen add
.define CGADSUB     $2131       ; add/sub for each BG & BG color
.define COLDATA     $2132       ; fixed color data for fixed col add/sub

.define SETINI      $2133       ; screen initial settings

; Multiplication
.define MPYL        $2134       ; \
.define MPYM        $2135       ;  | Multiplication reult
.define MPYH        $2136       ; /

.define SLHV        $2137       ; software latch for H/V counter

; OAM read
.define OAMDATAR    $2138       ; read data from OAM
.define VMDATALR    $2139       ; \ read data from
.define VMDATAHR    $213A       ; / VRAM

; CGRAM read
.define CGDATAR     $213B       ; read data from CGRAM

.define OPHCT       $213C       ; \ H/V counter data by external
.define OPVCT       $213D       ; / or software latch

; Various
.define STAT77      $213E       ; PPU status flag & version number
.define STAT88      $213F       ; same

; APU
.define APUIO1      $2140       ; \
.define APUIO2      $2141       ;  \ Communication port
.define APUIO3      $2142       ;  / with APU
.define APUIO4      $2143       ; /

; WRAM addresssing modes
.define WMDATA      $2180       ; data to consecutively read and write to WRAM
.define WMADDL      $2181       ; \
.define WMADDM      $2182       ;  | addresss to consecutively read/write WRAM
.define WMADDH      $2183       ; /
