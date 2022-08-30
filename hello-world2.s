PPUCTRL = $2000
PPUMASK = $2001
PPUSTATUS = $2002
PPUADDR = $2006
PPUDATA = $2007
OAMADDR = $2003
OAMDMA = $4014

.segment "HEADER"
.byte $4e, $45, $53, $1a, $02, $01, $00, $00

.segment "CODE"
.proc irq_handler
  rti
.endproc

.proc nmi_handler
  lda #$00
  sta OAMADDR         ; location where in OAM to write to
  lda #$02
  sta OAMDMA          ; transfer the page
  rti
.endproc

.proc reset_handler
  sei
  cld
  ldx #$00
  stx $2000
  STX $2001
vblankwait:
  bit PPUSTATUS
  bpl vblankwait
  
  lda #%10010000      ; turn on NMIs, sprites use first pattern table
  sta PPUCTRL
  lda #%00011110      ; turn on screen
  sta PPUMASK

  jmp main
.endproc

.proc main
  ldx PPUSTATUS
  ldx #$3f
  stx PPUADDR
  ldx #$00
  stx PPUADDR
  lda #$31            ; select color
  sta PPUDATA         ; set background color
  lda #%00011110
  sta PPUMASK

  ; load a palette
  ldx PPUSTATUS
  ldx #$3f
  stx PPUADDR
  ldx #$00
  stx PPUADDR

load_palettes:
  lda palettes, X
  sta PPUDATA
  inx
  cpx #$10
  bne load_palettes

  ; write sprite data
  ldx #$00
load_sprites:
  lda sprites, X
  sta $0200, X
  inx
  cpx #$10
  bne load_sprites

forever:
  jmp forever
.endproc

.segment "RODATA"
palettes:
  .byte $29, $19, $09, $0f
  .byte $29, $29, $09, $1f
  .byte $29, $39, $09, $2f
  .byte $29, $f9, $09, $ef
sprites:  ; y-coord, index, attribute, x-coord
  .byte $70, $05, $00, $80
  .byte $80, $05, $00, $80
  .byte $90, $05, $00, $80
  .byte $a0, $05, $00, $80

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "CHARS"
.incbin "graphics.chr"

.segment "STARTUP"
