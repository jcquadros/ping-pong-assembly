global desenha_bloco, desenha_blocos, desenha_raquete, move_raquete_cima, move_raquete_baixo
extern rectangle

desenha_bloco:
    ; Função genérica para desenhar um bloco ou raquete
    ; SI deve conter o endereço do bloco/raquete
    PUSH word [SI]              ; x1
    PUSH word [SI+2]            ; y1
    PUSH word [SI+4]            ; x2
    PUSH word [SI+6]            ; y2
    CALL rectangle
    RET

desenha_blocos:
    ; Função genérica para desenhar múltiplos blocos
    ; SI deve conter o endereço da tabela de blocos
    MOV CX, 5                   ; Quantidade de blocos
desenha_blocos_loop:
    CALL desenha_bloco          ; Desenha o bloco atual
    ADD SI, 8                   ; Avança para o próximo bloco (8 bytes por bloco)
    LOOP desenha_blocos_loop    ; Repetir para todos os blocos
    RET

desenha_raquete:
    ; Função genérica para desenhar uma raquete
    ; SI deve conter o endereço da raquete
    CALL desenha_bloco
    RET

move_raquete_cima:
    ; Função genérica para mover uma raquete para cima
    ; SI deve conter o endereço da raquete
    CALL desenha_raquete        ; Apaga a raquete atual

    MOV AX, [SI+6]              ; Y2 (Coordenada superior)
    ADD AX, 5
    CMP AX, 479
    JG move_raquete_cima_fim    ; Se ultrapassar o limite, sai
    MOV [SI+6], AX              ; Atualiza Y2
    
    MOV AX, [SI+2]              ; Y1
    ADD AX, 5
    MOV [SI+2], AX              ; Atualiza Y1

move_raquete_cima_fim:
    RET

move_raquete_baixo:
    ; Função genérica para mover uma raquete para baixo
    ; SI deve conter o endereço da raquete
    CALL desenha_raquete        ; Apaga a raquete atual

    MOV AX, [SI+2]              ; Y1 (Coordenada inferior)
    SUB AX, 5
    CMP AX, 0
    JL move_raquete_baixo_fim   ; Se ultrapassar o limite, sai
    MOV [SI+2], AX              ; Atualiza Y1

    MOV AX, [SI+6]              ; Y2
    SUB AX, 5
    MOV [SI+6], AX              ; Atualiza Y2

move_raquete_baixo_fim:
    RET
