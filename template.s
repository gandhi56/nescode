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
    sei             ; disable interrupts
    cld             ; turn off decimal mode
    ldx #%10000000  ; disable sound IRQ
    stx $4017
    ldx #$00
    stx $4010       ; disable PCM

    ; Initialize stack register
    ldx #$ff
    txs             ; transfer x to the stack

    ; Clear PPU registers
    ldx #$00
    stx $2000
    stx $2001

    ; Wait for vblank
:
    bit $2002
    bpl :-

    ; Clearing up 2k memory
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

    ; Wait for vblank
:
    bit $2002
    bpl :-
    
;;; Draw here ...

;;; ---

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

;;; Add palette data, sprite data, background data, and so on...

;;; ---


.segment "VECTORS" ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
    .word NMI   ; nonmaskable interrupt
    .word RESET ; reset event handler
    ; specialized hardware interrupts

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //

.segment "CHARS" ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
; .incbin "CHR ROM filename"

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
