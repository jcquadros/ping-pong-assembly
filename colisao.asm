global verifica_colisao, inverter_direcao_x, inverter_direcao_y
extern line, rectangle, cor, j1_blocos, j2_blocos, j1_raquete, j2_raquete, j1_status, j2_status, ball_x, ball_y, ball_radius, direction_x, direction_y, desenha_bloco, game_over

; Inverte direção X
inverter_direcao_x:
    NEG word [direction_x]
    RET

; Inverte direção Y
inverter_direcao_y:
    NEG word [direction_y]
    RET

verifica_colisao:
    ; Verificar bordas superior e inferior
    MOV AX, [ball_y]
    SUB AX, [ball_radius]                  		
    CMP AX, 1 
    JLE inverter_direcao_y       		

    MOV AX, [ball_y]
    ADD AX, [ball_radius]
    CMP AX, 478
    JGE inverter_direcao_y       		

    ; Verificar bordas laterais
verifica_colisao_esquerda:
    MOV AX, [ball_x]
    SUB AX, [ball_radius]                  		
    CMP AX, 0
	JG verifica_colisao_direita 		; Se não colidiu com a lateral esquerda, verifica a direita
    JMP game_over                          ; Define um valor de retorno indicando colisão com a lateral
    
verifica_colisao_direita:
    ; Verifica colisão com a borda lateral direita
    MOV AX, [ball_x]
    ADD AX, [ball_radius]
    CMP AX, 639
	JL verifica_raquetes 			    ; Se não colidiu com a lateral direita, verifica as raquetes
	JMP game_over                         ; Define um valor de retorno indicando colisão com a lateral

verifica_raquetes:
    ; Verifica colisão com as raquetes dos dois jogadores
    MOV SI, j1_raquete
    CALL verifica_colisao_raquete
    MOV SI, j2_raquete
    CALL verifica_colisao_raquete
    
    ; Verifica colisão com os blocos dos dois jogadores
    MOV SI, j1_blocos
    MOV DI, j1_status
    CALL verifica_blocos
    MOV SI, j2_blocos
    MOV DI, j2_status
    CALL verifica_blocos
    RET

verifica_colisao_raquete:
    ; Verifica colisão com uma raquete
    ; SI = raquete
    MOV AX, [ball_y]
    ADD AX, [ball_radius]
    CMP AX, [SI+2]
    JL no_colision

    MOV AX, [ball_y]
    SUB AX, [ball_radius]
    CMP AX, [SI+6]
    JG no_colision
   
    MOV AX, [ball_x]
    ADD AX, [ball_radius]
    CMP AX, [SI]
    JL no_colision
    JE colisao_raquete_x 

    MOV AX, [ball_x]
    SUB AX, [ball_radius]
    CMP AX, [SI+4]
    JG no_colision
    JE colisao_raquete_x 

    CALL inverter_direcao_y
    RET

colisao_raquete_x:
    CALL inverter_direcao_x
no_colision:
    RET

verifica_blocos:
    ; Argumentos esperados:
    ; SI = tabela de blocos
    ; DI = estado dos blocos
    MOV CX, 5
verifica_blocos_loop:
    CMP byte [DI], 0
    JE avanca_proximo_bloco

    ; Verifica colisão com o bloco atual
    MOV AX, [ball_x]
    ADD AX, [ball_radius]
    CMP AX, [SI]       ; x1
    JL avanca_proximo_bloco

    MOV AX, [ball_x]
    SUB AX, [ball_radius]
    CMP AX, [SI+4]     ; x2
    JG avanca_proximo_bloco

    MOV AX, [ball_y]
    ADD AX, [ball_radius]
    CMP AX, [SI+2]      ; y1
    JL avanca_proximo_bloco
    JE colisao_bloco_y

    MOV AX, [ball_y]
    SUB AX, [ball_radius]
    CMP AX, [SI+6]      ; y2
    JG avanca_proximo_bloco
    JE colisao_bloco_y

    ; Colisao com bloco detectada
    ; Marca bloco como destruído, pinta de preto e inverte direção
    MOV byte [DI], 0
    CALL desenha_bloco  ; SI contém o endereço do bloco
    CALL inverter_direcao_x
    JMP fim_verifica_blocos

colisao_bloco_y:
    ; Colisão com bloco detectada
    ; Marca bloco como destruído, pinta de preto e inverte direção
    MOV byte [DI], 0
    CALL desenha_bloco  ; SI contém o endereço do bloco
    CALL rectangle
    CALL inverter_direcao_y

avanca_proximo_bloco:
    ADD SI, 8
    INC DI
    LOOP verifica_blocos_loop
fim_verifica_blocos:
    RET
