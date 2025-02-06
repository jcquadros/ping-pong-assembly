global desenha_bloco, desenha_blocos, desenha_raquete, move_raquete_cima, move_raquete_baixo, desenha_blocos_coloridos
extern rectangle, cor, full_rectangle, line

desenha_bloco:
    ; Função genérica para desenhar um bloco ou raquete
    ; SI deve conter o endereço do bloco/raquete
    PUSH word [SI]              ; x1
    PUSH word [SI+2]            ; y1
    PUSH word [SI+4]            ; x2
    PUSH word [SI+6]            ; y2
    CALL full_rectangle
    RET

desenha_blocos:
    ; Função genérica para desenhar múltiplos blocos
    ; SI deve conter o endereço da tabela de blocos
    ; DI deve conter o endereço da tabela de estados dos blocos
    MOV CX, 5                   ; Quantidade de blocos
desenha_blocos_loop:
    CMP byte [DI], 0            ; Verifica se o bloco está destruído
    JE desenha_blocos_avanca    ; Se destruído, pula para o próximo bloco
    CALL desenha_bloco          ; Desenha o bloco atual
desenha_blocos_avanca:
    INC DI                      ; Avança para o próximo estado
    ADD SI, 8                   ; Avança para o próximo bloco (8 bytes por bloco)
    LOOP desenha_blocos_loop    ; Repetir para todos os blocos
    RET

desenha_blocos_coloridos:
    ; Função genérica para desenhar múltiplos blocos
    ; SI deve conter o endereço da tabela de blocos
    ; DI deve conter o endereço da tabela de estados dos blocos


    CMP byte[DI], 0             ; Se o bloco nao esta ativo
    JE desenha_bloco_2          ; Pula pro próximo bloco
    MOV byte[cor], 4            ; Vermelho
    CALL desenha_bloco

desenha_bloco_2:
    INC DI                      ; Avança para o próximo estado
    ADD SI, 8 
    CMP byte[DI], 0             ; Se o bloco nao esta ativo
    JE desenha_bloco_3          ; Pula pro próximo bloco
    MOV byte[cor], 14           ; Amarelo
    CALL desenha_bloco

desenha_bloco_3:
    INC DI                      ; Avança para o próximo estado
    ADD SI, 8 
    CMP byte[DI], 0             ; Se o bloco nao esta ativo
    JE desenha_bloco_4          ; Pula pro próximo bloco
    MOV byte[cor], 10           ; Verde
    CALL desenha_bloco
    
desenha_bloco_4:
    INC DI                      ; Avança para o próximo estado
    ADD SI, 8 
    CMP byte[DI], 0             ; Se o bloco nao esta ativo
    JE desenha_bloco_5          ; Pula pro próximo bloco
    MOV byte[cor], 9            ; Azul claro
    CALL desenha_bloco

desenha_bloco_5:
    INC DI                      ; Avança para o próximo estado
    ADD SI, 8 
    CMP byte[DI], 0             ; Se o bloco nao esta ativo
    JE desenha_bloco_sair          ; Pula pro próximo bloco
    MOV byte[cor], 1            ; Azul escuro
    CALL desenha_bloco
desenha_bloco_sair:
    RET

desenha_raquete:
    ; Função genérica para desenhar uma raquete
    ; SI deve conter o endereço da raquete
    PUSH word [SI]              ; x1
    PUSH word [SI+2]            ; y1
    PUSH word [SI+4]            ; x2
    PUSH word [SI+6]            ; y2
    CALL rectangle
    RET

move_raquete_cima:
    ; Função genérica para mover uma raquete para cima
    ; SI deve conter o endereço da raquete
    CALL desenha_raquete        ; Apaga a raquete atual
    MOV AX, [SI+6]              ; Y2 (Coordenada superior)
    ADD AX, 2
    CMP AX, 479
    JG move_raquete_cima_fim    ; Se ultrapassar o limite, sai
    MOV [SI+6], AX              ; Atualiza Y2
    MOV AX, [SI+2]              ; Y1
    ADD AX, 2
    MOV [SI+2], AX              ; Atualiza Y1


move_raquete_cima_fim:
    RET

move_raquete_baixo:
    ; Função genérica para mover uma raquete para baixo
    ; SI deve conter o endereço da raquete
    CALL desenha_raquete        ; Apaga a raquete atual
    MOV AX, [SI+2]              ; Y1 (Coordenada inferior)
    SUB AX, 2
    CMP AX, 0
    JL move_raquete_baixo_fim   ; Se ultrapassar o limite, sai
    MOV [SI+2], AX              ; Atualiza Y1
    MOV AX, [SI+6]              ; Y2
    SUB AX, 2
    MOV [SI+6], AX              ; Atualiza Y2

move_raquete_baixo_fim:
    RET

