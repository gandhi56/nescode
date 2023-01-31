.segment "HEADER"
    .byte "NES"         ; identification string
    .byte $1a
    .byte $02           ; amount of PRG ROM in 16k units
    .byte $01           ; amount of CHR ROM in 8k units
    .byte $00           ; mapper and mirroring
    .byte $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00
.segment "ZEROPAGE"
VAR:    .RES 1  ; reserves 1 byte of memory
.segment "STARTUP"

RESET:
    sei         ; disable interrupts
    cld         ; turn off decimal mode
    ldx #%10000000  ; disable sound IRQ
    stx $4017
    ldx #$00
    stx $4010       ; disable PCM

    ; initialize stack register
    ldx #$ff
    txs             ; transfer x to the stack

    ; clear PPU registers
    ldx #$00
    stx $2000
    stx $2001

    ; wait for vblank
:
    bit $2002
    bpl :-

    ; clearing up 2k memory
    txa

CLEARMEMORY:
    sta $0000, x
    sta $0100, x
    sta $0300, x
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x
    lda #$ff
    sta $0200, x
    lda #$00
    inx
    cpx #$00
    bne CLEARMEMORY

    ; wait for vblank
:
    bit $2002
    bpl :-
    
    ; setting sprite range
    lda #$02
    sta $4014

    nop

    ; setting palette data
    lda #$3f
    sta $2006
    lda #$00
    sta $2006

    ldx #$00
LOADPALETTES:
    lda PALETTEDATA, x
    sta $2007
    inx
    cpx #$20
    bne LOADPALETTES

    ldx #$00
LOADSPRITES:
    lda SPRITEDATA, x
    sta $0200, x
    inx
    cpx #$20
    bne LOADSPRITES

LOADBACKGROUND:
    lda $2002           ; read PPU status to reset high/low latch
    lda #$21
    sta $2006
    lda #$00
    sta $2006
    ldx #$00

LOADBACKGROUNDP1:
    lda BACKGROUNDDATA, x
    sta $2007
    inx
    cpx #$00
    bne LOADBACKGROUNDP1

LOADBACKGROUNDP2:
    lda BACKGROUNDDATA+256, x
    sta $2007
    inx
    cpx #$00
    bne LOADBACKGROUNDP2

    ;LOAD BACKGROUND PALETTEDATA
	lda #$23	;$23D0
	sta $2006
	lda #$D0
	sta $2006
	ldx #$00

LOADBACKGROUNDPALETTEDATA:
	lda BACKGROUNDPALETTEDATA, X
	sta $2007
	inx
	cpx #$20
	bne LOADBACKGROUNDPALETTEDATA

	;RESET SCROLL
	lda #$00
	sta $2005
	sta $2005

; Enable interrupts
    cli
    lda #%10010000
    sta $2000           ; when vblank occurs, call nmi
    lda #%00011110      ; show sprites and background
    sta $2001

INFLOOP:
    jmp INFLOOP

NMI:
    lda #$02            ; load sprite range
    sta $4014
    rti

PALETTEDATA:
	.byte $00, $0F, $00, $10, 	$00, $0A, $15, $01, 	$00, $29, $28, $27, 	$00, $34, $24, $14 	;background palettes
	.byte $31, $0F, $15, $30, 	$00, $0F, $11, $30, 	$00, $0F, $30, $27, 	$00, $3C, $2C, $1C 	;sprite palettes

SPRITEDATA:
;Y, SPRITE NUM, attributes, X
;76543210
;||||||||
;||||||++- Palette (4 to 7) of sprite
;|||+++--- Unimplemented
;||+------ Priority (0: in front of background; 1: behind background)
;|+------- Flip sprite horizontally
;+-------- Flip sprite vertically

	.byte $40, $00, $00, $40
	.byte $40, $01, $00, $48
	.byte $48, $10, $00, $40
	.byte $48, $11, $00, $48
	
	;sword
	.byte $50, $08, %00000001, $80
	.byte $50, $08, %01000001, $88
	.byte $58, $18, %00000001, $80
	.byte $58, $18, %01000001, $88


BACKGROUNDDATA:	;512 BYTES
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$03,$04,$05,$00,$00,$00,$00,$00,$00,$00,$06,$07,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$08,$09,$0a,$0b,$0b,$0b,$0c,$0d,$0e,$0f,$10,$11,$56,$13,$14,$0b,$15,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$16,$17,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$18,$19,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$1a,$1b,$1c,$1d,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$1e,$06,$1f,$00,$00,$00,$00,$00
	.byte $00,$00,$20,$21,$22,$23,$18,$24,$25,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$26,$27,$28,$00,$29,$2a,$00,$00,$00,$00,$00
	.byte $00,$00,$2b,$2c,$2d,$0b,$11,$2e,$2f,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$30,$31,$32,$33,$34,$35,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$36,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$18,$37,$38,$39,$3a,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$3b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$3c,$3d,$3e,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$3f,$40,$0b,$0b,$0b,$41,$42,$43,$44,$0b,$0b,$45,$0b,$0b,$0b,$0b,$46,$47,$48,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$49,$0b,$0b,$4a,$4b,$00,$4c,$4d,$0b,$4e,$4f,$50,$0b,$0b,$51,$00,$52,$53,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$3f,$54,$55,$12,$00,$00,$00,$57,$58,$59,$00,$5a,$5b,$5c,$5d,$00,$5e,$5f,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$60,$61,$00,$00,$62,$63,$64,$65,$00,$66,$67,$68,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$69,$00,$00,$6a,$6b,$6c,$00,$6d,$6e,$6f,$70,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$71,$72,$73,$0b,$74,$75,$76,$77,$78,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$79,$7a,$7b,$7c,$7d,$7e,$7f,$80,$81,$82,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$4c,$83,$84,$85,$86,$35,$87,$00,$00,$00,$00,$00,$00

BACKGROUNDPALETTEDATA:	;32 bytes
	.byte $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55
	.byte $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55

.segment "VECTORS"
    .word NMI   ; nonmaskable interrupt
    .word RESET ; reset event handler
    ; specialized hardware interrupts

.segment "CHARS"
.incbin "cart-rom.chr"
