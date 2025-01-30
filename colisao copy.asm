global verifica_colisao, inverter_direcao_x, inverter_direcao_y
extern line, rectangle, cor, j1_blocos, j2_blocos, j1_raquete, j2_raquete, j1_status, j2_status, ball_x, ball_y, ball_radius, direction_x, direction_y, tela_game_over, cor

inverter_direcao_x:
	NEG word [direction_x]             ; Inverte a direção em X
	RET

inverter_direcao_y:
	NEG word [direction_y]             ; Inverte a direção em Y
	RET

verifica_colisao:
    ; Verifica colisão com a borda superior
    MOV AX, [ball_y]
    MOV BX, [ball_radius]
    SUB AX, BX                  		; Posição da bola - Raio
    CMP AX, 2
    JL inverter_direcao_y       		; Reflete na borda superior se for menor que 0

    ; Verifica colisão com a borda inferior
    MOV AX, [ball_y]
    ADD AX, [ball_radius]
    CMP AX, 477
	JNG verifica_colisao_esquerda ;
    JMP inverter_direcao_y       		; Reflete na borda inferior se for maior que 479

verifica_colisao_esquerda:
    ; Verifica colisão com a borda lateral esquerda
    MOV AX, [ball_x]
    MOV BX, [ball_radius]
    SUB AX, BX                  		; Posição da bola - Raio
    CMP AX, 0
	JNL verifica_colisao_direita 		; Se não colidiu com a lateral esquerda, verifica a direita
	JMP tela_game_over						; Para o jogo em caso de colisão com a lateral
    
verifica_colisao_direita:
    ; Verifica colisão com a borda lateral direita
    MOV AX, [ball_x]
    ADD AX, [ball_radius]
    CMP AX, 639
	JNG verifica_colisao_raquete_j1 			; Se não colidiu com a lateral direita, verifica os blocos do Jogador 1
	JMP tela_game_over						; Para o jogo em caso de colisão com a lateral

verifica_colisao_raquete_j1:
    ; Verifica colisão com a raquete do Jogador 1
	MOV AX, [ball_x]
	ADD AX, [ball_radius]
    MOV BX, [j1_raquete]             			; x1 do bloco
    CMP AX, BX
    JL verifica_colisao_blocos_j1       	; Se a bola está antes do bloco, pula

	MOV AX, [ball_x]
	SUB AX, [ball_radius]
    MOV BX, [j1_raquete+4]             			; x2 do bloco
    CMP AX, BX
    JG verifica_colisao_blocos_j1            	; Se a bola está depois do bloco, pula

    MOV AX, [ball_y]
	ADD AX, [ball_radius]
    MOV BX, [j1_raquete+2]             			; y1 do bloco
    CMP AX, BX
    JL verifica_colisao_blocos_j1            	; Se a bola está antes do bloco, pula
	JE colisao_raquete_y_j1

	MOV AX, [ball_y]
	SUB AX, [ball_radius]
    MOV BX, [j1_raquete+6]             			; y2 do bloco
    CMP AX, BX
    JG verifica_colisao_blocos_j1            	; Se a bola está depois do bloco, pula
	JE colisao_raquete_y_j1
	
	CALL inverter_direcao_x
	JMP fim_verifica_colisao_j1

colisao_raquete_y_j1:
	CALL inverter_direcao_y
    JMP fim_verifica_colisao_j1         ; Pula para o final da sub-rotina

verifica_colisao_blocos_j1:
    ; Verifica colisão com os blocos do Jogador 1
    MOV CX, 5                  ; Quantidade de blocos
    MOV SI, j1_blocos          ; Apontar para a tabela de blocos
    MOV DI, j1_status          ; Apontar para o estado dos blocos
verifica_colisao_j1_loop:
    CMP byte [DI], 0           ; Verifica se o bloco está destruído
    JE avanca_proximo_bloco_j1

    ; Verifica colisão com o bloco atual
    MOV AX, [ball_x]
	ADD AX, [ball_radius]
    MOV BX, [SI]               			; x1 do bloco
    CMP AX, BX
    JL avanca_proximo_bloco_j1       	; Se a bola está antes do bloco, pula

	MOV AX, [ball_x]
	SUB AX, [ball_radius]
    MOV BX, [SI+4]             			; x2 do bloco
    CMP AX, BX
    JG avanca_proximo_bloco_j1        	; Se a bola está depois do bloco, pula

    MOV AX, [ball_y]
	ADD AX, [ball_radius]
    MOV BX, [SI+2]             			; y1 do bloco
    CMP AX, BX
    JL avanca_proximo_bloco_j1        	; Se a bola está antes do bloco, pula
	JE colisao_bloco_y_j1

	MOV AX, [ball_y]
	SUB AX, [ball_radius]
    MOV BX, [SI+6]             			; y2 do bloco
    CMP AX, BX
    JG avanca_proximo_bloco_j1        	; Se a bola está depois do bloco, pula
	JE colisao_bloco_y_j1

    ; Colisão com bloco detectada
    MOV byte [DI], 0           ; Marca o bloco como destruído
    PUSH word [SI]             ; x1
    PUSH word [SI+2]           ; y1
    PUSH word [SI+4]           ; x2
    PUSH word [SI+6]           ; y2
    CALL rectangle         ; Pinta o bloco de preto
    CALL inverter_direcao_x    ; Inverte a direção da bola em X
fim_verifica_colisao_j1:
    JMP verifica_colisao_raquete_j2

colisao_bloco_y_j1:
	MOV byte [DI], 0           ; Marca o bloco como destruído
    PUSH word [SI]             ; x1
    PUSH word [SI+2]           ; y1
    PUSH word [SI+4]           ; x2
    PUSH word [SI+6]           ; y2
    CALL rectangle    
	CALL inverter_direcao_y
	JMP fim_verifica_colisao_j1         ; Pula para o final da sub-rotina

avanca_proximo_bloco_j1:
    ADD SI, 8                  ; Avança para o próximo conjunto de coordenadas
    INC DI                     ; Avança para o próximo estado
    LOOP verifica_colisao_j1_loop           ; Repetir para os blocos restantes

verifica_colisao_raquete_j2:
	; Verifica colisão com a raquete do Jogador 2
	MOV AX, [ball_x]
	ADD AX, [ball_radius]
	MOV BX, [j2_raquete]             			; x1 do bloco
	CMP AX, BX
	JL verifica_colisao_blocos_j2       	; Se a bola está antes do bloco, pula
	
	MOV AX, [ball_x]
	SUB AX, [ball_radius]
	MOV BX, [j2_raquete+4]             			; x2 do bloco
	CMP AX, BX
	JG verifica_colisao_blocos_j2            	; Se a bola está depois do bloco, pula

	MOV AX, [ball_y]
	ADD AX, [ball_radius]
	MOV BX, [j2_raquete+2]             			; y1 do bloco
	CMP AX, BX
	JL verifica_colisao_blocos_j2            	; Se a bola está antes do bloco, pula
	JE colisao_raquete_y_j2

	MOV AX, [ball_y]
	SUB AX, [ball_radius]
	MOV BX, [j2_raquete+6]             			; y2 do bloco
	CMP AX, BX
	JG verifica_colisao_blocos_j2            	; Se a bola está depois do bloco, pula
	JE colisao_raquete_y_j2

	CALL inverter_direcao_x
	JMP fim_verifica_colisao_j2

colisao_raquete_y_j2:
	CALL inverter_direcao_y
	JMP fim_verifica_colisao_j2         ; Pula para o final da sub-rotina

verifica_colisao_blocos_j2:
	; Verifica colisão com os blocos do Jogador 2
	MOV CX, 5                  ; Quantidade de blocos
	MOV SI, j2_blocos          ; Apontar para a tabela de blocos
	MOV DI, j2_status          ; Apontar para o estado dos blocos
verifica_colisao_j2_loop:

	CMP byte [DI], 0           ; Verifica se o bloco está destruído
	JE avanca_proximo_bloco_j2

	; Verifica colisão com o bloco atual
	MOV AX, [ball_x]
	ADD AX, [ball_radius]
	MOV BX, [SI]               			; x1 do bloco
	CMP AX, BX
	JL avanca_proximo_bloco_j2       	; Se a bola está antes do bloco, pula

	MOV AX, [ball_x]
	SUB AX, [ball_radius]
	MOV BX, [SI+4]             			; x2 do bloco
	CMP AX, BX
	JG avanca_proximo_bloco_j2        	; Se a bola está depois do bloco, pula

	MOV AX, [ball_y]
	ADD AX, [ball_radius]
	MOV BX, [SI+2]             			; y1 do bloco
	CMP AX, BX
	JL avanca_proximo_bloco_j2        	; Se a bola está antes do bloco, pula
	JE colisao_bloco_y_j2

	MOV AX, [ball_y]
	SUB AX, [ball_radius]
	MOV BX, [SI+6]             			; y2 do bloco
	CMP AX, BX
	JG avanca_proximo_bloco_j2        	; Se a bola está depois do bloco, pula
	JE colisao_bloco_y_j2

	; Colisão com bloco detectada
	MOV byte [DI], 0           ; Marca o bloco como destruído
	PUSH word [SI]             ; x1
	PUSH word [SI+2]           ; y1
	PUSH word [SI+4]           ; x2
	PUSH word [SI+6]           ; y2
	CALL rectangle          ; Pinta o bloco de preto
	CALL inverter_direcao_x    ; Inverte a direção da bola em X

fim_verifica_colisao_j2:
	RET

colisao_bloco_y_j2:
	MOV byte [DI], 0           ; Marca o bloco como destruído
	PUSH word [SI]             ; x1
	PUSH word [SI+2]           ; y1
	PUSH word [SI+4]           ; x2
	PUSH word [SI+6]           ; y2
	CALL rectangle    
	CALL inverter_direcao_y
	JMP fim_verifica_colisao_j2         ; Pula para o final da sub-rotina

avanca_proximo_bloco_j2:
    ADD SI, 8                  ; Avança para o próximo conjunto de coordenadas
    INC DI                     ; Avança para o próximo estado
    LOOP verifica_colisao_j2_loop           ; Repetir para os blocos restantes
	RET