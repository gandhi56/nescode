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
forever:
  jmp forever
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "CHARS"
.res 8192
.segment "STARTUP"