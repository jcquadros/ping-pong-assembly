extern line, circle, full_circle, cursor, caracter, retangle,full_retangle

global cor
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
		
; Desenha borda branca superior e inferior da tela
		MOV byte[cor], branco_intenso
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
		
		CALL desenha_blocos
		
;Desenha circulo vermelho de raio 10 no centro da tela
		MOV AX, 320                 ; Coordenada inicial X (meio da tela)
		MOV word [ball_x], AX
		MOV AX, 240                 ; Coordenada inicial Y (meio da tela)
		MOV word [ball_y], AX
		MOV word [direction_x], 1   ; Direção X (movendo para a direita)
		MOV word [direction_y], 1   ; Direção Y (movendo para cima)
		MOV word [vel], 1           ; Velocidade da animação
		
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
		MOV AX, [ball_x]
		ADD AX, [direction_x]
		MOV BX, [ball_radius]
		SUB AX, BX                  ; Subtrai o raio para verificar borda esquerda
		CMP AX, 1
		JL inverter_direcao_x       ; Reflete na borda esquerda

		MOV AX, [ball_x]
		ADD AX, [direction_x]
		ADD AX, BX                  ; Adiciona o raio para verificar borda direita
		CMP AX, 638
		JG inverter_direcao_x       ; Reflete na borda direita

		MOV AX, [ball_x]
		ADD AX, [direction_x]
		MOV [ball_x], AX            ; Atualiza a posição X da bola

		MOV AX, [ball_y]
		ADD AX, [direction_y]
		MOV BX, [ball_radius]
		SUB AX, BX                  ; Subtrai o raio para verificar borda superior
		CMP AX, 1
		JL inverter_direcao_y       ; Reflete na borda superior

		MOV AX, [ball_y]
		ADD AX, [direction_y]
		ADD AX, BX                  ; Adiciona o raio para verificar borda inferior
		CMP AX, 478
		JG inverter_direcao_y       ; Reflete na borda inferior

		MOV AX, [ball_y]
		ADD AX, [direction_y]
		MOV [ball_y], AX            ; Atualiza a posição Y da bola

		; Desenha o novo círculo
		MOV byte [cor], vermelho
		MOV AX, [ball_x]
		PUSH AX
		MOV AX, [ball_y]
		PUSH AX
		MOV AX, [ball_radius]       ; Raio
		PUSH AX
		CALL circle            ; Desenha o círculo

		; Verifica entrada de teclado para sair
		MOV AH, 0Bh
		INT 21h
		CMP AL, 0
		JE continuar
		MOV AH, 08h
		INT 21h
		CMP AL, 's'
		JE sair

continuar:
		; Adiciona um pequeno atraso para a animação
		CALL delay
		JMP animacao_loop         ; Continua o loop

inverter_direcao_x:
		NEG word [direction_x]             ; Inverte a direção em X
		JMP continuar

inverter_direcao_y:
		NEG word [direction_y]             ; Inverte a direção em Y
		JMP continuar

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

desenha_blocos:
    ; Configuração inicial
    MOV word [altura_bloco], 92 ; Altura do bloco

    ; Definir espaçamento entre os blocos
    MOV word [espacamento], 5

    ; Configurar blocos do Jogador 1
    MOV AX, 0                ; Coordenada inicial X para o Jogador 1
    MOV word [j1_x1], AX
    MOV AX, 20               ; Largura do bloco
    MOV word [j1_x2], AX
    MOV AX, 0                ; Coordenada inicial Y para o primeiro bloco
    MOV word [j1_y1], AX

    ; Configurar blocos do Jogador 2
    MOV AX, 619              ; Coordenada inicial X para o Jogador 2
    MOV word [j2_x1], AX
    MOV AX, 639              ; Largura do bloco
    MOV word [j2_x2], AX
    MOV AX, 0                ; Coordenada inicial Y para o primeiro bloco
    MOV word [j2_y1], AX

    ; Desenhar os blocos do Jogador 1
    MOV CX, 5                ; Quantidade de blocos
    MOV byte [cor], magenta  ; Cor dos blocos do Jogador 1
	
blocos_j1_loop:
    ; Calcular Y2 para o bloco atual
    MOV AX, [j1_y1]
    ADD AX, [altura_bloco]
    MOV word [j1_y2], AX

    ; Desenhar bloco
    PUSH word [j1_x1]
    PUSH word [j1_y1]
    PUSH word [j1_x2]
    PUSH word [j1_y2]
    CALL full_retangle

    ; Atualizar coordenadas Y para o próximo bloco
    MOV AX, [j1_y2]
    ADD AX, [espacamento]
    MOV word [j1_y1], AX

    LOOP blocos_j1_loop

    ; Desenhar os blocos do Jogador 2
    MOV CX, 5                ; Quantidade de blocos
    MOV byte [cor], azul     ; Cor dos blocos do Jogador 2
blocos_j2_loop:
    ; Calcular Y2 para o bloco atual
    MOV AX, [j2_y1]
    ADD AX, [altura_bloco]
    MOV word [j2_y2], AX

    ; Desenhar bloco
    PUSH word [j2_x1]
    PUSH word [j2_y1]
    PUSH word [j2_x2]
    PUSH word [j2_y2]
    CALL full_retangle

    ; Atualizar coordenadas Y para o próximo bloco
    MOV AX, [j2_y2]
    ADD AX, [espacamento]
    MOV word [j2_y1], AX

    LOOP blocos_j2_loop

    RET




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

ball_x dw 0                   ; Coordenada X da bola
ball_y dw 0                   ; Coordenada Y da bola
ball_radius dw 10             ; Raio da bola
direction_x     dw 0                   ; Direção no eixo X
direction_y     dw 0                   ; Direção no eixo Y
vel    dw 0                   ; Velocidade do movimento

modo_anterior	db		0
linha   		dw  	0
coluna  		dw  	0
deltax			dw		0
deltay			dw		0	
mens    		db  	'Funcao Grafica'

j1_x1 dw 0
j1_y1 dw 0
j1_x2 dw 0
j1_y2 dw 0

j2_x1 dw 0
j2_y1 dw 0
j2_x2 dw 0
j2_y2 dw 0

altura_bloco dw 0
espacamento dw 0

; Estado dos blocos (1 = ativo, 0 = destruído)
j1_status db 1, 1, 1, 1, 1      ; Estado dos blocos do Jogador 1
j2_status db 1, 1, 1, 1, 1      ; Estado dos blocos do Jogador 2

;*************************************************************************
segment stack stack
	resb	512
stacktop: