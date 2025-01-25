extern line, rectangle, cor, j1_blocos, j2_blocos, j1_raquete, j2_raquete
global desenha_bordas, desenha_blocos_j1, desenha_blocos_j2, desenha_raquete_j1, desenha_raquete_j2, move_raquete_j1_cima, move_raquete_j1_baixo, move_raquete_j2_cima, move_raquete_j2_baixo


desenha_bordas:
; Desenha borda branca superior e inferior da tela
		MOV AX, 0
		PUSH AX
		MOV AX, 0
		PUSH AX
		MOV AX, 639
		PUSH AX
		MOV AX, 0
		PUSH AX
		CALL line
		
		MOV AX, 0
		PUSH AX
		MOV AX, 479
		PUSH AX
		MOV AX, 639
		PUSH AX
		MOV AX, 479
		PUSH AX
		CALL line
        
        RET
		

desenha_blocos_j1:
    ; Desenha os blocos do Jogador 1
    MOV CX, 5                    ; Quantidade de blocos
    MOV SI, j1_blocos            ; Apontar para a tabela de blocos do Jogador 1
blocos_j1_loop:
    ; Desenha bloco atual
    PUSH word [SI]               ; x1
    PUSH word [SI+2]             ; y1
    PUSH word [SI+4]             ; x2
    PUSH word [SI+6]             ; y2
    CALL rectangle

    ; Avançar para o próximo bloco
    ADD SI, 8                    ; Avançar para o próximo conjunto de coordenadas
    LOOP blocos_j1_loop          ; Repetir para todos os blocos do Jogador 1

    RET
    
desenha_blocos_j2:
    ; Desenha os blocos do Jogador 2
    MOV CX, 5                    ; Quantidade de blocos
    MOV SI, j2_blocos            ; Apontar para a tabela de blocos do Jogador 2
blocos_j2_loop:
    ; Desenha bloco atual
    PUSH word [SI]               ; x1
    PUSH word [SI+2]             ; y1
    PUSH word [SI+4]             ; x2
    PUSH word [SI+6]             ; y2
    CALL rectangle

    ; Avança para o próximo bloco
    ADD SI, 8                    ; Avançar para o próximo conjunto de coordenadas
    LOOP blocos_j2_loop          ; Repetir para todos os blocos do Jogador 2

    RET

desenha_raquete_j1:
    MOV AX, [j1_raquete]
	PUSH AX
	MOV AX, [j1_raquete+2]
	PUSH AX
	MOV AX, [j1_raquete+4]
	PUSH AX
	MOV AX, [j1_raquete+6]
	PUSH AX
	CALL rectangle
    RET

desenha_raquete_j2:
    MOV AX, [j2_raquete]
    PUSH AX
    MOV AX, [j2_raquete+2]
    PUSH AX
    MOV AX, [j2_raquete+4]
    PUSH AX
    MOV AX, [j2_raquete+6]
    PUSH AX
    CALL rectangle
    RET

move_raquete_j1_cima:
    CALL desenha_raquete_j1 ; Apaga a raquete atual

    MOV AX, [j1_raquete+2] ; Y1
    ADD AX, 5
    CMP AX, 388
    JG move_raquete_j1_cima_fim
    
    MOV [j1_raquete+2], AX
    MOV AX, [j1_raquete+6] ; Y2
    ADD AX, 5
    MOV [j1_raquete+6], AX

move_raquete_j1_cima_fim:
    RET

move_raquete_j1_baixo:
    CALL desenha_raquete_j1 ; Apaga a raquete atual

    MOV AX, [j1_raquete+2] ; Y1
    SUB AX, 5
    CMP AX, 0
    JL move_raquete_j1_baixo_fim
    
    MOV [j1_raquete+2], AX
    MOV AX, [j1_raquete+6] ; Y2
    SUB AX, 5
    MOV [j1_raquete+6], AX

move_raquete_j1_baixo_fim:
    RET

move_raquete_j2_cima:
    CALL desenha_raquete_j2 ; Apaga a raquete atual

    MOV AX, [j2_raquete+2] ; Y1
    ADD AX, 5
    CMP AX, 388
    JG move_raquete_j2_cima_fim
    
    MOV [j2_raquete+2], AX
    MOV AX, [j2_raquete+6] ; Y2
    ADD AX, 5
    MOV [j2_raquete+6], AX

move_raquete_j2_cima_fim:
    RET

move_raquete_j2_baixo:
    CALL desenha_raquete_j2 ; Apaga a raquete atual

    MOV AX, [j2_raquete+2] ; Y1
    SUB AX, 5
    CMP AX, 0
    JL move_raquete_j2_baixo_fim
    
    MOV [j2_raquete+2], AX
    MOV AX, [j2_raquete+6] ; Y2
    SUB AX, 5
    MOV [j2_raquete+6], AX

move_raquete_j2_baixo_fim:
    RET