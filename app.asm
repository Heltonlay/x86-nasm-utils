extern _ExitProcess@4
extern floatToStr
extern printText

global _main

section .data
value1:     dd  0.001

section .text
_main:
    fld dword [value1]
    call floatToStr

    push 64
    push eax
    call printText

    push 0
    call _ExitProcess@4