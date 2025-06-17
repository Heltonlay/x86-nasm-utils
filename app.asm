extern _ExitProcess@4
%include "./output/printInt.asm"

global _main

section .text
_main:
    push 40
    call printInt

    push 0
    call _ExitProcess@4