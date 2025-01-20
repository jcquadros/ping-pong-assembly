extern line
global full_retangle
		
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

