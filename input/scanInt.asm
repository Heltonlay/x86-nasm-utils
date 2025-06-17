extern _GetStdHandle@4
extern _ReadFile@20
extern textToInt

global scanInt

section .data
    lpBuffer:   times 128 db 0
    bytesRead:  db 0
    
section .text
;   out: eax receives number
scanInt:                   ;   returns pointer to string of char
    push -10                ;   stdin
    call _GetStdHandle@4
    mov ebx, eax

    push 0
    push bytesRead          ;   bytesRead
    push 128                ;   max bytes to read is 128
    push lpBuffer           ;   lpBuffer
    push ebx                ;   read stdin
    call _ReadFile@20

    push lpBuffer
    call textToInt
    
    ret