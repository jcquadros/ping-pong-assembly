; versão de 10/05/2007
; corrigido erro de arredondamento na rotina line.
; circle e full_circle DISPonibilizados por JEfferson Moro em 10/2009
; 
segment code
..start:
;Inicializa registradores
    	MOV		AX,data
    	MOV 	DS,AX
    	MOV 	AX,stack
    	MOV 	SS,AX
    	MOV 	SP,stacktop

;Salvar modo corrente de video(vendo como está o modo de video da maquina)
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
		MOV AX, 320                   ; Coordenada inicial X (meio da tela)
		MOV word [ball_x], AX
		MOV AX, 240                   ; Coordenada inicial Y (meio da tela)
		MOV word [ball_y], AX
		MOV word [direction_x], 1              ; Direção X (movendo para a direita)
		MOV word [direction_y], 1             ; Direção Y (movendo para cima)
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
		CALL circle            ; Apaga o círculo

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


;-----------------------------------------------------------------------------
;função cursor
; Parametros:
; 	DH = linha (0-29) e  DL = coluna  (0-79)
cursor:
		PUSHF
		PUSH 	AX
		PUSH 	BX
		PUSH	CX
		PUSH	DX
		PUSH	SI
		PUSH	DI
		PUSH	BP
		MOV     AH,2
		MOV     BH,0
		INT     10h
		POP		BP
		POP		DI
		POP		SI
		POP		DX
		POP		CX
		POP		BX
		POP		AX
		POPF
		RET
;-----------------------------------------------------------------------------
;função caracter escrito na posição do cursor
; Parametros:
; 	AL = caracter a ser escrito
; 	cor definida na variavel cor
caracter:
		PUSHF
		PUSH 	AX
		PUSH 	BX
		PUSH	CX
		PUSH	DX
		PUSH	SI
		PUSH	DI
		PUSH	BP
    	MOV     AH,9
    	MOV     BH,0
    	MOV     CX,1
   		MOV     bl,[cor]
    	INT     10h
		POP		BP
		POP		DI
		POP		SI
		POP		DX
		POP		CX
		POP		BX
		POP		AX
		POPF
		RET
;-----------------------------------------------------------------------------
;função plot_xy
; Parametros:
;	PUSH x; PUSH y; CALL plot_xy;  (x<639, y<479)
; 	cor definida na variavel cor
plot_xy:
		PUSH	BP
		MOV		BP,SP
		PUSHF
		PUSH 	AX
		PUSH 	BX
		PUSH	CX
		PUSH	DX
		PUSH	SI
		PUSH	DI
	    MOV     AH,0Ch
	    MOV     AL,[cor]
	    MOV     BH,0
	    MOV     DX,479
		SUB		DX,[BP+4]
	    MOV     CX,[BP+6]
	    INT     10h
		POP		DI
		POP		SI
		POP		DX
		POP		CX
		POP		BX
		POP		AX
		POPF
		POP		BP
		RET		4
;-----------------------------------------------------------------------------
;função circle
; Parametros:
;	PUSH xc; PUSH yc; PUSH r; CALL circle;  (xc+r<639,yc+r<479)e(xc-r>0,yc-r>0)
; 	cor definida na variavel cor
circle:
	PUSH 	BP
	MOV	 	BP,SP
	PUSHF                        	;coloca os flags na pilha
	PUSH 	AX
	PUSH 	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI
	
	MOV		AX,[BP+8]    			;resgata xc
	MOV		BX,[BP+6]    			;resgata yc
	MOV		CX,[BP+4]    			;resgata r
	
	MOV 	DX,BX	
	ADD		DX,CX       			;ponto extremo superior
	PUSH    AX			
	PUSH	DX
	CALL plot_xy
	
	MOV		DX,BX
	SUB		DX,CX       			;ponto extremo inferior
	PUSH    AX			
	PUSH	DX
	CALL plot_xy
	
	MOV 	DX,AX	
	ADD		DX,CX       			;ponto extremo DIreita
	PUSH    DX			
	PUSH	BX
	CALL plot_xy
	
	MOV		DX,AX
	SUB		DX,CX       			;ponto extremo esquerda
	PUSH    DX			
	PUSH	BX
	CALL plot_xy
		
	MOV		DI,CX
	SUB		DI,1	 				;DI = r-1
	MOV		DX,0  					;DX será a variável x. CX é a variavel y
	
;Aqui em cima a lógica foi invertida, 1-r => r-1 e as comparações passaram a 
; ser JL => JG, assim garante valores positivos para d

stay:								;LOOP
	MOV		SI,DI
	CMP		SI,0
	JG		inf       				;caso d for menor que 0, seleciona pixel superior (não  SALta)
	MOV		SI,DX					;o JL é importante porque trata-se de conta com sinal
	SAL		SI,1					;multiplica por dois (shift arithmetic left)
	ADD		SI,3
	ADD		DI,SI     				;nesse ponto d = d+2*DX+3
	INC		DX						;Incrementa DX
	JMP		plotar
inf:	
	MOV		SI,DX
	SUB		SI,CX  					;faz x - y (DX-CX), e SALva em DI 
	SAL		SI,1
	ADD		SI,5
	ADD		DI,SI					;nesse ponto d = d+2*(DX-CX)+5
	INC		DX						;Incrementa x (DX)
	DEC		CX						;Decrementa y (CX)
	
plotar:	
	MOV		SI,DX
	ADD		SI,AX
	PUSH    SI						;coloca a abcisa x+xc na pilha
	MOV		SI,CX
	ADD		SI,BX
	PUSH    SI						;coloca a ordenada y+yc na pilha
	CALL plot_xy					;toma conta do segundo octante
	MOV		SI,AX
	ADD		SI,DX
	PUSH    SI						;coloca a abcisa xc+x na pilha
	MOV		SI,BX
	SUB		SI,CX
	PUSH    SI						;coloca a ordenada yc-y na pilha
	CALL plot_xy					;toma conta do s�timo octante
	MOV		SI,AX
	ADD		SI,CX
	PUSH    SI						;coloca a abcisa xc+y na pilha
	MOV		SI,BX
	ADD		SI,DX
	PUSH    SI						;coloca a ordenada yc+x na pilha
	CALL plot_xy					;toma conta do segundo octante
	MOV		SI,AX
	ADD		SI,CX
	PUSH    SI						;coloca a abcisa xc+y na pilha
	MOV		SI,BX
	SUB		SI,DX
	PUSH    SI						;coloca a ordenada yc-x na pilha
	CALL plot_xy					;toma conta do oitavo octante
	MOV		SI,AX
	SUB		SI,DX
	PUSH    SI						;coloca a abcisa xc-x na pilha
	MOV		SI,BX
	ADD		SI,CX
	PUSH    SI						;coloca a ordenada yc+y na pilha
	CALL plot_xy					;toma conta do terceiro octante
	MOV		SI,AX
	SUB		SI,DX
	PUSH    SI						;coloca a abcisa xc-x na pilha
	MOV		SI,BX
	SUB		SI,CX
	PUSH    SI						;coloca a ordenada yc-y na pilha
	CALL plot_xy					;toma conta do sexto octante
	MOV		SI,AX
	SUB		SI,CX
	PUSH    SI						;coloca a abcisa xc-y na pilha
	MOV		SI,BX
	SUB		SI,DX
	PUSH    SI						;coloca a ordenada yc-x na pilha
	CALL plot_xy					;toma conta do quINTo octante
	MOV		SI,AX
	SUB		SI,CX
	PUSH    SI						;coloca a abcisa xc-y na pilha
	MOV		SI,BX
	ADD		SI,DX
	PUSH    SI						;coloca a ordenada yc-x na pilha
	CALL plot_xy					;toma conta do quarto octante
	
	CMP		CX,DX
	JB		fim_circle  			;se CX (y) está abaixo de DX (x), termina     
	JMP		stay					;se CX (y) está acima de DX (x), continua no LOOP
	
fim_circle:
	POP		DI
	POP		SI
	POP		DX
	POP		CX
	POP		BX
	POP		AX
	POPF
	POP		BP
	RET		6
;-----------------------------------------------------------------------------
;função full_circle
; Parametros:
;	PUSH xc; PUSH yc; PUSH r; CALL full_circle;  (xc+r<639,yc+r<479)e(xc-r>0,yc-r>0)
; 	cor definida na variavel cor					  
full_circle:
	PUSH 	BP
	MOV	 	BP,SP
	PUSHF                        ;coloca os flags na pilha
	PUSH 	AX
	PUSH 	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI

	MOV		AX,[BP+8]    		;resgata xc
	MOV		BX,[BP+6]    		;resgata yc
	MOV		CX,[BP+4]    		;resgata r
	
	MOV		SI,BX
	SUB		SI,CX
	PUSH    AX					;coloca xc na pilha			
	PUSH	SI					;coloca yc-r na pilha
	MOV		SI,BX
	ADD		SI,CX
	PUSH	AX					;coloca xc na pilha
	PUSH	SI					;coloca yc+r na pilha
	CALL line
		
	MOV		DI,CX
	SUB		DI,1	 			;DI = r-1
	MOV		DX,0  				;DX será a variável x. CX é a variavel y
	
;aqui em cima a lógica foi invertida, 1-r => r-1 e as comparações passaram a ser
;JL => JG, assimm garante valores positivos para d

stay_full:						;LOOP
	MOV		SI,DI
	CMP		SI,0
	JG		inf_full       		;caso d for menor que 0, seleciona pixel superior (não  salta)
	MOV		SI,DX				;o JL é importante porque trata-se de conta com sinal
	SAL		SI,1				;multiplica por doi (shift arithmetic left)
	ADD		SI,3
	ADD		DI,SI     			;nesse ponto d = d+2*DX+3
	INC		DX					;Incrementa DX
	JMP		plotar_full
inf_full:	
	MOV		SI,DX
	SUB		SI,CX  				;faz x - y (DX-CX), e salva em DI 
	SAL		SI,1
	ADD		SI,5
	ADD		DI,SI				;nesse ponto d=d+2*(DX-CX)+5
	INC		DX					;Incrementa x (DX)
	DEC		CX					;Decrementa y (CX)
	
plotar_full:	
	MOV		SI,AX
	ADD		SI,CX
	PUSH	SI					;coloca a abcisa y+xc na pilha			
	MOV		SI,BX
	SUB		SI,DX
	PUSH    SI					;coloca a ordenada yc-x na pilha
	MOV		SI,AX
	ADD		SI,CX
	PUSH	SI					;coloca a abcisa y+xc na pilha	
	MOV		SI,BX
	ADD		SI,DX
	PUSH    SI					;coloca a ordenada yc+x na pilha	
	CALL 	line
	
	MOV		SI,AX
	ADD		SI,DX
	PUSH	SI					;coloca a abcisa xc+x na pilha			
	MOV		SI,BX
	SUB		SI,CX
	PUSH    SI					;coloca a ordenada yc-y na pilha
	MOV		SI,AX
	ADD		SI,DX
	PUSH	SI					;coloca a abcisa xc+x na pilha	
	MOV		SI,BX
	ADD		SI,CX
	PUSH    SI					;coloca a ordenada yc+y na pilha	
	CALL	line
	
	MOV		SI,AX
	SUB		SI,DX
	PUSH	SI					;coloca a abcisa xc-x na pilha			
	MOV		SI,BX
	SUB		SI,CX
	PUSH    SI					;coloca a ordenada yc-y na pilha
	MOV		SI,AX
	SUB		SI,DX
	PUSH	SI					;coloca a abcisa xc-x na pilha	
	MOV		SI,BX
	ADD		SI,CX
	PUSH    SI					;coloca a ordenada yc+y na pilha	
	CALL	line
	
	MOV		SI,AX
	SUB		SI,CX
	PUSH	SI					;coloca a abcisa xc-y na pilha			
	MOV		SI,BX
	SUB		SI,DX
	PUSH    SI					;coloca a ordenada yc-x na pilha
	MOV		SI,AX
	SUB		SI,CX
	PUSH	SI					;coloca a abcisa xc-y na pilha	
	MOV		SI,BX
	ADD		SI,DX
	PUSH    SI					;coloca a ordenada yc+x na pilha	
	CALL	line
	
	CMP		CX,DX
	JB		fim_full_circle  	;se CX (y) está abaixo de DX (x), termina     
	JMP		stay_full			;se CX (y) está acima de DX (x), continua no LOOP
	
fim_full_circle:
	POP		DI
	POP		SI
	POP		DX
	POP		CX
	POP		BX
	POP		AX
	POPF
	POP		BP
	RET		6
;-----------------------------------------------------------------------------
;função line
; Parametros:
;	PUSH x1; PUSH y1; PUSH x2; PUSH y2; CALL line;  (x<639, y<479)
line:
		PUSH	BP
		MOV		BP,SP
		PUSHF             		;coloca os flags na pilha
		PUSH 	AX
		PUSH 	BX
		PUSH	CX
		PUSH	DX
		PUSH	SI
		PUSH	DI
		MOV		AX,[BP+10]   	;resgata os vALores das coordenadas
		MOV		BX,[BP+8]    	;resgata os vALores das coordenadas
		MOV		CX,[BP+6]    	;resgata os vALores das coordenadas
		MOV		DX,[BP+4]    	;resgata os vALores das coordenadas
		CMP		AX,CX
		JE		line2
		JB		line1
		XCHG	AX,CX
		XCHG	BX,DX
		JMP		line1
line2:							;deltax = 0
		CMP		BX,DX  			;Subtrai DX de BX
		JB		line3
		XCHG	BX,DX        	;troca os valores de BX e DX entre eles
line3:							;DX > BX
		PUSH	AX
		PUSH	BX
		CALL 	plot_xy
		CMP		BX,DX
		JNE		line31
		JMP		fim_line
line31:	INC		BX
		JMP		line3
;deltax <>0
line1:
;Comparar módulos de deltax e deltay sabendo que CX>AX
	; CX > AX
		PUSH	CX
		SUB		CX,AX
		MOV		[deltax],CX
		POP		CX
		PUSH	DX
		SUB		DX,BX
		JA		line32
		NEG		DX
line32:		
		MOV		[deltay],DX
		POP		DX

		PUSH	AX
		MOV		AX,[deltax]
		CMP		AX,[deltay]
		POP		AX
		JB		line5
; CX > AX e deltax>deltay
		PUSH	CX
		SUB		CX,AX
		MOV		[deltax],CX
		POP		CX
		PUSH	DX
		SUB		DX,BX
		MOV		[deltay],DX
		POP		DX

		MOV		SI,AX
line4:
		PUSH	AX
		PUSH	DX
		PUSH	SI
		SUB		SI,AX	;(x-x1)
		MOV		AX,[deltay]
		IMUL	SI
		MOV		SI,[deltax]		;arredondar
		SHR		SI,1
;Se numerador (DX)>0 soma se <0 Subtrai
		CMP		DX,0
		JL		ar1
		ADD		AX,SI
		ADC		DX,0
		JMP		arc1
ar1:	SUB		AX,SI
		SBB		DX,0
arc1:
		IDIV	word [deltax]
		ADD		AX,BX
		POP		SI
		PUSH	SI
		PUSH	AX
		CALL	plot_xy
		POP		DX
		POP		AX
		CMP		SI,CX
		JE		fim_line
		INC		SI
		JMP		line4

line5:	CMP		BX,DX
		JB 		line7
		XCHG	AX,CX
		XCHG	BX,DX
line7:
		PUSH	CX
		SUB		CX,AX
		MOV		[deltax],CX
		POP		CX
		PUSH	DX
		SUB		DX,BX
		MOV		[deltay],DX
		POP		DX

		MOV		SI,BX
line6:
		PUSH	DX
		PUSH	SI
		PUSH	AX
		SUB		SI,BX	;(y-y1)
		MOV		AX,[deltax]
		IMUL	SI
		MOV		SI,[deltay]		;arredondar
		SHR		SI,1
;Se numerador (DX)>0 soma se <0 subtrai
		CMP		DX,0
		JL		ar2
		ADD		AX,SI
		ADC		DX,0
		JMP		arc2
ar2:	SUB		AX,SI
		SBB		DX,0
arc2:
		IDIV	word [deltay]
		MOV		DI,AX
		POP		AX
		ADD		DI,AX
		POP		SI
		PUSH	DI
		PUSH	SI
		CALL	plot_xy
		POP		DX
		CMP		SI,DX
		JE		fim_line
		INC		SI
		JMP		line6

fim_line:
		POP		DI
		POP		SI
		POP		DX
		POP		CX
		POP		BX
		POP		AX
		POPF
		POP		BP
		RET		8


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
		
full_retangle:
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
		
		; se x1 > x2, troca
		CMP		AX,CX
		JL		swap_y_coordinates
		XCHG	AX,CX

swap_y_coordinates:
		; se y1 > y2, troca
		JL 		full_retangle_loop
		XCHG	BX,DX

full_retangle_loop:
		; enquanto y1 < y2 escreve a linha horizontal e incrementa y1
		PUSH	AX				; x1
		PUSH 	BX				; y1
		PUSH 	CX				; x2
		PUSH 	BX				; y1
		CALL	line
		INC		BX
		CMP		BX,DX
		JL		full_retangle_loop
		
full_retangle_end:
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
