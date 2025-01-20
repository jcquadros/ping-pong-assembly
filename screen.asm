extern line, full_rectangle, cor, j1_blocos, j2_blocos
global desenha_bordas, desenha_blocos_j1, desenha_blocos_j2


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
    CALL full_rectangle

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
    CALL full_rectangle

    ; Avança para o próximo bloco
    ADD SI, 8                    ; Avançar para o próximo conjunto de coordenadas
    LOOP blocos_j2_loop          ; Repetir para todos os blocos do Jogador 2

    RET
