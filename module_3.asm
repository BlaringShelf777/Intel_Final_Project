
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
auxVal              dw  0
auxIndex            db  0
hex                 db  16
FileBuffer			db  10  dup (0)
fileHandle          dw  0
BufferWRWORD	    DB	10  dup (0)
string	            db	256 dup(0)  ; String da linha de comando
msgErrorOpenFile	db		"Erro na abertura do arquivo.",CR,LF,0
	.code
	.startup
	lea		dx, string              ; Peaga texto da linha de comando
	mov		cx, 256                 ;   ||
	call    ReadCommandLine         ;   ||
    ;--
    lea     dx, string              ; String da linha de comando
    inc     dx                      ;   ||
    ;--
    call    fopen                   ; Abre arquivo
    ;--
    mov     fileHandle, bx          ; Salva handle do arquivo
    jnc     notError                ;   ||
    ;--
    lea     bx, msgErrorOpenFile    ; Erro na criação do arquivo
    call    printf_s                ;   ||
    .exit   1                       ;   ||
notError:
    mov     cx, 0
readingLoop:
    mov     bx, fileHandle          ; Pega carcatere do arquivo
    call    getChar                 ;   ||
    ;--
    cmp     ax, 0                   ; Verifica fim do arquivo
    je      fim                     ;   ||
    ;--
    mov     dh, 0                   ; Imprime carcatere na tela em HEX
    mov     ax, dx                  ;   ||
	call	printf_w                ;   ||
    ;--
    jmp     readingLoop             ; Loop de leitura

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
;Fun��o: Escreve o valor de AX na tela em HEX
;
;--------------------------------------------------------------------
printf_w	proc	near
    mov     auxVal, ax
    dec     auxIndex
calcLoop:
    inc     auxIndex
    mov     al, auxIndex
    mul     hex
    cmp     ax, auxVal
    jle     calcLoop
    ;--
    dec     auxIndex
    ;--
    mov     dl, auxIndex
    add     dl, '0'
    call    putChar
    inc     cx
    ;--
    mov     al, auxIndex
    mul     hex
    ;--
    sub     auxVal, ax
    mov     dl, byte ptr auxVal
    ;--
    cmp     auxVal, 10
    jl      jmp1
    add     dl, 'A'
    sub     dl, 10
    jmp     jmp2
jmp1:
    add     dl, '0'
jmp2:
    call    putChar
    inc     cx
    cmp     cx, 32
    jne     jmp3
    mov     dl, LF
    call    putChar
    mov     cx, 0
jmp3:
    ret
printf_w	endp

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
	end
;--------------------------------------------------------------------
