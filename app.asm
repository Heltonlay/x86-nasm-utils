extern _ExitProcess@4
%include "./utils/intToText.asm"
%include "./utils/print.asm"
%include "./utils/textToInt.asm"

global _main

section .data
    test:   db "68"

section .text
_main:
    push test
    call textToInt

    push eax
    call intToText

    push 4
    push eax
    call print

    push 0
    call _ExitProcess@4