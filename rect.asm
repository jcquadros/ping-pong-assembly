extern line
global retangle

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