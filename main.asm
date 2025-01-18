extern line, circle, full_circle, cursor, caracter

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
		
;Desenha retângulo branco no fundo da tela
		MOV byte[cor], branco_intenso
		MOV AX, 0
		PUSH AX
		MOV AX, 0
		PUSH AX
		MOV AX, 639
		PUSH AX
		MOV AX, 479
		PUSH AX
		CALL retangle
		
;Desenha circulo vermelho de raio 10 no centro da tela
		MOV AX, 320                 ; Coordenada inicial X (meio da tela)
		MOV word [ball_x], AX
		MOV AX, 240                 ; Coordenada inicial Y (meio da tela)
		MOV word [ball_y], AX
		MOV word [direction_x], 1   ; Direção X (movendo para a direita)
		MOV word [direction_y], 1   ; Direção Y (movendo para cima)
		MOV word [vel], 3           ; Velocidade da animação
		
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

; Draw rectangle border function
; Params: PUSH x1, y1, x2, y2
retangle:
		PUSH	BP
		MOV		BP,SP
		PUSHF             		;coloca os flags na pilha
		PUSH 	AX
		PUSH 	BX
		PUSH	CX
		PUSH	DX
		PUSH	SI
		PUSH	DI

		MOV		AX,[BP+10]    			
		MOV		BX,[BP+8]    			
		MOV		CX,[BP+6]    			
		MOV 	DX,[BP+4]

		PUSH	AX				; x1 
		PUSH 	BX				; y1
		PUSH 	CX				; x2	
		PUSH 	BX				; y1
		CALL	line
		

		PUSH	AX				; x1
		PUSH 	BX				; y1
		PUSH 	AX				; x1
		PUSH 	DX				; y2
		CALL	line
		
		PUSH	AX				; x1
		PUSH 	DX				; y2
		PUSH 	CX				; x2
		PUSH 	DX				; y2
		CALL	line
		
		PUSH	CX				; x2
		PUSH 	DX				; y2
		PUSH 	CX				; x2
		PUSH 	BX				; y1
		CALL	line
		

		POP DI
		POP SI
		POP DX
		POP CX
		POP BX
		POP AX
		POPF
		POP BP
		RET 8                     ; Return and clean stack

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
;*************************************************************************
segment stack stack
	resb	512
stacktop: