
; +-----------------+
; | Memory map      |
; +-----------------+
;
; $0000 - $0800 : Internal RAM, 2KB chip in the NES
; $2000 - $2007 : PPU access ports
;   $2000 - PPUCTRL
;   $2001 - PPUMASK
;   $2002 - PPUSTATUS
;   $2003 - OAMADDR
;   $2004 - OAMDATA
;   $2005 - PPUSCROLL
;   $2006 - PPUADDR
;   $2007 - PPUDATA
;
; $4000 - $4017 : Audio and controller access ports
; $6000 - $7FFF : Optional WRAM inside the game cart
; $8000 - $FFFF : Game cart ROM
;
; +-----------------+
; | iNES Header     |
; +-----------------+
;
; 16 byte iNES header gives the emulator all the
; information about the game including mapper,
; graphics mirroring, and PRG/CHR sizes. These
; can be included inside the asm at the very
; beginning.

  .inesprg 1    ; 1 x 16KB PRG code
  .ineschr 1    ; 1 x 8KB CHR data
  .inesmap 0    ; mapper 0 = NROM, no bank swapping
  .inesmir 1    ; background mirroring enabled

; +----------------------+
; | NES has powered on   |
; +----------------------+
;
  .bank 0
  .org $C000    ; Tells the assembler where to start this bank
RESET:
  sei           ; disable IRQs
  cld           ; disable decimal mode, meant to make decimal
                ; arithmetic "easier"
  ldx #$40
  stx $4017     ; disable APU frame IRQ
  ldx #$ff
  txs           ; set up stack
  inx           ; now X = 0
  stx $2000     ; disable NMI
  stx $2001     ; disable rendering
  stx $4010     ; disable DMC IRQs

vblankwait1:
  bit $2002
  bpl vblankwait1

; +----------------+
; | Clear memory   |
; +----------------+
;
clrmem:
  lda #$00
  sta $0000, x
  sta $0100, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  lda #$fe
  sta $0200, x  ; move all sprites off screen
  inx
  bne clrmem

vblankwait2:    ; second wait for vblank, PPU is ready after this
  bit $2002
  bpl vblankwait2

; +-----------------------+
; | Load game palettes    |
; +-----------------------+
;
LoadPalettes:
  lda $2002     ; read PPU status to reset high/low latch
  lda #$3f      ; max out 0011 1111
  sta $2006
  lda #$00
  sta $2006
  ldx #$00      ; start at 0

LoadPalettesLoop:
  lda palette, x
  sta $2007
  inx
  cpx #$20
  bne LoadPalettesLoop

MainLoop:
  lda #$00
  sta $2003     ; clear the low byte of the RAM address
  lda #$02
  sta $4014     ; set the high byte of the RAM address,
                ; start the transfer

  jsr Draw

  jsr Update

  rti           ; return from interrupt

; +-----------------------+
; | Data initialization   |
; +-----------------------+
; .db command is a macro for storing bytes
; in memory without having to write
  .bank 1
  .org $e000
palette:
    ;; Background Palletes (0-3)
  .db $08,$1A,$38,$18, $08,$02,$38,$3C, $08,$1C,$15,$14, $08,$02,$38,$2A
  ;;  Character Palletes (0-3)
  .db $21,$2C,$11,$15, $0F,$35,$36,$37, $0F,$39,$3A,$3B, $0F,$3D,$3E,$0F



; Define interrupt vectors at the top of memory $FFFF
; Basically registering callbacks for different functions
; NMI, RESET and IRQ.
;
; .org means starting at $FFFA
; .dw means store dataword
;   stores in little endian order (least significant bit first)

  .bank 1
  .org $FFFA    ; first of the three vectors starts here
nescallback:
  .dw MainLoop  ; when an NMI happens, jump to label NMI
  .dw Reset     ; when the processor is reset, jump to Reset
  .dw 0         ; external interrupt IRQ for audio

; Load in external sprites or audio data here
  .bank 2
  .org $0000
  .incbin "mario.chr"




















