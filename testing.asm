
;
;====================================================================
;	- Fonte base para a escrita de programa para o 8086
;====================================================================
;

	; Declara��o do modelo de segmentos
	.model		small
	
	; Declara��o do segmento de pilha
	.stack
CR		equ		10
LF		equ		13
MAXSTRING	equ		200
	; Declara��o do segmento de dados
	.data
msgCrLf				db		CR, LF, 0
FileBuffer			db		10 dup (?)
BufferWRWORD		db		10 dup (?)
String				db		MAXSTRING dup (?)
FileNameBuffer		db		MAXSTRING dup (?)
msgSrcFile			db		"Insira o nome do arquivo: ",0
msgErrorOpenFile	db		"Erro na abertura do arquivo.",CR,LF,0
msgErrorReadFile	db		"Erro na leitura do arquivo.",CR,LF,0
fileHandle			dw		0
NumbersArray        db      "ZERO",0, "UM",0, "DOIS",0, "TRES",0, "QUATRO",0, "CINCO",0, "SEIS",0, "SETE",0, "OITO",0, "NOVE",0 
; Variaveis para uso interno na função sprintf_w
sw_n	dw	0
sw_f	db	0
sw_m	dw	0
	; Declaração do segmento de código
	.code
	.startup
	
	; Coloque o seu programa principal aqui!
    lea         bx, msgSrcFile                  ; Imprime mensagem - Nome do arquivo
    call        printf_s                        ;   ||
    ;--
    lea         bx, FileNameBuffer              ; Pega o nome do arquivo
    call        gets                            ;   ||
    ;--
    lea         dx, FileNameBuffer              ; Abre arquivo
    call        fopen                           ;   ||
    ;--
    jnc         continua1                       ; Testa erro de abertura
    ;--
    lea         bx, msgErrorOpenFile            ; Imprime mensagem de erro
    call        printf_s                        ;   ||
    ;--
    .exit       1                               ; Código de erro (error 1)
continua1:
    mov         bx, fileHandle                  ; Lê carcater do arquivo
    call        getChar                         ;   ||
    ;--
    jnc         continua2                       ; Testa error de leitura
    ;--
    lea         bx, msgErrorReadFile            ; Imprime mensagem de erro
    call        printf_s                        ;   ||
    ;--
    .exit       2                               ; Código de erro (error 2)
continua2:
    cmp         dl, '1'
    jne         continua3 

    
	.exit       0
	
	; Coloque suas subrotinas a partir daqui!

putchar	proc	near 
	mov		ah,2
	int		21H
	ret
putchar endp
;--------------------------------------------------------------------
format	proc	near
	lea		bx, msgCrLf
	call 	printf_s
	lea		bx, msgCrLf
	call 	printf_s
	ret
format endp
;--------------------------------------------------------------------
;Fun��o	Abre o arquivo cujo nome est� no string apontado por DX
;		boolean fopen(char *FileName -> DX)
;Entra: DX -> ponteiro para o string com o nome do arquivo
;Sai:   BX -> handle do arquivo
;       CF -> 0, se OK
;--------------------------------------------------------------------
fopen	proc	near
	mov		al,0
	mov		ah,3dh
	int		21h
	mov		bx,ax
	ret
fopen	endp

;--------------------------------------------------------------------
;Fun��o Cria o arquivo cujo nome est� no string apontado por DX
;		boolean fcreate(char *FileName -> DX)
;Sai:   BX -> handle do arquivo
;       CF -> 0, se OK
;--------------------------------------------------------------------
fcreate	proc	near
	mov		cx,0
	mov		ah,3ch
	int		21h
	mov		bx,ax
	ret
fcreate	endp

;--------------------------------------------------------------------
;Entra:	BX -> file handle
;Sai:	CF -> "0" se OK
;--------------------------------------------------------------------
fclose	proc	near
	mov		ah,3eh
	int		21h
	ret
fclose	endp

;--------------------------------------------------------------------
;Fun��o	Le um caractere do arquivo identificado pelo HANLDE BX
;		getChar(handle->BX)
;Entra: BX -> file handle
;Sai:   dl -> caractere
;		AX -> numero de caracteres lidos
;		CF -> "0" se leitura ok
;--------------------------------------------------------------------
getChar	proc	near
	mov		ah,3fh
	mov		cx,1
	lea		dx,FileBuffer
	int		21h
	mov		dl,FileBuffer
	ret
getChar	endp
	
;--------------------------------------------------------------------
;Entra: BX -> file handle
;       dl -> caractere
;Sai:   AX -> numero de caracteres escritos
;		CF -> "0" se escrita ok
;--------------------------------------------------------------------
setChar	proc	near
	mov		ah,40h
	mov		cx,1
	mov		FileBuffer,dl
	lea		dx,FileBuffer
	int		21h
	ret
setChar	endp	

;
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

;--------------------------------------------------------------------
	end
;--------------------------------------------------------------------
