.segment "HEADER"
.byte "NES"             ; Beginning of the iNES header
.byte $1a               ; Signature of the NES ROM
.byte $02               ; 2 x 16KB PRG ROM
.byte $01               ; 1 x  8KB CHR ROM
.byte %00000000         ; Mapper and mirroring
.byte $00
.byte $00
.byte $00
.byte $00
.byte $00, $00, $00, $00, $00   ; filler bytes

.segment "ZEROPAGE"
.segment "STARTUP"
Reset:
    sei                 ; Disables all interrupts
    cld                 ; Disable decimal mode (Not supported by default)

    ;; Disable sound IRQ
    ldx #$40
    stx $4017

    ;; Initialize the stack register
    ldx #$ff
    txs
    inx

    ;; Zero out PPU registers
    stx $2000
    stx $2001

    ;; Disable PCM channel
    stx $4010

    :
    bit $2002           ; test bits with A
    bpl :-              ; branch on N = 0

    txa

ClearMem:
    sta $0000, x
    sta $0100, x
    sta $0300, x
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x
    ; lda #$ff
    sta $0200, x
    lda #$00
    inx
    bne ClearMem

; wait for vblank
:
    bit $2002
    bpl :-

    lda #$02
    sta $4014       ; OAM DMA (sprite mem)
    nop             ; Burn a cycle to give PPU time to
                    ; finish a mem transfer

;; Write Palette memory
    lda #$3f
    sta $2006       ; tell PPU that we want to start off writing data at #$3f0
    lda #$00
    sta $2006

    ldx #$00

LoadPalettes:
    lda PaletteData, x
    sta $2007       ; write data to draw into PPU memory, locations are $3f00, $3f01, ..., $3f20z
    inx
    cpx #$20
    bne LoadPalettes

    ldx #$00
LoadSprites:
    lda SpriteData, x
    sta $0200, x
    inx
    cpx #$40
    bne LoadSprites

; Enable interrupts
    cli
    lda #%10010000
    sta $2000       ; enable NMI, change background to use second chr set of tiles ($1000)
    lda #%00011110
    sta $2001       ; enabling sprites and background for 8 pixels

Loop:
    jmp Loop

NMI:
    lda #$02        ; copy sprite data from $0200
    sta $4014

    rti

PaletteData:
    .byte $22,$29,$1A,$0F,$22,$36,$17,$0f,$22,$30,$21,$0f,$22,$27,$17,$0F  ;background palette data
    .byte $22,$16,$27,$18,$22,$1A,$30,$27,$22,$16,$30,$27,$22,$0F,$36,$17  ;sprite palette data

SpriteData:
    ; y-pos, tile#, attr, x-pos
    .byte $08, $00, $00, $08
    .byte $08, $01, $00, $10
    .byte $10, $02, $00, $08
    .byte $10, $03, $00, $10
    .byte $18, $04, $00, $08
    .byte $18, $05, $00, $10
    .byte $20, $06, $00, $08
    .byte $20, $07, $00, $10

    .byte $08, $08, $00, $1a
    .byte $08, $09, $00, $22
    .byte $10, $0a, $00, $1a
    .byte $10, $0b, $00, $22
    .byte $18, $0c, $00, $1a
    .byte $18, $0d, $00, $22
    .byte $20, $0e, $00, $1a
    .byte $20, $0f, $00, $22

.segment "VECTORS"
;; Interrupts handler labels
.word NMI
.word Reset         ; reset button press

.segment "CHARS"
    .incbin "mario.chr"