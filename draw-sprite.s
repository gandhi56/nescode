.segment "HEADER"
  ; .byte "NES", $1A      ; iNES header identifier
  .byte $4E, $45, $53, $1A
  .byte 2               ; 2x 16KB PRG code
  .byte 1               ; 1x  8KB CHR data
  .byte $01, $00        ; mapper 0, vertical mirroring

.segment "VECTORS"
  ;; When an NMI happens (once per frame if enabled) the label nmi:
  .addr nmi
  ;; When the processor first turns on or is reset, it will jump to the label reset:
  .addr reset
  ;; External interrupt IRQ (unused)
  .addr 0

; "nes" linker config requires a STARTUP section, even if it's empty
.segment "STARTUP"

; Main code segement for the program
.segment "CODE"

reset:
  sei		; disable IRQs
  cld		; disable decimal mode
  ldx #$40
  stx $4017	; disable APU frame IRQ
  ldx #$ff 	; Set up stack
  txs		;  .
  inx		; now X = 0
  stx $2000	; disable NMI
  stx $2001 	; disable rendering
  stx $4010 	; disable DMC IRQs

;; first wait for vblank to make sure PPU is ready
vblankwait1:
  bit $2002
  bpl vblankwait1

clear_memory:
  lda #$00
  sta $0000, x
  sta $0100, x
  sta $0200, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  inx
  bne clear_memory

;; second wait for vblank, PPU is ready after this
vblankwait2:
  bit $2002
  bpl vblankwait2

main:
load_palettes:
  lda $2002       ; Read PPU status to reset the high/low latch
  lda #$3f
  sta $2006       ; Write the high bits of value at $3f00
  lda #$00
  sta $2006       ; Write the low bits of value at $3f00
  ldx #$00

@loop:
  lda palettes, x
  sta $2007
  inx
  cpx #$20
  bne @loop

enable_rendering:
  lda #%10000000	; Enable NMI
  sta $2000
  lda #%00010000	; Enable Sprites
  sta $2001

nmi:
  ldx #$00 	; Set SPR-RAM address to 0
  stx $2003
@loop:	;lda hello, x 	; Load the hello message into SPR-RAM
  sta $2004
  inx
  cpx #$24
  bne @loop
  rti

palettes:
  .byte $22, $29, $1A, $0F
  .byte $22, $36, $17, $0F
  .byte $22, $30, $21, $0F
  .byte $22, $27, $17, $0F
  .byte $22, $16, $27, $18
  .byte $22, $1A, $30, $27
  .byte $22, $16, $30, $27
  .byte $00, $0F, $36, $17    ; Sprite

.segment "CHARS"

.incbin "mario.chr"
