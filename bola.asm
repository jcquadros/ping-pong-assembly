global desenha_bola
extern circle, ball_x, ball_y, ball_radius

desenha_bola:
    MOV AX, [ball_x]
	PUSH AX
	MOV AX, [ball_y]
	PUSH AX
	MOV AX, [ball_radius]       
	PUSH AX
	CALL circle             
    RET