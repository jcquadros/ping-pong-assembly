extern line
global desenha_bordas

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