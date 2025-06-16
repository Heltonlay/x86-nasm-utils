extern _VirtualAlloc@16
extern _VirtualFree@12
global intToText

section .text
;   parameters:
;   value:      the int to convert to ascii text

intToText:                          ;   returns pointer to string
    push 0x04                       ;   PAGE_READWRITE
    push 0x1000                     ;   MEM_COMMIT
    push 16                         ;   alloc 16 bytes
    push 0                          ;   system choses address
    call _VirtualAlloc@16
    mov esi, eax                    ;   returned pointer

    cmp eax, 0
    je .handleException              ;   handle exception sending NULL if _VirtualAlloc fails

    push 0x04                       ;   PAGE_READWRITE
    push 0x1000                     ;   MEM_COMMIT
    push 16                         ;   alloc 16 bytes
    push 0                          ;   system choses address
    call _VirtualAlloc@16
    mov edi, eax                    ;   returned pointer

    cmp eax, 0
    je .handleException              ;   handle exception sending NULL if _VirtualAlloc fails

    mov ecx, 0                      ;   prepare counter
    mov eax, [esp+4]                ;   int parameter

    ; we need 2 allocated places. First one will be the loop result, second will be fixed number order
    
    test eax, eax
    jns .loopStart
    neg eax                         ;   negate eax if number is negative for correct division

    .loopStart:
        mov edx, 0                  ;   reset remainder
        mov ebx, 10
        div ebx                     ;   eax / 10

        add edx, 48                 ;   converts remainder to ascii
        mov byte [esi+ecx], dl      ;   writes into RAM

        inc ecx
        cmp eax, 0
        jg .loopStart               ;   loop

    ;   negative test to put negative char into result
    mov eax, [esp+4]
    test eax, eax
    jns .skipMinus

    .placeMinus:
    mov byte [esi+ecx], 45          ;   places minus char if number is negative
    inc ecx

    .skipMinus:
    dec ecx
    mov ebx, ecx
    mov ecx, 0

    .revertOrderLoop:
        mov eax, [esi+ebx]
        mov byte [edi+ecx], al
        inc ecx
        dec ebx
        cmp ebx, 0
        jge .revertOrderLoop        ;   order fix loop

    push 0x00008000                 ;   MEM_RELEASE
    push 0
    push esi                        ;   address to release
    call _VirtualFree@12            ;   releases first allocation. We will no longer need it

    mov eax, edi
    ret 4

.handleException:
    mov eax, 0
    ret 4