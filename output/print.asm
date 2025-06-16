extern _GetStdHandle@4
extern _WriteFile@20
global print

section .text
print:
    mov ebx, [esp+4]            ;   message
    mov ecx, [esp+8]            ;   length
    
    push -11                    ;   stdout
    call _GetStdHandle@4
    mov edx, eax

    push 0
    push 0
    push ecx                    ;   bytes to write
    push ebx                    ;   message
    push edx                    ;   handle
    call _WriteFile@20          ;   print

    ret 8