
;
;====================================================================
;	Uso de ReadCommandLine e apresenta��o do string na tela
;	A linha de comando � apresentada entre colchetes
;====================================================================
;

	.model		small
	.stack

	.data
LF          equ 10                  ; Quebra de linha
CR		    equ	10
FileBuffer			db  10  dup (0)
BufferWRWORD	    DB	10  dup (0)
Serie		        dw  0,1,1
fileHandle			dw  0           ; Handle do arquivo
string	            db	256 dup(0)  ; String da linha de comando
msgErrorCreateFile	db		"Erro na criação do arquivo.",CR,LF,0
; Variaveis para uso interno na fun��o sprintf_w
sw_n	dw	0
sw_f	db	0
sw_m	dw	0
	.code
	.startup
	lea		dx, string              ; Peaga texto da linha de comando
	mov		cx, 256                 ;   ||
	call    ReadCommandLine         ;   ||
    ;--
    lea     dx, string              ; String da linha de comando
    inc     dx                      ;   ||
    ;--
    call    fcreate                 ; Cria arquivo
    ;--
    mov     fileHandle, bx          ; Salva handle do arquivo
    jnc     notError                ;   ||
    ;--
    lea     bx, msgErrorCreateFile  ; Erro na criação do arquivo
    call    printf_s                ;   ||
    .exit   1                       ;   ||
notError:
    mov     bx, fileHandle          ; Handle do arquivo
    ;--
    mov		ax,Serie                ; Coloca fib de 0 no arquivo
	call	printf_w                ;   ||
    ;--
	mov		ax,Serie+2              ; Coloca fib de 1 no arquivo
	call	printf_w                ;   ||
NextValue:
	mov		ax,Serie+2              ; Calcula fib
	add		ax,Serie+0              ;   ||
	mov		Serie+4,ax              ;   ||
    ;--
	jc		fim                     ; Testa carry
    ;--
	mov		ax,Serie+4              ; Coloca no arquivo
	call	printf_w                ;   ||
    ;--
	mov		ax,Serie+2              ; Atualiza valores para proxima iteração
	mov		Serie+0,ax              ;   ||
	mov		ax,Serie+4              ;   ||
	mov		Serie+2,ax              ;   ||
	=--
	jmp		NextValue               ; Loop de calculo
fim:
    mov     bx, fileHandle          ; Fecha arquivo
    call    fclose                  ;   ||
    ;--
	.exit       0                   ; Termina  
;--------------------------------------------------------------------
;--------------------------------------------------------------------
; Coloca um caractere na tela

; void putChar(char c -> dl)
;--------------------------------------------------------------------
putChar     proc    near
    mov     ah, 2
	int		21H
    ret
putChar     endp
;--------------------------------------------------------------------
;Fun��o: Escrever um string na tela
;
;void printf_s(char *s -> DS:BX) {
;	While (*s!='\0') {
;		putchar(*s)
; 		++s;
;	}
;}
;--------------------------------------------------------------------
printf_s	proc	near

;	While (*s!='\0') {
	mov		dl,[bx]
	cmp		dl,0
	je		ps_1

;		putchar(*s)
	push	bx
	mov		ah,2
	int		21H
	pop		bx

;		++s;
	inc		bx
		
;	}
	jmp		printf_s
		
ps_1:
	ret
	
printf_s	endp

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
;--------------------------------------------------------------------
;Fun��o: Escreve o valor de AX na tela
;		printf("%
;--------------------------------------------------------------------
printf_w	proc	near
	; sprintf_w(AX, BufferWRWORD)
	lea		bx,BufferWRWORD
	call	sprintf_w
	
	lea		bp,BufferWRWORD
	dec     bp
    mov     bx, fileHandle
printToFIleLoop:
    inc     bp
    mov     dl, [bp]
    cmp     dl, 0
    je      printToFIleEnd
    call    setChar
    jmp     printToFIleLoop
	
printToFIleEnd:
    mov     dl, LF
    call    setChar
    mov     dl, LF
    call    setChar
	ret
printf_w	endp

;--------------------------------------------------------------------
;Fun��o: Converte um inteiro (n) para (string)
;		 sprintf(string->BX, "%d", n->AX)
;--------------------------------------------------------------------
sprintf_w	proc	near
	mov		sw_n,ax
	mov		cx,5
	mov		sw_m,10000
	mov		sw_f,0
	
sw_do:
	mov		dx,0
	mov		ax,sw_n
	div		sw_m
	
	cmp		al,0
	jne		sw_store
	cmp		sw_f,0
	je		sw_continue
sw_store:
	add		al,'0'
	mov		[bx],al
	inc		bx
	
	mov		sw_f,1
sw_continue:
	
	mov		sw_n,dx
	
	mov		dx,0
	mov		ax,sw_m
	mov		bp,10
	div		bp
	mov		sw_m,ax
	
	dec		cx
	cmp		cx,0
	jnz		sw_do

	cmp		sw_f,0
	jnz		sw_continua2
	mov		[bx],'0'
	inc		bx
sw_continua2:

	mov		byte ptr[bx],0
	ret		
sprintf_w	endp
	
;
;--------------------------------------------------------------------
; ES:xx -> segmento onde est� o PSP
; DS:DX -> endere�o do string de destino da linha de comando
; CX -> n�mero m�ximo de caracteres do string de destino
;
; AX <- n�mero de caracteres copiados para o string
;
; AX=0
; di=DX
; if(CX>1) {
;	si=80H
;	CX = MIN(CX,[ES:si])
;	si++
;	do {
;		[DS:di]=[ES:si]
;		di++
;		si++
;	}while(--cx != 0)
; }
; [di]=0
;--------------------------------------------------------------------
ReadCommandLine	proc	near

	mov		ax,0
	mov		di,dx
	cmp		cx,1
	jle		rdcl1

	mov		si,80h
	
	mov		bh,0
	mov		bl,es:[si]
	cmp		cx,bx
	jle		rdcl3
	mov		cx,bx
rdcl3:
	inc		si
	
rdcl2:
	mov		al,es:[si]
	mov		[di],al
	inc		di
	inc		si
	loop	rdcl2
	
rdcl1:
	mov		byte ptr [di],0
	ret

ReadCommandLine	endp	


;--------------------------------------------------------------------
	end
;--------------------------------------------------------------------
