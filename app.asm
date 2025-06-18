extern _ExitProcess@4
extern printInt
extern printText
extern intToText

global _main

section .data
value1:             dd  1526.667
acc:                dd  0
intRound:           dd  0
breakLine:          db  0xA
controlWord:        dw  0

rawBinary:          dd  0
biasedExponent:     db  0
exponent:           db  0
significand:        dd  0
integer:            dd  0
fraction:           dd  0

rawBinTxt:          db  "raw binary: "
rawBinTxtLen:       equ $ - rawBinTxt
biasExpTxt:         db  "biased exponent: "
biasExpTxtLen:      equ $ - biasExpTxt
expTxt:             db  "unbiased exponent: "
expTxtLen:          equ $ - expTxt
sigTxt:             db  "significand with J-bit: "
sigTxtLen:          equ $ - sigTxt
intTxt:             db  "integer: "
intTxtLen:          equ $ - intTxt
fracTxt:            db  "fraction: "
fracTxtLen:         equ $ - fracTxt
decimalToTxt:       db  "decimal representation: "
decimalToTxtLen:    equ $ - decimalToTxt
decimalPoint:       db  "."

section .text
_main:
    fld dword [value1]
    fst dword [acc]

    ;   raw binary
    mov eax, dword [acc]
    mov [rawBinary], eax

    push rawBinTxtLen
    push rawBinTxt
    call printText

    push dword [rawBinary]
    call printInt

    push 1
    push breakLine
    call printText

    ;   biased exponent
    mov eax, dword [acc]
    and eax, 0x7F80_0000
    shr eax, 23
    mov [biasedExponent], al

    push biasExpTxtLen
    push biasExpTxt
    call printText

    push dword [biasedExponent]
    call printInt

    push 1
    push breakLine
    call printText

    ;   unbiased exponent
    mov eax, dword [acc]
    and eax, 0x7F80_0000
    shr eax, 23
    sub eax, 127
    mov [exponent], al

    push expTxtLen
    push expTxt
    call printText

    push dword [exponent]
    call printInt

    push 1
    push breakLine
    call printText

    ;   significand
    mov eax, dword [acc]
    and eax, 0x7F_FFFF
    or eax, 0x80_0000
    mov [significand], eax

    push sigTxtLen
    push sigTxt
    call printText

    push dword [significand]
    call printInt

    push 1
    push breakLine
    call printText

    ;   integer
    fnstcw [controlWord]                ;   load control word
    or word [controlWord], 0x400        ;   change rounding mode to down
    fldcw [controlWord]                 ;   save control word
    fld st0
    frndint                             ;   round value in st0 to int
    fstp dword [intRound]
    mov eax, [intRound]
    and eax, 0x807F_FFFF
    or eax, 0x80_0000

    mov bl, [exponent]
    cmp bl, 0
    je .skipShift
    .shiftIntLeft:
        rol eax, 1
        dec bl
        cmp bl, 0
        jg .shiftIntLeft
    .skipShift:

    ror eax, 23
    mov [integer], eax

    push intTxtLen
    push intTxt
    call printText

    push dword [integer]
    call printInt

    push 1
    push breakLine
    call printText

    ;   fraction
    mov eax, dword [significand]

    mov bl, [exponent]
    cmp bl, 0
    je .skipFracShift
    .shiftFracLeft:
        shl eax, 1
        dec bl
        cmp bl, 0
        jg .shiftFracLeft
    .skipFracShift:

    and eax, 0x7F_FFFF                  ;   remove exponent digits
    mov esi, 1_000_000_000              ;   must be shifted right every iteration
    mov edi, 0x80_0000                  ;   logical AND for adding up to final result
    mov ecx, 0

    .loopFractionAsWhole:
        inc ecx
        cmp ecx, 10                     ;   nine iterations. Next iteration would result in a division by 2 with remainder
        jg .breakFractionAsWhole
        shr esi, 1
        shr edi, 1
        mov ebx, eax
        and ebx, edi
        cmp ebx, 0
        je .loopFractionAsWhole
        add [fraction], esi
        jmp .loopFractionAsWhole
    .breakFractionAsWhole:

    add dword [fraction], 1_000_000_000
        
    push fracTxtLen
    push fracTxt
    call printText

    push dword [fraction]
    call printInt

    push 1
    push breakLine
    call printText

    ;   decimal representation
    push decimalToTxtLen
    push decimalToTxt
    call printText

    push dword [integer]
    call printInt

    push 1
    push decimalPoint
    call printText

    push dword [fraction]
    call intToText

    inc eax
    push 9
    push eax
    call printText

    push 0
    call _ExitProcess@4