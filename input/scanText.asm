extern _GetStdHandle@4
extern _ReadFile@20
global scanText

section .data
    lpBuffer:   times 128 db 0
    bytesRead:  db 0
section .text
;   out: eax receives pointer to text
;   out: edx receives number of bytes written
scanText:                   ;   returns pointer to string of char
    push -10                ;   stdin
    call _GetStdHandle@4
    mov ebx, eax

    push 0
    push bytesRead          ;   bytesRead
    push 128                ;   max bytes to read is 128
    push lpBuffer           ;   lpBuffer
    push ebx                ;   read stdin
    call _ReadFile@20

    mov eax, lpBuffer
    mov edx, [bytesRead]
    ret