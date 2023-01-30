PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
PPUADDR   = $2006
PPUDATA   = $2007
OAMADDR   = $2003
OAMDMA    = $4014

.segment "HEADER"
.byte $4e, $45, $53, $1a ; Magic string that always begins an iNES header
.byte $02        ; Number of 16KB PRG-ROM banks
.byte $01        ; Number of 8KB CHR-ROM banks
.byte %00000001  ; Vertical mirroring, no save RAM, no mapper
.byte %00000000  ; No special-case flags set, no mapper
.byte $00        ; No PRG-RAM present
.byte $00        ; NTSC format

.segment "STARTUP"
.segment "CODE"
.proc irq_handler
    rti
.endproc

.proc nmi_handler
    lda #$00
    sta OAMADDR
    lda #$02
    sta OAMDMA
    rti
.endproc

.proc reset_handler
    sei
    cld
    ldx #$00
    stx PPUCTRL
    stx PPUMASK
vblankwait:
    bit PPUSTATUS
    bpl vblankwait
.endproc

.proc main
    ;; Prepare PPU to load a palette
    ldx PPUSTATUS
    ldx #$3f
    stx PPUADDR
    ldx #$00
    stx PPUADDR

    ;; Load palette into PPU
    ldx #$00
LoadPalette:
    lda PaletteData, x
    sta PPUDATA
    inx
    cpx #$04
    bne LoadPalette

    ;; Load sprites into PPU
    ldx #$00
LoadSprites:
    lda SpriteData, x
    sta $0200, x
    inx
    cpx #$08
    bne LoadSprites

vblankwait:       ; wait for another vblank before continuing
    bit PPUSTATUS
    bpl vblankwait

    lda #%10010000  ; turn on NMIs, sprites use first pattern table
    sta PPUCTRL
    lda #%00011110  ; turn on screen
    sta PPUMASK

forever:
    jmp forever
.endproc

PaletteData:
    .byte $0f,$19,$09,$0f

SpriteData:
    .byte $70,$07,$00,$80
    .byte $70,$08,$00,$88

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "CHARS"
.incbin "graphics.chr"