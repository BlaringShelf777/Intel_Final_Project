	.model		small
	.stack

	.data
LF          equ 10                  ; Quebra de linha
virgula     db  0                   ; Flag virgula
count       db  0                   ; Contagem dos carcateres
string	    db	256 dup(0)          ; String da linha de comando
stringAux	db	256 dup(0)          ; Sub-string

	.code
	.startup
	lea		dx, string              ; Peaga texto da linha de comando
	mov		cx, 256                 ;   ||
	call    ReadCommandLine         ;   ||
    ;--
    lea     bx, string              ; String da linha de comando
    dec     bx                      ; Ajuste
    ;--
    lea     bp, stringAux           ; String auxiliar
    ;--
readingLoop:
    inc     bx                      ; Incrementa o vetor
    mov     dl, [bx]                ;   ||
    ;--
    cmp     dl, 0                   ; Testa '\0'  
    je      fim                     ;   ||
    ;--
    cmp     dl, ','                 ; Testa virgula
    je      tokenC1               ;   ||
    ;--
    cmp     dl, 20H                 ; Testa espaço
    je      tokenC2                   ;   ||
    ;--
    cmp     dl, 09H                 ; Testa TAB
    je      tokenC2                   ;   ||
    ;--
    jmp     notToken                ; Não é um token
tokenC1:
    cmp     virgula, 0              ; Testa flag de virgula
    jne     comma                   ;   ||
    ;--
    mov     virgula, 1              ; Atualiza flag de virgula
    jmp     readingLoop             ;   ||
comma:
    mov     virgula, 0              ; Atualiza flag de virgula
    jmp     token_continue
tokenC2:
    ;--
    cmp     count, 0                ; Testa numero de caracteres
    je      readingLoop             ;   ||
    ;--
token_continue:
    ;--
    mov     [bp], 0                 ; Fim de string auxiliar
    mov     count, 0                ;   ||
    ;--
    call    printStringAux          ; Imprime string auxiliar
    ;--
    lea     bp, stringAux           ; String auxiliar vazia
    mov     [bp], 0                 ;   ||
    ;--
    jmp     readingLoop

notToken:
    inc     count                   ; Incremeta caracteres lidos
    ;--
    mov     virgula, 0              ; Zera virgula
    ;--
    mov     [bp], dl                ; Coloca caractere na string
    inc     bp                      ;   ||
    ;--
    cmp     [bx+1], 0               ; Confere se é o fim da string principal
    jne     readingLoop             ;   ||
    ;--
    mov     [bp], 0                 ; Fim de string auxiliar
    mov     count, 0                ;   ||
    ;--
    call    printStringAux          ; Imprime string auxiliar
    ;--
    jmp     readingLoop             ; loop
fim:
	.exit       0                   ; Termina  
;--------------------------------------------------------------------
;   Imprime string Auxiliar em stringAux com formatação
;       printStringAux(void)
;--------------------------------------------------------------------
printStringAux proc    near
    call    format                  ; Imprime string
    push    bx                      ;   ||
    lea     bx, stringAux           ;   ||
    call    printf_s                ;   ||
    pop     bx                      ;   ||
    call    format                  ;   ||
    push    dx                      ;   ||
    mov     dl, LF                  ;   ||
    call    putChar                 ;   ||
    pop     dx                      ;   ||
    ;--
    ret
printStringAux endp
;--------------------------------------------------------------------
; Formata

; void format(void)
;--------------------------------------------------------------------
format      proc    near
    mov     dl, '"'
    call    putChar
    ret
format      endp
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

