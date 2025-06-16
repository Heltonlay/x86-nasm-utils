global textToInt

section .text
textToInt:
    mov ebx, [esp+4]            ;   pointer to text

    mov eax, 0
    mov ecx, 0
    .loopStart:                 ;   loop while char is between 48 and 57 (numbers in ascii)
        mov cl, byte [ebx]      ;   move next char into edx

        cmp ecx, 45
        je .continue

        cmp ecx, 48
        jl .break
        cmp ecx, 57
        jg .break               ;   break out of loop if edx is less than 48 or greater than 57

        mov edx, 0
        mov esi, 10
        mul esi                 ;   eax * 10

        sub ecx, 48
        add eax, ecx            ;   eax + ecx

        .continue:
        inc ebx 
        jmp .loopStart
    .break:

    mov ebx, [esp+4]
    mov cl, byte [ebx]
    cmp ecx, 45
    jne .skipMinus
    neg eax

    .skipMinus:
    ret 4