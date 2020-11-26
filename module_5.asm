
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
inFileHandle        dw  0
outFileHandle       dw  0
format              db  LF, LF, 0
outFileName  		db	250 dup (0)
inFileName          db  250 dup (0)
string	            db	256 dup(0)  ; String da linha de comando
msgErrorOpenFile	db  "Erro na abertura do arquivo.",CR,LF,0
msgErrorCreateFile	db  "Erro na criação do arquivo.",CR,LF,0
NumbersArray        db  "ZERO", 0, 0, 0, "UM", 0, 0, 0, 0, 0, "DOIS", 0, 0, 0, "TRES", 0, 0, 0, "QUATRO", 0, "CINCO", 0, 0, "SEIS", 0, 0, 0, "SETE", 0, 0, 0, "OITO", 0, 0, 0, "NOVE", 0, 0, 0 
count               db  0
	.code
	.startup
	lea		dx, string              ; Peaga texto da linha de comando
	mov		cx, 256                 ;   ||
	call    ReadCommandLine         ;   ||
    ;--
    call    getFIleName             ; Pega o nome dos arquivos de entrada e saida
    ;--
    lea     dx, inFileName          ; Abre arquivo
    call    fopen                   ;   ||
    ;--
    mov     inFileHandle, bx        ; Salva handle do arquivo
    jnc     notError1               ;   ||
    ;--
    lea     bx, msgErrorOpenFile    ; Erro na abertura do arquivo
    call    printf_s                ;   ||
    ;--
    .exit   1                       ; Termina programa ERROR 1
notError1:
    lea     dx, outFileName         ; Cria arquivo 
    call    fcreate                 ;   ||
    ;--
    mov     outFileHandle, bx       ; Salva handle do arquivo
    jnc     notError2               ;   ||
    ;--
    mov     bx, inFileHandle        ; Fecha arquivo de entrada
    call    fclose                  ;   ||
    ;--
    lea     bx, msgErrorCreateFile  ; Erro na criação do arquivo
    call    printf_s                ;   ||
    ;--
    .exit   2                       ; Termina programa ERROR 2
notError2:
    mov     bx, inFileHandle        ; Lê carcatere di arquivo de entrada
    call    getChar                 ;   ||
    ;--
    cmp     ax, 0                   ; Testa fim do arquivo
    je      fim                     ;   ||
    ;--
    cmp     dl, 'A'                 ; Testa se em [A, Z]
    jl      notAlpha                ;   ||
    cmp     dl, 'Z'                 ;   ||
    jle     isAlpha                 ;   ||
    ;--
    cmp     dl, 'a'                 ; Testa se em [a, z]
    jl      notAlpha                ;   ||
    cmp     dl, 'z'                 ;   ||
    jle     isAlpha                     ;   ||
    jmp     notAlpha
isAlpha:     
    inc     count                   ; Incrementa caracteres lidos
    ;--
    cmp     count, 1                ; Testa se é uma nova leitura
    jne     alphaJmp                ;   ||
    ;--
    lea     bp, string              ; Nova leitura
alphaJmp:
    mov     [bp], dl                ; Salva valor no vetor auxiliar
    inc     bp                      ;   ||
    ;--
    jmp     notError2               ; Loop de leitura
notAlpha:
    cmp     count, 0                ; Testa se há string auxiliar
    je      notAlphaJmp             ;   ||
    ;--
    mov     cx, 0    
    mov     [bp], 0           
    call    strcmp                  ;**************************
notAlphaJmp:
    mov     bx, outFileHandle       ; Coloca caracter não alfabetico no arquivo
    call    setChar                 ;   ||
    ;--
    mov     count, 0                ; Zera contagem de carcateres da sub-string
    ;--
    jmp     notError2               ; Loop de leitura do arquivo de entrada
fim:
    cmp     count, 0
    je      fimNext
    mov     [bp], 0
    call    strcmp
fimNext:
    mov     bx, inFileHandle        ; Fecha arquivo de entrada
    call    fclose                  ;   ||
    ;--
    mov     bx, outFileHandle       ; Fecha arquivo de saida
    call    fclose                  ;   ||
    ;--
	.exit       0                   ; Termina  
;--------------------------------------------------------------------
strcmp      proc    near 
    push    bx                      ; Salva valores
    push    bp                      ;   ||
    push    dx                      ;   ||
    ;--
notEqualJmp:
    lea     bx, string              ; Pega endereço das strings a serem comparadas
    lea     bp, NumbersArray        ;   ||
    ;--
    mov     al, 7                   ; Calcula posição no vetor
    mul     cl                      ;   ||
    add     bp, ax                  ;   ||
cmpAgain:
    mov     dl, [bx]                ; Ajusta valor
    cmp     dl, 'Z'                 ;   ||
    jle     cmpAgainJmp             ;   ||
    sub     dl, 32                  ;   ||
cmpAgainJmp:              
    ;--
    cmp     [bp], dl                ; Ve se iguais
    jne     notEqual                ;   ||
    ;--
    cmp     [bp], 0                 ; Testa fim da string
    je      strcmpEnd               ;   ||
    ;--
    inc     bx                      ; Incrementa posição
    inc     bp                      ;   ||
    ;--
    jmp     cmpAgain
notEqual:
    inc     cx                      ; Incrementa posição no vetor
    cmp     cx, 9                   ;   ||
    jle     notEqualJmp             ;   ||
    ;--
    lea     bp, string              ;
    dec     bp
notEqualLoop:
    inc     bp
    mov     bx, outFileHandle
    cmp     [bp], 0
    je      notEqualJmpEnd
    mov     dl, [bp]
    call    setChar
    jmp     notEqualLoop
notEqualJmpEnd:
    pop     dx
    pop     bp
    pop     bx
    ;--
    ret
strcmpEnd:
    mov     dl, cl
    add     dl, '0'
    mov     bx, outFileHandle
    call    setChar
    pop     dx
    pop     bp
    pop     bx
    ret
strcmp      endp
;--------------------------------------------------------------------
getFIleName proc    near
    lea     bx, inFileName
    lea     bp, string
getFileNameLoop:
    inc     bp
    mov     dl, [bp]
    ;--
    cmp     dl, 20H
    jne     getFileNameJmp
    ;--
    lea     bx, outFileName
    ;--
    jmp     getFileNameLoop
getFileNameJmp:
    cmp     dl, 0
    je      getFileNameEnd
    ;--
    mov     [bx], dl
    inc     bx
    ;--
    jmp     getFileNameLoop
getFileNameEnd:
    ret
getFIleName endp
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
	end
;--------------------------------------------------------------------
