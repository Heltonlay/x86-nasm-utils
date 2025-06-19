extern _ExitProcess@4
extern floatToStr
extern printText

global _main

section .data
value1:     dd  3.14

section .text
_main:
    fld dword [value1]
    call floatToStr

    push 12
    push eax
    call printText

    push 0
    call _ExitProcess@4