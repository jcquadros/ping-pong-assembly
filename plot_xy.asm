
extern cor
global plot_xy
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