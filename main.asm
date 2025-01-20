extern line, circle, full_circle, cursor, caracter, rectangle,full_rectangle, desenha_bordas , desenha_blocos_j1, desenha_blocos_j2

global cor,  j1_blocos, j2_blocos
global deltax, deltay, mens

segment code
..start:
;Inicializa registradores
	MOV		AX,data
	MOV 	DS,AX
	MOV 	AX,stack
	MOV 	SS,AX
	MOV 	SP,stacktop

;Salvar modo corrente de video
	MOV  	AH,0Fh
	INT  	10h
	MOV  	[modo_anterior],AL   

;Alterar modo de video para gráfico 640x480 16 cores
	MOV     	AL,12h
	MOV     	AH,0
	INT     	10h

	MOV byte [cor], branco_intenso
	CALL desenha_bordas
	
	MOV byte [cor], magenta
	CALL desenha_blocos_j1 

	MOV byte [cor], azul
	CALL desenha_blocos_j2

; Loop da animacao da bolinha na tela		
animacao_loop:
	; Limpa o círculo anterior
	MOV byte [cor], preto
	MOV AX, [ball_x]
	PUSH AX
	MOV AX, [ball_y]
	PUSH AX
	MOV AX, [ball_radius]       ; Raio
	PUSH AX
	CALL circle            		; Apaga o círculo

	; Atualiza coordenadas da bola
	CALL verifica_colisao       ; Chama a função para verificar colisões

	; Atualiza a posição da bola
	MOV AX, [ball_x]
	ADD AX, [direction_x]
	MOV [ball_x], AX

	MOV AX, [ball_y]
	ADD AX, [direction_y]
	MOV [ball_y], AX

	; Desenha o novo círculo
	MOV byte [cor], vermelho
	MOV AX, [ball_x]
	PUSH AX
	MOV AX, [ball_y]
	PUSH AX
	MOV AX, [ball_radius]       
	PUSH AX
	CALL circle            		; Desenha o círculo

	; Verifica entrada de teclado para sair
	MOV AH, 0Bh
	INT 21h
	CMP AL, 0
	JE continuar
	MOV AH, 08h
	INT 21h
	CMP AL, 's'
	JNE continuar
	JMP sair

continuar:
	; Adiciona um pequeno atraso para a animação
	CALL delay
	JMP animacao_loop         			; Continua o loop

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
	JMP game_over						; Para o jogo em caso de colisão com a lateral
    
verifica_colisao_direita:
    ; Verifica colisão com a borda lateral direita
    MOV AX, [ball_x]
    ADD AX, [ball_radius]
    CMP AX, 639
	JNG verifica_colisao_j1 			; Se não colidiu com a lateral direita, verifica os blocos do Jogador 1
	JMP game_over						; Para o jogo em caso de colisão com a lateral

verifica_colisao_j1:
    ; Verifica colisão com os blocos do Jogador 1
    MOV CX, 5                  ; Quantidade de blocos
    MOV SI, j1_blocos          ; Apontar para a tabela de blocos
    MOV DI, j1_status          ; Apontar para o estado dos blocos
verifica_colisao_j1_loop:
    CMP byte [DI], 0           ; Verifica se o bloco está destruído
    JE avanca_proximo_bloco_j1

    ; Verifica colisão com o bloco atual
    MOV AX, [ball_x]
	SUB AX, [ball_radius]
    MOV BX, [SI]               			; x1 do bloco
    CMP AX, BX
    JL avanca_proximo_bloco_j1       	; Se a bola está antes do bloco, pula

    MOV BX, [SI+4]             			; x2 do bloco
    CMP AX, BX
    JG avanca_proximo_bloco_j1        	; Se a bola está depois do bloco, pula

    MOV AX, [ball_y]
    MOV BX, [SI+2]             			; y1 do bloco
    CMP AX, BX
    JL avanca_proximo_bloco_j1        	; Se a bola está antes do bloco, pula

    MOV BX, [SI+6]             			; y2 do bloco
    CMP AX, BX
    JG avanca_proximo_bloco_j1        	; Se a bola está depois do bloco, pula

    ; Colisão com bloco detectada
    MOV byte [DI], 0           ; Marca o bloco como destruído
    MOV byte [cor], preto
    PUSH word [SI]             ; x1
    PUSH word [SI+2]           ; y1
    PUSH word [SI+4]           ; x2
    PUSH word [SI+6]           ; y2
    CALL full_rectangle         ; Pinta o bloco de preto
    CALL inverter_direcao_x    ; Inverte a direção da bola em X
    RET

avanca_proximo_bloco_j1:
    ADD SI, 8                  ; Avança para o próximo conjunto de coordenadas
    INC DI                     ; Avança para o próximo estado
    LOOP verifica_colisao_j1_loop           ; Repetir para os blocos restantes

verifica_colisao_j2:
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

    MOV BX, [SI+4]             			; x2 do bloco
    CMP AX, BX
    JG avanca_proximo_bloco_j2        	; Se a bola está depois do bloco, pula

    MOV AX, [ball_y]
    MOV BX, [SI+2]             			; y1 do bloco
    CMP AX, BX
    JL avanca_proximo_bloco_j2        	; Se a bola está antes do bloco, pula

    MOV BX, [SI+6]             			; y2 do bloco
    CMP AX, BX
    JG avanca_proximo_bloco_j2        	; Se a bola está depois do bloco, pula

    ; Colisão com bloco detectada
    MOV byte [DI], 0           ; Marca o bloco como destruído
    MOV byte [cor], preto
    PUSH word [SI]             ; x1
    PUSH word [SI+2]           ; y1
    PUSH word [SI+4]           ; x2
    PUSH word [SI+6]           ; y2
    CALL full_rectangle         ; Pinta o bloco de preto
    CALL inverter_direcao_x    ; Inverte a direção da bola em X
    RET

avanca_proximo_bloco_j2:
    ADD SI, 8                  ; Avança para o próximo conjunto de coordenadas
    INC DI                     ; Avança para o próximo estado
    LOOP verifica_colisao_j2_loop           ; Repetir para os blocos restantes

    RET

game_over:
    ; Pausa a animação
    HLT                        ; Simplesmente para o programa

sair:
	; Restaura o modo de vídeo original e finaliza o programa
	MOV AH, 0
	MOV AL, [modo_anterior]
	INT 10h
	MOV AX, 4C00h
	INT 21h

; Função de atraso (delay)
delay:
	MOV CX, word [vel]        ; Carrega "vel" para ajustar o atraso
del2:
	PUSH CX
	MOV CX, 0800h             ; Loop interno para criar atraso
del1:
	LOOP del1
	POP CX
	LOOP del2
	RET



	MOV    	AH,08h
	INT     21h
	MOV  	AH,0   				; set video mode
	MOV  	AL,[modo_anterior] 	; modo anterior
	INT  	10h
	MOV     AX,4C00h
	INT     21h

;*******************************************************************
segment data

cor		db		branco_intenso
							; I R G B COR
preto			equ		0	; 0 0 0 0 pRETo
azul			equ		1	; 0 0 0 1 azul
verde			equ		2	; 0 0 1 0 verde
cyan			equ		3	; 0 0 1 1 cyan
vermelho		equ		4	; 0 1 0 0 vermelho
magenta			equ		5	; 0 1 0 1 magenta
marrom			equ		6	; 0 1 1 0 marrom
branco			equ		7	; 0 1 1 1 branco
cinza			equ		8	; 1 0 0 0 cinza
azul_claro		equ		9	; 1 0 0 1 azul claro
verde_claro		equ		10	; 1 0 1 0 verde claro
cyan_claro		equ		11	; 1 0 1 1 cyan claro
rosa			equ		12	; 1 1 0 0 rosa
magenta_claro	equ		13	; 1 1 0 1 magenta claro
amarelo			equ		14	; 1 1 1 0 amarelo
branco_intenso	equ		15	; 1 1 1 1 branco INTenso

; Coordenadas da bola
ball_x 			dw 320                   ; Coordenada X da bola
ball_y 			dw 240                   ; Coordenada Y da bola
ball_radius 	dw 10             ; Raio da bola
direction_x     dw 1                   ; Direção no eixo X
direction_y     dw 1                   ; Direção no eixo Y
vel    			dw 10                   ; Velocidade do movimento

modo_anterior	db		0
linha   		dw  	0
coluna  		dw  	0
deltax			dw		0
deltay			dw		0	
mens    		db  	'Funcao Grafica'

; Coordenadas dos blocos do Jogador 1
j1_blocos 	dw 0, 0, 20, 92       ; x1, y1, x2, y2 (Bloco 1)
           	dw 0, 97, 20, 189    ; Bloco 2
           	dw 0, 194, 20, 286   ; Bloco 3
           	dw 0, 291, 20, 383   ; Bloco 4
           	dw 0, 388, 20, 480   ; Bloco 5

; Coordenadas dos blocos do Jogador 2
j2_blocos 	dw 619, 0, 639, 92    ; x1, y1, x2, y2 (Bloco 1)
           	dw 619, 97, 639, 189 ; Bloco 2
           	dw 619, 194, 639, 286; Bloco 3
           	dw 619, 291, 639, 383; Bloco 4
           	dw 619, 388, 639, 480; Bloco 5

; Estado dos blocos (1 = ativo, 0 = destruído)
j1_status db 1, 1, 1, 1, 1      ; Estado dos blocos do Jogador 1
j2_status db 1, 1, 1, 1, 1      ; Estado dos blocos do Jogador 2

;*************************************************************************
segment stack stack
	resb	512
stacktop: