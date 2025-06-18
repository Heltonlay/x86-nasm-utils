extern _ExitProcess@4
%include "./output/printInt.asm"
%include "./output/printText.asm"

global _main

section .data
value1:         dd  3.14
acc:            dd  0
breakLine:      db  0xA

biasedExponent: db  0
exponent:       db  0
significand:    dd  0
integer:        dd  0
fraction:       dd  0

biasExpTxt:     db  "biased exponent: "
biasExpTxtLen:  equ $ - biasExpTxt
expTxt:         db  "unbiased exponent: "
expTxtLen:      equ $ - expTxt
sigTxt:         db  "significand with J-bit: "
sigTxtLen:      equ $ - sigTxt
intTxt:         db  "integer: "
intTxtLen:      equ $ - intTxt
fracTxt:        db  "fraction: "
fracTxtLen:     equ $ - fracTxt
floatToTxt:     db  "float ascii representation: "
floatToTxtLen:  equ $ - floatToTxt
decimalPoint:   db  "."

section .text
_main:
    fld dword [value1]
    fst dword [acc]

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
    mov eax, dword [significand]

    mov bl, [exponent]
    cmp bl, 0
    je .skipShift
    .shiftIntLeft:
        shl eax, 1
        dec bl
        cmp bl, 0
        jg .shiftIntLeft
    .skipShift:

    and eax, 0xFF80_0000
    shr eax, 23
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
        cmp ecx, 9                      ;   nine iterations. Next iteration would result in a division by 2 with remainder
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
        
    push fracTxtLen
    push fracTxt
    call printText

    push dword [fraction]
    call printInt

    push 1
    push breakLine
    call printText

    ;   float representation
    push floatToTxtLen
    push floatToTxt
    call printText

    push dword [integer]
    call printInt

    push 1
    push decimalPoint
    call printText

    push dword [fraction]
    call printInt

    push 0
    call _ExitProcess@4