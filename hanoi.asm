.686
.model flat, stdcall

option casemap:none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\masm32.inc
include \masm32\include\msvcrt.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\msvcrt.lib
includelib \masm32\lib\user32.lib

include \masm32\macros\macros.asm

.data
    saida dd 127 dup(0) ;array de saida que contem os movimentos
    output_handle dword 0 
    input_handle dword 0
    write_count DWORD 0
    convertida byte 10 dup(0) 
    num_discos DWORD 0 
    tam_string DD ?
    cont dd -1 ;contador para atualizar dados do array
    msgDeErro db "numero de discos maior que 6", 0
    
.code

hanoi:

    push ebp ; coloca ebp na pilha
    mov ebp, esp ; atualiza valor da base

    cmp DWORD PTR [ebp + 8], 1 ; compara o numero de discos com 1
    ja MaiorQueUm ;se maior que 1 ele vai para o MaiorQueUm

        ;colocar movimentos no array
        inc cont
        mov edx, cont
        mov ecx, DWORD PTR [ebp + 12] ;coloca a origem do movimento em ecx
        mov saida[edx*4], ecx ;coloca ecx no array
        mov ebx, DWORD PTR [ebp + 16] ;coloca o destino do movimento em ebx
        inc cont ;atualiza o indice do array
        mov edx, cont ;coloca o indice no registrador
        mov saida[edx * 4], ebx ;coloca ebx no array

        ;remove a pilha
        mov esp, ebp
        pop ebp
    ;retorna para onde a função foi chamada
    ret
                     
    MaiorQueUm:

       mov eax, DWORD PTR[ebp + 8] ; coloca o numero de discos em eax
       dec eax ; diminui numero de discos

       ;inverter a ordem pra chamar a funcao dnv
       
       push DWORD PTR [ebp + 16] ; coloca o destino na pilha
       push DWORD PTR [ebp + 20] ; coloca o auxiliar na pilha
       push DWORD PTR [ebp + 12]  ; coloca a origem na pilha
       push eax ; coloca o numero de discos na pilha

       call hanoi

        ;colocar movimentos no array
        inc cont
        mov edx, cont
        cmp saida[edx*4], 0
        mov ecx, DWORD PTR [ebp + 12]
        mov saida[edx*4], ecx
        mov ebx, DWORD PTR [ebp + 16]
        inc cont
        mov edx, cont
        mov saida[edx * 4], ebx

        ;coloca o numero de discos em eax novamente
        mov eax, DWORD PTR [ebp + 8]
        ;diminui o numero de discos
        dec eax

       ;inverte a ordem para chamar a função novamente
       
       push DWORD PTR [ebp + 12] ;coloca a origem na pilha
       push DWORD PTR [ebp + 16] ;coloca o destino na pilha
       push DWORD PTR [ebp + 20] ;coloca a auxiliar na pilha
       push eax ;coloca o numero de discos na pilha

       call hanoi
       ;remove a pilha
       mov esp, ebp 
       pop ebp
    ;retorna para onde a função foi chamada
    ret



start:

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    mov output_handle, eax
    push STD_INPUT_HANDLE
    call GetStdHandle
    mov input_handle, eax
    invoke ReadConsole, input_handle, addr num_discos, 1, addr write_count, NULL ; recebe o numero de discos do usuario
    sub num_discos, 48 ;transforma de acordo com a tabela ascii

    cmp num_discos, 6
    ja Erro
    
    push 2; coloca auxiliar na pilha (ebp + 20) 
    push 3; coloca destino na pilha  (ebp + 16)
    push 1; colcoa origem na pilha   (ebp + 12)
    push num_discos;                    (ebp + 8)

    
    xor edx, edx
    call hanoi ; chama função hanoi

    xor edx, edx ;zera edx
    xor eax, eax ;zera eax

    push -1 ;coloca -1 na pilha como flag

    ;coloca os movimentos do array na pilha de forma invertida
    forPraBotarNaPilha:
        mov edx, cont
        mov eax, saida[edx*4]
        cmp edx, -1
        je horaDePrintar
        push saida[edx*4]
        dec cont
        jmp forPraBotarNaPilha

    ;da um pop nos movimentos que estão na pilha, dessa vez de forma correta
    horaDePrintar:
        pop eax
        mov num_discos, eax
        cmp eax, -1
        je fim
        invoke dwtoa, num_discos, addr convertida
        invoke StrLen, addr convertida
        mov tam_string, eax
        invoke WriteConsole, output_handle, addr convertida, tam_string, addr write_count, NULL
        jmp horaDePrintar

    fim:
        invoke ExitProcess, 0

    Erro:
        invoke MessageBox, NULL, addr msgDeErro, addr msgDeErro, MB_OK
        invoke ExitProcess, 0

    
    end start