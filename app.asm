extern _ExitProcess@4
%include "./utils/intToAscii.asm"
%include "./utils/print.asm"

global _main

section .text
_main:
    push 75
    call intToAscii

    push 4
    push eax
    call print

    push 0
    call _ExitProcess@4