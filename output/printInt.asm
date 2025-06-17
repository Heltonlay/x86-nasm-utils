extern _GetStdHandle@4
extern _WriteFile@20
extern _VirtualFree@12
extern intToText

global printInt

section .text
printInt:
    mov eax, [esp+4]            ;   int

    push eax
    call intToText
    mov ebx, eax
    
    push -11                    ;   stdout
    call _GetStdHandle@4
    mov edx, eax
    
    push 0
    push 0
    push 16                     ;   bytes to write
    push ebx                    ;   message
    push edx                    ;   handle
    call _WriteFile@20          ;   print

    push 0x8000                 ;   MEM_RELEASE
    push 0
    push ebx                    ;   address to release
    call _VirtualFree@12        ;   intToText allocates memory. We're releasing its memory

    ret 4