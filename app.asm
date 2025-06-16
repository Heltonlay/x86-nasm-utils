extern _ExitProcess@4
%include "./input/scanText.asm"
%include "./output/print.asm"
%include "./utils/intToText.asm"
%include "./utils/textToInt.asm"

global _main

section .text
_main:
    call scanText

    push edx
    push eax
    call print

    push 0
    call _ExitProcess@4