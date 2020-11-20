
;
;====================================================================
;	- Fonte base para a escrita de programa para o 8086
;====================================================================
;

	; Declara��o do modelo de segmentos
	.model		small
	
	; Declara��o do segmento de pilha
	.stack
CR              equ 10
LF              equ 13
MAXSTRING       equ 200
ARRAYMAX        equ 7
	; Declara��o do segmento de dados
	.data
msgCrLf				db	CR, LF, 0
String				db	MAXSTRING dup (?)
userString		    db	MAXSTRING dup (?)
srcTxtMsg			db	"Insira o texto: ",0
NumbersArray        db  "ZERO", 0, 0, 0, "UM", 0, 0, 0, 0, 0, "DOIS", 0, 0, 0, "TRES", 0, 0, 0, "QUATRO", 0, "CINCO", 0, 0, "SEIS", 0, 0, 0, "SETE", 0, 0, 0, "OITO", 0, 0, 0, "NOVE", 0, 0, 0 
counter             db  0
; Variaveis para uso interno na função sprintf_w
sw_n	        dw  0
sw_f	        db	0
sw_m	        dw	0
	.code
	.startup
main:
    lea         bx, userString                  ; Reseta flags
    mov         [bx+1], 0                       ;   ||
    mov         counter, 0                      ;   ||
    ;--
    lea         bx, msgCrLf                     ; Formatação
    call        printf_s                        ;   ||
    ;--
    lea         bx, srcTxtMsg                   ; Imprime mensagem - Texto do Usuario
    call        printf_s                        ;   ||
    ;--
    lea         bx, userString                  ; Pega a string do usuario
    call        gets                            ;   ||
    ;--
    lea         bx, msgCrLf                     ; Formatação
    call        printf_s                        ;   ||
    ;--
    lea         bx, userString                  ; String do usuario
    dec         bx                              ; Ajuste
continua1:
    inc         bx                              ; Incrementa posição
    mov         dl, [bx]                        ; Pega caractere da string
    inc         counter                         ; Incrementa contador
continua2:
    cmp         dl, 0                           ; Testa se '\0'
    je          main                            ;   ||
    cmp         dl, 'f'
    jne         continua2_5
    cmp         [bx+1], 0                       ; Testa se "f\0"
    jne         continua2_5                     ;   ||
    cmp         counter, 1                      ; Testa fim do programa
    je          fimMain                         ;   ||
continua2_5:
    ;--
    cmp         dl, '0'                         ; Compara com '0'
    jb          continua3                       ;   ||
    ;--
    cmp         dl, '9'                         ; Compara com '9'
    ja          continua3                       ;   ||
    ;--                                         ; Está no intervalo ['0', '9']
    sub         dl, '0'                         ; Calcula posição no vetor: index
    ;--
    push        bx
    lea         bx, NumbersArray                ; Calcula endereço da string
    push        ax                              ;   ||
    mov         al, ARRAYMAX                    ;   ||
    mul         dl                              ;   ||
    add         bx, ax                          ;   ||
    pop         ax                              ;   ||
    ;--
    call        printf_s                        ; Imprime string
    ;--
    pop         bx
    jmp         continua1                       ; Loop de leitura
continua3:
    call        putchar                         ; Coloca caractere na tela
    ;--
    jmp         continua1                       ; Loop de leitura
fimMain:
    ;--
	.exit       0                               ; Ecerra o programa sem erros
	
	; Coloque suas subrotinas a partir daqui!

;--------------------------------------------------------------------
; Função coloca um caractere no visor
;       putchar (char c -> dl)
;--------------------------------------------------------------------
putchar	proc	near 
	mov		ah,2
	int		21H
	ret
putchar endp

;--------------------------------------------------------------------
;Funcao Le um string do teclado e coloca no buffer apontado por BX
;		gets(char *s -> bx)
;--------------------------------------------------------------------
gets	proc	near
	push	bx

	mov		ah,0ah						; L� uma linha do teclado
	lea		dx,String
	mov		byte ptr String, MAXSTRING-4	; 2 caracteres no inicio e um eventual CR LF no final
	int		21h

	lea		si,String+2					; Copia do buffer de teclado para o FileName
	pop		di
	mov		cl,String+1
	mov		ch,0
	mov		ax,ds						; Ajusta ES=DS para poder usar o MOVSB
	mov		es,ax
	rep 	movsb

	mov		byte ptr es:[di],0			; Coloca marca de fim de string
	ret
gets	endp

;--------------------------------------------------------------------
;Fun��o Escrever um string na tela
;		printf_s(char *s -> BX)
;--------------------------------------------------------------------
printf_s	proc	near
	mov		dl,[bx]
	cmp		dl,0
	je		ps_1

	push	bx
	mov		ah,2
	int		21H
	pop		bx

	inc		bx		
	jmp		printf_s
		
ps_1:
	ret
printf_s	endp

end