extern _VirtualAlloc@16
extern intToText

global floatToStr

section .data
originalValue:      dd  0
fpuRoundedInt:      dd  0
fpuControlWord:     dw  0

exponent:           dd  0
integer:            dd  0
fraction:           dd  0
result:             dd  0
counter:            db  0

section .text
;   parameters:
;   value:      float from top of FPU stack

floatToStr:
    fst dword [originalValue]

    ;   unbiased exponent
    mov eax, dword [originalValue]
    and eax, 0x7F80_0000
    shr eax, 23
    sub eax, 127
    mov [exponent], eax

    ;   integer
    fnstcw [fpuControlWord]                ;   load control word
    or word [fpuControlWord], 0x400        ;   change rounding mode to down
    fldcw [fpuControlWord]                 ;   save control word
    fld st0
    frndint                             ;   round value in st0 to int
    fstp dword [fpuRoundedInt]

    mov eax, [fpuRoundedInt]
    and eax, 0x807F_FFFF
    or eax, 0x80_0000

    mov ebx, [exponent]
    cmp ebx, 0
    je .skipRot
    jg .rotIntLeft
    .intZero:
        mov eax, 0
        jmp .intFinal
    .rotIntLeft:
        rol eax, 1
        dec ebx
        cmp ebx, 0
        jg .rotIntLeft
    .skipRot:

    ror eax, 23
    .intFinal:
    mov [integer], eax

    ;   fraction
    mov eax, dword [originalValue]
    and eax, 0x7F_FFFF
    or eax, 0x80_0000

    mov ebx, [exponent]
    cmp ebx, 0
    je .skipFracShift
    jl .shiftFracRight
    .shiftFracLeft:
        shl eax, 1
        dec ebx
        cmp ebx, 0
        jg .shiftFracLeft
        jmp .skipFracShift
    .shiftFracRight:
        shr eax, 1
        inc ebx
        cmp ebx, 0
        jl .shiftFracRight
    .skipFracShift:

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

    ;   decimal representation
    push 0x04                       ;   PAGE_READWRITE
    push 0x1000                     ;   MEM_COMMIT
    push 32                         ;   alloc 32 bytes
    push 0                          ;   system choses address
    call _VirtualAlloc@16
    mov [result], eax               ;   returned pointer

    cmp eax, 0
    je .handleException             ;   handle exception sending NULL if _VirtualAlloc fails

    ;   first step is adding up the integer part
    push dword [integer]
    call intToText                  ;   eax = pointer to int text
                                    ;   esi = pointer to allocated memory
    mov ebx, [result]
    mov [counter], ebx
    mov edx, ebx
    .moveIntByte:
        mov bl, byte [eax]
        mov byte [edx], bl          ;   copy ascii byte into value pointed by result
        inc eax
        inc edx
        mov [counter], edx
        cmp byte [eax], 0
        jne .moveIntByte

    ;   second step is putting the decimal point
    mov byte [edx], 46
    inc edx
    mov [counter], edx

    ;   third step is adding up the fractional part
    push dword [fraction]
    call intToText
    inc eax

    mov edx, [counter]
    .moveFracByte:
        mov bl, byte [eax]
        mov byte [edx], bl
        inc eax
        inc edx
        mov [counter], edx
        cmp byte [eax], 0
        jne .moveFracByte

    mov eax, [result]
    ret

.handleException:
    mov eax, 0
    ret