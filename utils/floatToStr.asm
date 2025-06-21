extern _VirtualAlloc@16
extern intToText

global floatToStr

section .data
originalValue:      dd  0
fpuRoundedInt:      dd  0
fpuControlWord:     dw  0

exponent:           db  0
integer:            dd  0
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
    sub al, 127
    mov [exponent], al

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

    mov bl, [exponent]
    cmp bl, 0
    je .skipRot
    jg .rotIntLeft
    .intZero:
        mov eax, 0
        jmp .intFinal
    .rotIntLeft:
        rol eax, 1
        dec bl
        cmp bl, 0
        jg .rotIntLeft
    .skipRot:

    ror eax, 23
    .intFinal:
    mov [integer], eax

    ;   decimal representation
    push 0x04                       ;   PAGE_READWRITE
    push 0x1000                     ;   MEM_COMMIT
    push 64                         ;   alloc 32 bytes
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

    mov ebx, [originalValue]
    and ebx, 0x8000_0000
    cmp ebx, 0
    je .moveIntByte
    mov byte [edx], 45
    inc edx

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
    mov eax, dword [originalValue]
    and eax, 0x7F_FFFF
    mov cl, [exponent]
    test cl, cl
    jns .skipNegate
    or eax, 0x80_0000
    neg cl
    shr eax, cl
    jmp .skipPositive
    .skipNegate:
    shl eax, cl
    .skipPositive:
    and eax, 0x7F_FFFF
    shl eax, 9
    mov ebx, 100_000_000

    mul ebx
    
    add edx, 100_000_000
    push edx
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

    mov eax, dword [originalValue]
    and eax, 0x7F_FFFF
    mov cl, [exponent]
    test cl, cl
    jns .skipNegate2
    or eax, 0x80_0000
    neg cl
    shr eax, cl
    jmp .skipPositive2
    .skipNegate2:
    shl eax, cl
    .skipPositive2:
    and eax, 0x7F_FFFF
    shl eax, 9
    mov ebx, 100_000_000

    mul ebx
    mul ebx
    
    add edx, 100_000_000
    push edx
    call intToText
    inc eax

    mov edx, [counter]
    .moveFracByte2:
        mov bl, byte [eax]
        mov byte [edx], bl
        inc eax
        inc edx
        mov [counter], edx
        cmp byte [eax], 0
        jne .moveFracByte2

    mov eax, dword [originalValue]
    and eax, 0x7F_FFFF
    mov cl, [exponent]
    test cl, cl
    jns .skipNegate3
    or eax, 0x80_0000
    neg cl
    shr eax, cl
    jmp .skipPositive3
    .skipNegate3:
    shl eax, cl
    .skipPositive3:
    and eax, 0x7F_FFFF
    shl eax, 9
    mov ebx, 100_000_000

    mul ebx
    mul ebx
    mul ebx
    
    add edx, 100_000_000
    push edx
    call intToText
    inc eax

    mov edx, [counter]
    .moveFracByte3:
        mov bl, byte [eax]
        mov byte [edx], bl
        inc eax
        inc edx
        mov [counter], edx
        cmp byte [eax], 0
        jne .moveFracByte3

    mov eax, [result]
    ret

.handleException:
    mov eax, 0
    ret