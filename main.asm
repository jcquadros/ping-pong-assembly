extern line, circle, full_circle, cursor, caracter, rectangle,full_rectangle, desenha_bordas , desenha_blocos_j1, desenha_blocos_j2, desenha_raquete_j1, desenha_raquete_j2, move_raquete_j1_cima, move_raquete_j1_baixo, move_raquete_j2_cima, move_raquete_j2_baixo, desenha_bola
global cor,  j1_blocos, j2_blocos, j1_raquete, j2_raquete, ball_x, ball_y, ball_radius
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

	; Configura gráficos iniciais
	MOV byte [cor], branco_intenso
	CALL desenha_bordas
	MOV byte [cor], magenta
	CALL desenha_blocos_j1
	MOV byte [cor], azul
	CALL desenha_blocos_j2

; Loop da animacao da bolinha na tela		
animacao_loop:
	; Limpa o círculo anterior
	MOV byte [cor], preto
	CALL desenha_bola           		

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
	CALL desenha_raquete_j1
	MOV byte [cor], azul
	CALL desenha_raquete_j2
	
	; Verifica se há uma tecla pressionada
	MOV     AX, [p_i]
    CMP     AX, [p_t]
	JNE    eh_tecla_pressionada ; Se há tecla pressionada, verifica qual foi
    JMP      continuar_animacao ; Se não há tecla pressionada, continua a animação

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

p:	
	; verifica se a tecla pressionada foi 'p'
	CMP  byte [tecla_ascii] , 19h
	JNE y
    JMP   sair ; TODO: Implementar a pausa
y:
	; Verifica se a tecla pressionada foi 'y'
	CMP    byte [tecla_ascii], 15h ; Código Make da tecla 'y'
	JNE n
	JMP     sair ; TODO: Implementar a confirmacao de saida
n:
	; Verifica se a tecla pressionada foi 'n'
	CMP    byte [tecla_ascii], 31h ; Código Make da tecla 'n'
	JNE q
	JMP     sair ; TODO: Implementar a negacao de saida
q: 
	; Verifica se a tecla pressionada foi 'q'
	CMP    byte [tecla_ascii], 10h ; Código Make da tecla 'q'
	JNE w
	JMP sair
w:
	; Verifica se a tecla pressionada foi 'w'
	CMP    byte [tecla_ascii], 11h ; Código Make da tecla 'w'
	JNE s
	CMP byte [jogando], 1 ; Se está jogando (1), move a raquete, senão, ignora
	JE w_jogando
	JMP continuar_animacao
w_jogando:
	MOV byte [cor], preto
	CALL move_raquete_j1_cima
	JMP continuar_animacao
s:
	; Verifica se a tecla pressionada foi 's'
	CMP    byte [tecla_ascii], 1Fh ; Código Make da tecla 's'
	JNE seta_cima
	CMP byte [jogando], 1 ; Se está jogando (1), move a raquete, senão, ignorar
	JE s_jogando
	JMP continuar_animacao
s_jogando:
	MOV byte [cor], preto
	CALL move_raquete_j1_baixo
	JMP continuar_animacao

seta_cima:	
	; Verifica se a tecla pressionada foi a seta para cima (Make Code 48h)
	CMP    byte [tecla_ascii], 48h
	JNE seta_baixo
	CMP byte [jogando], 1 ; Se está jogando (1), move a raquete, senão, ignorar OU QUALQUER OUTRA INSTRUCAO A DEFINIR COMO PARA MEXER NO MENU DA TELA
	JE seta_cima_jogando
	JMP continuar_animacao
seta_cima_jogando:	
	MOV byte [cor], preto
	CALL move_raquete_j2_cima
	JMP continuar_animacao

seta_baixo:
	; Verifica se a tecla pressionada foi a seta para baixo (Make Code 50h)
	CMP    byte [tecla_ascii], 50h
	JNE continuar_animacao
	CMP byte [jogando], 1 ; Se está jogando (1), move a raquete, senão, ignorar
	JE seta_baixo_jogando
	JMP continuar_animacao
seta_baixo_jogando:
	MOV byte [cor], preto
	CALL move_raquete_j2_baixo
	JMP continuar_animacao

continuar_animacao:
	; Adiciona um pequeno atraso para a animação
	CALL delay
	JMP animacao_loop         			; Continua o loop
	
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

inverter_direcao_x:
	NEG word [direction_x]             ; Inverte a direção em X
	RET

inverter_direcao_y:
	NEG word [direction_y]             ; Inverte a direção em Y
	RET

verifica_colisao:
    ; Verifica colisão com a borda superior
    MOV AX, [ball_y]
    MOV BX, [ball_radius]
    SUB AX, BX                  		; Posição da bola - Raio
    CMP AX, 2
    JL inverter_direcao_y       		; Reflete na borda superior se for menor que 0

    ; Verifica colisão com a borda inferior
    MOV AX, [ball_y]
    ADD AX, [ball_radius]
    CMP AX, 477
	JNG verifica_colisao_esquerda ;
    JMP inverter_direcao_y       		; Reflete na borda inferior se for maior que 479

verifica_colisao_esquerda:
    ; Verifica colisão com a borda lateral esquerda
    MOV AX, [ball_x]
    MOV BX, [ball_radius]
    SUB AX, BX                  		; Posição da bola - Raio
    CMP AX, 0
	JNL verifica_colisao_direita 		; Se não colidiu com a lateral esquerda, verifica a direita
	JMP game_over						; Para o jogo em caso de colisão com a lateral
    
verifica_colisao_direita:
    ; Verifica colisão com a borda lateral direita
    MOV AX, [ball_x]
    ADD AX, [ball_radius]
    CMP AX, 639
	JNG verifica_colisao_raquete_j1 			; Se não colidiu com a lateral direita, verifica os blocos do Jogador 1
	JMP game_over						; Para o jogo em caso de colisão com a lateral

verifica_colisao_raquete_j1:
    ; Verifica colisão com a raquete do Jogador 1
	MOV AX, [ball_x]
	ADD AX, [ball_radius]
    MOV BX, [j1_raquete]             			; x1 do bloco
    CMP AX, BX
    JL verifica_colisao_blocos_j1       	; Se a bola está antes do bloco, pula

	MOV AX, [ball_x]
	SUB AX, [ball_radius]
    MOV BX, [j1_raquete+4]             			; x2 do bloco
    CMP AX, BX
    JG verifica_colisao_blocos_j1            	; Se a bola está depois do bloco, pula

    MOV AX, [ball_y]
	ADD AX, [ball_radius]
    MOV BX, [j1_raquete+2]             			; y1 do bloco
    CMP AX, BX
    JL verifica_colisao_blocos_j1            	; Se a bola está antes do bloco, pula
	JE colisao_raquete_y_j1

	MOV AX, [ball_y]
	SUB AX, [ball_radius]
    MOV BX, [j1_raquete+6]             			; y2 do bloco
    CMP AX, BX
    JG verifica_colisao_blocos_j1            	; Se a bola está depois do bloco, pula
	JE colisao_raquete_y_j1
	
	CALL inverter_direcao_x
	JMP fim_verifica_colisao_j1

colisao_raquete_y_j1:
	CALL inverter_direcao_y
    JMP fim_verifica_colisao_j1         ; Pula para o final da sub-rotina

verifica_colisao_blocos_j1:
    ; Verifica colisão com os blocos do Jogador 1
    MOV CX, 5                  ; Quantidade de blocos
    MOV SI, j1_blocos          ; Apontar para a tabela de blocos
    MOV DI, j1_status          ; Apontar para o estado dos blocos
verifica_colisao_j1_loop:
    CMP byte [DI], 0           ; Verifica se o bloco está destruído
    JE avanca_proximo_bloco_j1

    ; Verifica colisão com o bloco atual
    MOV AX, [ball_x]
	ADD AX, [ball_radius]
    MOV BX, [SI]               			; x1 do bloco
    CMP AX, BX
    JL avanca_proximo_bloco_j1       	; Se a bola está antes do bloco, pula

	MOV AX, [ball_x]
	SUB AX, [ball_radius]
    MOV BX, [SI+4]             			; x2 do bloco
    CMP AX, BX
    JG avanca_proximo_bloco_j1        	; Se a bola está depois do bloco, pula

    MOV AX, [ball_y]
	ADD AX, [ball_radius]
    MOV BX, [SI+2]             			; y1 do bloco
    CMP AX, BX
    JL avanca_proximo_bloco_j1        	; Se a bola está antes do bloco, pula
	JE colisao_bloco_y_j1

	MOV AX, [ball_y]
	SUB AX, [ball_radius]
    MOV BX, [SI+6]             			; y2 do bloco
    CMP AX, BX
    JG avanca_proximo_bloco_j1        	; Se a bola está depois do bloco, pula
	JE colisao_bloco_y_j1

    ; Colisão com bloco detectada
    MOV byte [DI], 0           ; Marca o bloco como destruído
    MOV byte [cor], preto
    PUSH word [SI]             ; x1
    PUSH word [SI+2]           ; y1
    PUSH word [SI+4]           ; x2
    PUSH word [SI+6]           ; y2
    CALL rectangle         ; Pinta o bloco de preto
    CALL inverter_direcao_x    ; Inverte a direção da bola em X
fim_verifica_colisao_j1:
    JMP verifica_colisao_raquete_j2

colisao_bloco_y_j1:
	MOV byte [DI], 0           ; Marca o bloco como destruído
    MOV byte [cor], preto
    PUSH word [SI]             ; x1
    PUSH word [SI+2]           ; y1
    PUSH word [SI+4]           ; x2
    PUSH word [SI+6]           ; y2
    CALL rectangle    
	CALL inverter_direcao_y
	JMP fim_verifica_colisao_j1         ; Pula para o final da sub-rotina

avanca_proximo_bloco_j1:
    ADD SI, 8                  ; Avança para o próximo conjunto de coordenadas
    INC DI                     ; Avança para o próximo estado
    LOOP verifica_colisao_j1_loop           ; Repetir para os blocos restantes

verifica_colisao_raquete_j2:
	; Verifica colisão com a raquete do Jogador 2
	MOV AX, [ball_x]
	ADD AX, [ball_radius]
	MOV BX, [j2_raquete]             			; x1 do bloco
	CMP AX, BX
	JL verifica_colisao_blocos_j2       	; Se a bola está antes do bloco, pula
	
	MOV AX, [ball_x]
	SUB AX, [ball_radius]
	MOV BX, [j2_raquete+4]             			; x2 do bloco
	CMP AX, BX
	JG verifica_colisao_blocos_j2            	; Se a bola está depois do bloco, pula

	MOV AX, [ball_y]
	ADD AX, [ball_radius]
	MOV BX, [j2_raquete+2]             			; y1 do bloco
	CMP AX, BX
	JL verifica_colisao_blocos_j2            	; Se a bola está antes do bloco, pula
	JE colisao_raquete_y_j2

	MOV AX, [ball_y]
	SUB AX, [ball_radius]
	MOV BX, [j2_raquete+6]             			; y2 do bloco
	CMP AX, BX
	JG verifica_colisao_blocos_j2            	; Se a bola está depois do bloco, pula
	JE colisao_raquete_y_j2

	CALL inverter_direcao_x
	JMP fim_verifica_colisao_j2

colisao_raquete_y_j2:
	CALL inverter_direcao_y
	JMP fim_verifica_colisao_j2         ; Pula para o final da sub-rotina

verifica_colisao_blocos_j2:
	; Verifica colisão com os blocos do Jogador 2
	MOV CX, 5                  ; Quantidade de blocos
	MOV SI, j2_blocos          ; Apontar para a tabela de blocos
	MOV DI, j2_status          ; Apontar para o estado dos blocos
verifica_colisao_j2_loop:

	CMP byte [DI], 0           ; Verifica se o bloco está destruído
	JE avanca_proximo_bloco_j2

	; Verifica colisão com o bloco atual
	MOV AX, [ball_x]
	ADD AX, [ball_radius]
	MOV BX, [SI]               			; x1 do bloco
	CMP AX, BX
	JL avanca_proximo_bloco_j2       	; Se a bola está antes do bloco, pula

	MOV AX, [ball_x]
	SUB AX, [ball_radius]
	MOV BX, [SI+4]             			; x2 do bloco
	CMP AX, BX
	JG avanca_proximo_bloco_j2        	; Se a bola está depois do bloco, pula

	MOV AX, [ball_y]
	ADD AX, [ball_radius]
	MOV BX, [SI+2]             			; y1 do bloco
	CMP AX, BX
	JL avanca_proximo_bloco_j2        	; Se a bola está antes do bloco, pula
	JE colisao_bloco_y_j2

	MOV AX, [ball_y]
	SUB AX, [ball_radius]
	MOV BX, [SI+6]             			; y2 do bloco
	CMP AX, BX
	JG avanca_proximo_bloco_j2        	; Se a bola está depois do bloco, pula
	JE colisao_bloco_y_j2

	; Colisão com bloco detectada
	MOV byte [DI], 0           ; Marca o bloco como destruído
	MOV byte [cor], preto
	PUSH word [SI]             ; x1
	PUSH word [SI+2]           ; y1
	PUSH word [SI+4]           ; x2
	PUSH word [SI+6]           ; y2
	CALL rectangle         ; Pinta o bloco de preto
	CALL inverter_direcao_x    ; Inverte a direção da bola em X

fim_verifica_colisao_j2:
	RET

colisao_bloco_y_j2:
	MOV byte [DI], 0           ; Marca o bloco como destruído
	MOV byte [cor], preto
	PUSH word [SI]             ; x1
	PUSH word [SI+2]           ; y1
	PUSH word [SI+4]           ; x2
	PUSH word [SI+6]           ; y2
	CALL rectangle    
	CALL inverter_direcao_y
	JMP fim_verifica_colisao_j2         ; Pula para o final da sub-rotina

avanca_proximo_bloco_j2:
    ADD SI, 8                  ; Avança para o próximo conjunto de coordenadas
    INC DI                     ; Avança para o próximo estado
    LOOP verifica_colisao_j2_loop           ; Repetir para os blocos restantes
	RET

game_over:
    ; Pausa a animação
    HLT                        ; Simplesmente para o programa
	CALL sair

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

keyINT:									; Este segmento de código só será executado se uma tecla for presionada, ou seja, se a INT 9h for acionada!
        PUSH    AX						; Salva contexto na pilha
        PUSH    BX
        PUSH    DS
 ;       MOV     AX,data					; Carrega em AX o endereço de "data" -> Região do código onde encontra-se o segemeto de dados "Segment data" 			
 ;       MOV     DS,AX					; Atualiza registrador de segmento de dados DS, isso pode ser feito no inicio do programa!
        IN      AL, kb_data				; Le a porta 60h, que é onde está o byte do Make/Break da tecla. Esse valor é fornecido pelo chip "8255 PPI"
        INC     word [p_i]				; Incrementa p_i para indicar no loop principal que uma tecla foi acionada!
        AND     word [p_i],7			
        MOV     BX,[p_i]				; Carrega p_i em BX
        MOV     [BX+tecla],al			; Transfere o valor Make/Break da tecla armacenado em AL "linha 84" para o segmento de dados com offset DX, na variável "tecla"
        IN      AL, kb_ctl				; Le porta 61h, pois o bit mais significativo "bit 7" 
        OR      AL, 80h					; Faz operação lógica OR com o bit mais significativo do registrador AL (1XXXXXXX) -> Valor lido da porta 61h 
        OUT     kb_ctl, AL				; Seta o bit mais significativo da porta 61h
        AND     AL, 7Fh					; Restablece o valor do bit mais significativo do registrador AL (0XXXXXXX), alterado na linha 90 	
        OUT     kb_ctl, AL				; Reinicia o registrador de dislocamento 74LS322 e Livera a interrupção "CLR do flip-flop 7474". O 8255 - Programmable Peripheral Interface (PPI) fica pronto para recever um outro código da tecla https://es.wikipedia.org/wiki/INTel_8255
        MOV     AL, eoi					; Carrega o AL com a byte de End of Interruption, -> 20h por default
        OUT     pictrl, AL				; Livera o PIC
        
		POP     DS						; Reestablece os registradores salvos na linha 79 
        POP     BX
        POP     AX
        IRET

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
vel    			dw 10                   ; Velocidade do movimento

modo_anterior	db		0
linha   		dw  	0
coluna  		dw  	0
deltax			dw		0
deltay			dw		0	
mens    		db  	'Funcao Grafica'

; Coordenadas dos blocos do Jogador 1
j1_blocos 	dw 0, 0, 20, 92       ; x1, y1, x2, y2 (Bloco 1)
           	dw 0, 97, 20, 189    ; Bloco 2
           	dw 0, 194, 20, 286   ; Bloco 3
           	dw 0, 291, 20, 383   ; Bloco 4
           	dw 0, 388, 20, 480   ; Bloco 5

; Coordenadas dos blocos do Jogador 2
j2_blocos 	dw 619, 0, 639, 92    ; x1, y1, x2, y2 (Bloco 1)
           	dw 619, 97, 639, 189 ; Bloco 2
           	dw 619, 194, 639, 286; Bloco 3
           	dw 619, 291, 639, 383; Bloco 4
           	dw 619, 388, 639, 480; Bloco 5

j1_raquete dw  22, 194, 42, 286
j2_raquete dw 597, 194, 617, 286

; Estado dos blocos (1 = ativo, 0 = destruído)
j1_status db 1, 1, 1, 1, 1      ; Estado dos blocos do Jogador 1
j2_status db 1, 1, 1, 1, 1      ; Estado dos blocos do Jogador 2

jogando db 1 ; Indica se o jogo está em andamento (1 = sim, 0 = não)

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