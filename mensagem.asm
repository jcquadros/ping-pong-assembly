global escreve_mensagem
extern cursor, caracter

; -----------------------------------------------------------------------------
; Função: escreve_mensagem
; Descrição: Escreve uma mensagem na tela em uma posição específica.
; Parâmetros:
;   PUSH Y   (linha)  
;   PUSH X   (coluna)  
;   PUSH mensagem (endereço da string, terminada em 0)
;   CALL escreve_mensagem
escreve_mensagem:
    PUSH    BP
    MOV     BP, SP
    PUSHF
    PUSH    AX
    PUSH    BX
    PUSH    CX
    PUSH    DX
    PUSH    SI
    PUSH    DI

    MOV     DH, [BP+8]   ; Carregar linha (Y)
    MOV     DL, [BP+6]   ; Carregar coluna (X)
    MOV     SI, [BP+4]   ; Endereço da string
    ; Calcular o tamanho da string
    XOR     CX, CX       ; Zerar contador
calcula_tamanho:
    MOV     AL, [SI]     ; Carrega caractere atual
    CMP     AL, 0        ; Se for o fim da string, sai do loop
    JE      imprime_texto
    INC     SI           ; Avança o ponteiro na string
    INC     CX           ; Conta caracteres
    JMP     calcula_tamanho
    
imprime_texto:
    MOV SI, [BP+4]       ; Endereço da string

loop_escrita:
    CALL    cursor       ; Posicionar cursor
    MOV     AL, [SI]     ; Carregar caractere
    CMP     AL, 0        ; Se for o fim da string, sai
    JE      fim_escrita  
    CALL    caracter     ; Exibir caractere
    
    INC     SI           ; Avança na string
    INC     DL           ; Avança a coluna

    LOOP    loop_escrita ; Continua até acabar os caracteres

fim_escrita:
    POP     DI
    POP     SI
    POP     DX
    POP     CX
    POP     BX
    POP     AX
    POPF
    POP     BP
    RET     6            ; Remove os 3 parâmetros da pilha (X, Y, mensagem)
