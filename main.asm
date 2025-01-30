extern line, circle, full_circle, cursor, caracter, rectangle,full_rectangle, desenha_bordas , desenha_blocos, desenha_raquete, move_raquete_cima, move_raquete_baixo, desenha_bola, verifica_colisao, escreve_mensagem
global cor,  j1_blocos, j2_blocos, j1_raquete, j2_raquete, ball_x, ball_y, ball_radius, direction_x, direction_y, j1_status, j2_status, game_over, deltax, deltay, mens

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
	
	; Inicializa o teclado
    CLI
    XOR     AX, AX
    MOV     ES, AX
    MOV     AX, [ES:INT9*4]
    MOV     [offset_dos], AX
    MOV     AX, [ES:INT9*4+2]
    MOV     [cs_dos], AX
    MOV     [ES:INT9*4+2], CS
    MOV     word [ES:INT9*4], keyINT
    STI

tela_inicial:
	; Configura gráficos iniciais
	MOV byte [cor], verde  ; Definir cor antes da chamada
	MOV AX, 13				;Linha
	PUSH AX 
	MOV AX, 35				;Coluna
	PUSH AX             
	MOV SI, mensagem_fácil
	PUSH SI
    CALL escreve_mensagem
	
	MOV byte [cor], amarelo
	MOV AX, 14				;Linha
	PUSH AX
	MOV AX, 35				;Coluna
	PUSH AX
	MOV SI, mensagem_médio
	PUSH SI
	CALL escreve_mensagem
	
	MOV byte [cor], vermelho
	MOV AX, 15				;Linha
	PUSH AX
	MOV AX, 35				;Coluna
	PUSH AX
	MOV SI, mensagem_difícil
	PUSH SI
	CALL escreve_mensagem
	

navega_tela_inicial:
	MOV byte [cor], branco_intenso
	CALL desenha_opcao_cursor

	; Verifica se há uma tecla pressionada
	CALL verifica_se_tecla_pressionada	
	MOV  AL, byte [estado_jogo]
	CMP AL, estado_inicial
	JE navega_tela_inicial
	MOV BL, estado_inicial
	JMP navega_entre_telas

tela_jogo:
	MOV byte [cor], branco_intenso
	CALL desenha_bordas
	MOV byte [cor], magenta
	MOV SI, j1_blocos
	MOV DI, j1_status
	CALL desenha_blocos
	MOV byte [cor], azul
	MOV SI, j2_blocos
	MOV DI, j2_status
	CALL desenha_blocos
	

; Loop da animacao da bolinha na tela		
animacao_loop:
	; Limpa o círculo anterior
	MOV byte [cor], preto
	CALL desenha_bola           		

	MOV byte [cor], preto
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
	CALL desenha_bola          		
	
	; Desenha as raquetes
	MOV byte [cor], magenta
	MOV SI, j1_raquete
	CALL desenha_raquete
	MOV byte [cor], azul
	MOV SI, j2_raquete
	CALL desenha_raquete
	
	CALL verifica_se_tecla_pressionada
    CALL delay
	MOV  AL, byte [estado_jogo]
	CMP AL, estado_jogando
	JE animacao_loop
	MOV BL, estado_jogando
	JMP navega_entre_telas


tela_pausado:
	MOV byte [cor], amarelo
	MOV AX, 14				;Linha
	PUSH AX
	MOV AX, 17				;Coluna
	PUSH AX
	MOV SI, mensagem_pausado
	PUSH SI
	CALL escreve_mensagem
	
	CALL verifica_se_tecla_pressionada
	MOV BL, estado_pausado
	JMP navega_entre_telas

game_over:
	MOV byte [estado_jogo], estado_game_over
	MOV BL, estado_jogando
	JMP navega_entre_telas

navega_entre_telas:
	; requer BL = estado anterior
	MOV  AL, byte [estado_jogo]
	CMP AL, BL 
	JE nao_apaga_tela
	CALL apaga_tudo
nao_apaga_tela:
	MOV  AL, byte [estado_jogo]
	CMP AL, estado_inicial
	JE pula_para_tela_inicial
	CMP AL, estado_jogando
	JE pula_para_tela_jogo
	CMP AL, estado_pausado
	JE pula_para_tela_pausado
	CMP AL, estado_game_over
	JE pula_para_tela_game_over
	JMP tela_sair

pula_para_tela_inicial:
	JMP tela_inicial
pula_para_tela_jogo:
	JMP tela_jogo
pula_para_tela_pausado:
	JMP tela_pausado
pula_para_tela_game_over:
	JMP tela_game_over

tela_sair:
	MOV byte [cor], vermelho
	MOV AX, 14				;Linha
	PUSH AX
	MOV AX, 25				;Coluna
	PUSH AX
	MOV SI, mensagem_sair
	PUSH SI
	CALL escreve_mensagem
	
	CALL verifica_se_tecla_pressionada
	MOV BL, estado_sair
	JMP navega_entre_telas
	
verifica_se_tecla_pressionada:
	MOV     AX, [p_i]
	CMP     AX, [p_t]
	JNE      eh_tecla_pressionada
	RET
	
; Verifica qual tecla foi pressionada
eh_tecla_pressionada:
    INC     word [p_t]
    AND     word [p_t], 7
    MOV     BX, [p_t]
    XOR     AX, AX
    MOV     AL, [BX+tecla]
    MOV     [tecla_ascii], AL

; Converte o código da tecla para ASCII - parte menos significativa
convertendo_tecla_low:
    MOV     BL, 16
    DIV     BL
    ADD     AL, 30h
    CMP     AL, 3Ah
    JB      converte_tecla_high
    ADD     AL, 07h

; Converte o código da tecla para ASCII - parte mais significativa
converte_tecla_high:
    ADD     AH, 30h
    CMP     AH, 3Ah
    JB      compara_tecla; Se for número
    ADD     AH, 07h ; Se for letra (Adiciona 7 para pular os caracteres especiais)
	
compara_tecla:
	MOV  AL, byte [estado_jogo]
	CMP AL, estado_inicial
	JE pula_para_tecla_inicial
	CMP AL, estado_jogando
	JE pula_para_tecla_jogando
	CMP AL, estado_pausado
	JE pula_para_tecla_pausado
	CMP AL, estado_sair
	JE pula_para_tecla_sair
	JMP tecla_game_over
	
	RET
pula_para_tecla_inicial:
	JMP tecla_menu_inicial
pula_para_tecla_jogando:
	JMP tecla_jogando
pula_para_tecla_pausado:
	JMP tecla_pausado
pula_para_tecla_sair:
	JMP tecla_sair

tecla_menu_inicial:
    ; Verifica se a tecla pressionada foi seta para cima
    CMP  byte [tecla_ascii], 48h  ; Código da tecla ↑ (seta para cima)
    JE   mover_cima

    ; Verifica se a tecla pressionada foi seta para baixo
    CMP  byte [tecla_ascii], 50h  ; Código da tecla ↓ (seta para baixo)
    JE   mover_baixo

    ; Verifica se a tecla pressionada foi Enter
    CMP  byte [tecla_ascii], 1Ch  ; Código da tecla Enter
    JE   selecionar_opcao
	
	; Verifica se a tecla pressionada foi 'q'
	CMP    byte [tecla_ascii], 10h ; Código Make da tecla 'q'
	JNE fim_tecla_menu_inicial
	MOV AL, byte [estado_jogo]
	MOV byte [estado_antes_de_sair], AL
	MOV byte [estado_jogo], estado_sair

fim_tecla_menu_inicial:
    RET

mover_cima:
    CMP  byte [opcao], 0   ; Se opcao já é 0, não decrementar
    JLE  fim_mover_cima
	MOV byte [cor], preto
	CALL desenha_opcao_cursor
    DEC  byte [opcao]      ; Decrementa a opcao se não for menor que 0
fim_mover_cima:
    RET

mover_baixo:
    CMP  byte [opcao], 2   ; Se opcao já é 2, não incrementar
    JGE  fim_mover_baixo
	MOV byte [cor], preto
	CALL desenha_opcao_cursor
    INC  byte [opcao]      ; Incrementa a opcao se não for maior que 2
fim_mover_baixo:
    RET

selecionar_opcao:
	MOV byte [estado_jogo], estado_jogando
    MOV  AL, byte [opcao]      ; Carrega a opção selecionada
    CMP  AL, 0
    JE   opcao_0
    CMP  AL, 1
    JE   opcao_1
    CMP  AL, 2
    JE   opcao_2
    RET

opcao_0:
    MOV  byte [vel], 20   ; Se opção 0 foi selecionada, define velocidade para 10
    RET

opcao_1:
    MOV  byte [vel], 10   ; Se opção 1 foi selecionada, define velocidade para 20
    RET

opcao_2:
    MOV  byte [vel], 0   ; Se opção 2 foi selecionada, define velocidade para 30
    RET

tecla_jogando:

	CMP    byte [tecla_ascii], 10h ; Código Make da tecla 'q'
	JNE p
	MOV AL, byte [estado_jogo]
	MOV byte [estado_antes_de_sair], AL
	MOV byte [estado_jogo], estado_sair
p:
	; verifica se a tecla pressionada foi 'p'
	CMP  byte [tecla_ascii] , 19h
	JNE w
    MOV byte [estado_jogo], estado_pausado
	RET

w:
	; Verifica se a tecla pressionada foi 'w'
	CMP    byte [tecla_ascii], 11h ; Código Make da tecla 'w'
	JNE s
	MOV byte [cor], preto
	MOV SI, j1_raquete
	CALL move_raquete_cima
	RET
s:
	; Verifica se a tecla pressionada foi 's'
	CMP    byte [tecla_ascii], 1Fh ; Código Make da tecla 's'
	JNE seta_cima
	MOV byte [cor], preto
	MOV SI, j1_raquete
	CALL move_raquete_baixo
	RET

seta_cima:	
	; Verifica se a tecla pressionada foi a seta para cima (Make Code 48h)
	CMP    byte [tecla_ascii], 48h
	JNE seta_baixo
	MOV byte [cor], preto
	MOV SI, j2_raquete
	CALL move_raquete_cima
	RET

seta_baixo:
	; Verifica se a tecla pressionada foi a seta para baixo (Make Code 50h)
	CMP    byte [tecla_ascii], 50h
	JNE seta_baixo_sair
	MOV byte [cor], preto
	MOV SI, j2_raquete
	CALL move_raquete_baixo
seta_baixo_sair:	
	RET
tecla_pausado:
	; verifica se a tecla pressionada foi 'p'
	CMP  byte [tecla_ascii] , 19h
	JE despausar

	; Verifica se a tecla pressionada foi 'q'
	CMP    byte [tecla_ascii], 10h ; Código Make da tecla 'q'
	JNE fim_tecla_pausado
	MOV AL, byte [estado_jogo]
	MOV byte [estado_antes_de_sair], AL
	MOV byte [estado_jogo], estado_sair

fim_tecla_pausado:
	RET

despausar:
    MOV byte [estado_jogo], estado_jogando
	RET

tecla_sair:
	; Verifica se a tecla pressionada foi 'y'
	CMP    byte [tecla_ascii], 15h ; Código Make da tecla 'y'
	JE sair

	; Verifica se a tecla pressionada foi 'n'
	CMP    byte [tecla_ascii], 31h ; Código Make da tecla 'n'
	JNE fim_tecla_sair
	MOV AL, byte [estado_antes_de_sair]
	MOV byte [estado_jogo], AL
fim_tecla_sair:
	RET

tecla_game_over:
	; Verifica se a tecla pressionada foi 'n'
	CMP    byte [tecla_ascii], 31h ; Código Make da tecla 'n'
	JE sair		
	
	; Verifica se a tecla pressionada foi 'y'
	CMP    byte [tecla_ascii], 15h ; Código Make da tecla 'y'
	JNE fim_tecla_game_over
	MOV byte [estado_jogo], estado_inicial
	MOV word [ball_x], 320
	MOV word [ball_y], 240
	MOV word [direction_x], 1
	MOV word [direction_y], 1
	MOV CX, 5
	MOV SI, j1_status
	CALL reinicia_blocos
	MOV CX, 5
	MOV SI, j2_status
	CALL reinicia_blocos
	MOV word [j1_raquete], 22
	MOV word [j1_raquete+2], 194
	MOV word [j1_raquete+4], 42
	MOV word [j1_raquete+6], 286
	MOV word [j2_raquete], 597
	MOV word [j2_raquete+2], 194
	MOV word [j2_raquete+4], 617
	MOV word [j2_raquete+6], 286
fim_tecla_game_over:
	RET
sair:
	; Restaura o modo de vídeo original e finaliza o programa
    CLI
	MOV AX, 0								
	MOV ES, AX
    MOV AX, [cs_dos]
    MOV [ES:INT9*4+2], AX
    MOV AX, [offset_dos]
    MOV [ES:INT9*4], AX
    STI
    MOV AH, 0
    MOV AL, [modo_anterior]
    INT 10h
    MOV AX, 4C00h
    INT 21h
reinicia_blocos:
	MOV byte [SI], 1
	ADD SI, 1
	LOOP reinicia_blocos
	RET
tela_game_over:
	MOV byte [cor], amarelo
	MOV AX, 14				;Linha
	PUSH AX
	MOV AX, 17				;Coluna
	PUSH AX
	MOV SI, mensagem_game_over
	PUSH SI
	CALL escreve_mensagem
	
	CALL verifica_se_tecla_pressionada
	MOV BL, estado_game_over
	JMP navega_entre_telas

; Função de atraso (delay)
delay:
	MOV AH, 0
	MOV AL, byte [vel]        ; Carrega "vel" para ajustar o atraso
	CMP AL, 0
	JE fim_delay
	MOV CX, AX
del2:
	PUSH CX
	MOV CX, 0800h             ; Loop interno para criar atraso
del1:
	LOOP del1
	POP CX
	LOOP del2
fim_delay:
	RET


keyINT:									; Este segmento de código só será executado se uma tecla for presionada, ou seja, se a INT 9h for acionada!
        PUSH    AX						
        PUSH    BX
        PUSH    DS
        IN      AL, kb_data				
        INC     word [p_i]				
        AND     word [p_i],7			
        MOV     BX,[p_i]				
        MOV     [BX+tecla],al			
        IN      AL, kb_ctl				
        OR      AL, 80h					
        OUT     kb_ctl, AL				
        AND     AL, 7Fh					
        OUT     kb_ctl, AL				
        MOV     AL, eoi					
        OUT     pictrl, AL				
        
		POP     DS						
        POP     BX
        POP     AX
        IRET

desenha_opcao_cursor:
	MOV AX, 13				;Linha
	ADD AX, [opcao]
	PUSH AX
	MOV AX, 34				;Coluna
	PUSH AX
	MOV SI, opcao_cursor
	PUSH SI
	CALL escreve_mensagem
	RET
apaga_tudo:
	; Configura gráficos iniciais
	MOV byte [cor], preto  ; Definir cor antes da chamada
	MOV AX, 13				;Linha
	PUSH AX 
	MOV AX, 35				;Coluna
	PUSH AX             
	MOV SI, mensagem_fácil
	PUSH SI
    CALL escreve_mensagem

	MOV AX, 14				;Linha
	PUSH AX
	MOV AX, 35				;Coluna
	PUSH AX
	MOV SI, mensagem_médio
	PUSH SI
	CALL escreve_mensagem
	
	MOV AX, 15				;Linha
	PUSH AX
	MOV AX, 35				;Coluna
	PUSH AX
	MOV SI, mensagem_difícil
	PUSH SI
	CALL escreve_mensagem

	MOV AX, 14				;Linha
	PUSH AX
	MOV AX, 17				;Coluna
	PUSH AX
	MOV SI, mensagem_game_over
	PUSH SI
	CALL escreve_mensagem
	
	MOV AX, 14
	PUSH AX
	MOV AX, 17
	PUSH AX
	MOV SI, mensagem_pausado
	PUSH SI
	CALL escreve_mensagem
	
	MOV AX, 14				;Linha
	PUSH AX
	MOV AX, 25				;Coluna
	PUSH AX
	MOV SI, mensagem_sair
	PUSH SI
	CALL escreve_mensagem
	
	CALL desenha_opcao_cursor
	MOV SI, j1_blocos
	MOV DI, j1_status
	CALL desenha_blocos
	MOV SI, j2_blocos
	MOV DI, j2_status
	CALL desenha_blocos
	CALL desenha_bordas
	MOV SI, j1_raquete
	CALL desenha_raquete
	MOV SI, j2_raquete
	CALL desenha_raquete
	CALL desenha_bola
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

; Coordenadas da bola
ball_x 			dw 320                   ; Coordenada X da bola
ball_y 			dw 240                   ; Coordenada Y da bola
ball_radius 	dw 10             ; Raio da bola
direction_x     dw 1                   ; Direção no eixo X
direction_y     dw 1                   ; Direção no eixo Y
vel    			db 10                   ; Velocidade do movimento

modo_anterior	db		0
linha   		dw  	0
coluna  		dw  	0
deltax			dw		0
deltay			dw		0	
mensagem_fácil 		db  	'Facil', 0
mensagem_médio 		db  	'Medio', 0
mensagem_difícil 	db  	'Dificil', 0
opcao_cursor		db		'>', 0
mensagem_pausado	db		'Jogo Pausado! Pressione P para voltar a jogar.', 0
mensagem_game_over	db		'Game Over! Deseja jogar novamente? (Y/N)', 0
mensagem_sair		db		'Deseja sair do jogo? (Y/N)', 0
opcao 				db		0

; Coordenadas dos blocos do Jogador 1
j1_blocos 	dw 0, 0, 20, 92       ; x1, y1, x2, y2 (Bloco 1)
           	dw 0, 97, 20, 189    ; Bloco 2
           	dw 0, 194, 20, 286   ; Bloco 3
           	dw 0, 291, 20, 383   ; Bloco 4
           	dw 0, 388, 20, 479   ; Bloco 5

; Coordenadas dos blocos do Jogador 2
j2_blocos 	dw 619, 0, 639, 92    ; x1, y1, x2, y2 (Bloco 1)
           	dw 619, 97, 639, 189 ; Bloco 2
           	dw 619, 194, 639, 286; Bloco 3
           	dw 619, 291, 639, 383; Bloco 4
           	dw 619, 388, 639, 479; Bloco 5

j1_raquete dw  22, 194, 42, 286
j2_raquete dw 597, 194, 617, 286

; Estado dos blocos (1 = ativo, 0 = destruído)
j1_status db 1, 1, 1, 1, 1      ; Estado dos blocos do Jogador 1
j2_status db 1, 1, 1, 1, 1      ; Estado dos blocos do Jogador 2

jogando db 1
estado_jogo db 0 ; Indica o estado do jogo (0 = menu inicial, 1 = jogando, 2 = pausado, 3 = game over, 4 = tela sair)
estado_inicial equ 0
estado_jogando equ 1
estado_pausado equ 2
estado_game_over equ 3
estado_sair equ 4

estado_antes_de_sair db 0

; Variáveis para o teclado
kb_data equ 60h  				; PORTA DE LEITURA DE TECLADO
kb_ctl  equ 61h  				; PORTA DE RESET PARA PEDIR NOVA INTERRUPCAO
pictrl  equ 20h					; PORTA DO PIC DE TECLADO
eoi     equ 20h					; Byte de final de interrupção PIC - resgistrador
INT9    equ 9h					; Interrupção por hardware do teclado
cs_dos  dw  1					; Variável de 2 bytes para armacenar o CS da INT 9
offset_dos  dw 1				; Variável de 2 bytes para armacenar o IP da INT 9
tecla_ascii db 0
tecla   resb  8					; Variável de 8 bytes para armacenar a tecla presionada. Só precisa de 2 bytes!	 
p_i     dw  0   				; Indice p/ Interrupcao (Incrementa na ISR quando pressiona/solta qualquer tecla)  
p_t     dw  0   				; Indice p/ Interrupcao (Incrementa após retornar da ISR quando pressiona/solta qualquer tecla)    


;*************************************************************************
segment stack stack
	resb	512
stacktop: