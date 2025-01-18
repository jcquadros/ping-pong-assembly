
extern plot_xy
global circle

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