;; MACROS

; ------------------------------------
; Servirá para mostrar un mensaje en pantalla
mPrintMsg macro str
    mov DX, offset str
    mov AH, 09h
    int 21h
endm
; ------------------------------------

; ------------------------------------
mConfigData macro
    mov ax, @data
    mov ds, ax
endm
; ------------------------------------

; ------------------------------------
mWaitEnter macro
    inicio:
        mPrintMsg pressEnterMsg
        mov AH, 08h
        int 21
        cmp AL, 0Dh
        jne inicio
endm
; ------------------------------------

; ------------------------------------
mExit macro
mov AH, 4Ch
int 21h
endm
; ------------------------------------
; ------------------------------------

mConvertToStr macro
       mov CX, 06h
                mov BX, offset emptyCell
                mov DX, 30h

limpiar:        mov [BX], DL
                inc BX
                loop limpiar
                dec BX                   ;;; Posicionarse en el caracter de las unidades
                cmp AX, 0000h            ;;; Si el número es 0 no hacer nada
                je retorno
		jg unidad
		not AX
		mov DL, 2d
		mov [emptyCell], DL
unidad:         mov DL,[BX]              ;;; Incrementar las unidades
                inc DL
                mov [BX],DL
                dec AX                   ;;; Decrementar el número de entrada
                mov SI, BX               ;;; Guardar el dato de la posición de las unidades en otro registro
revisar_cifra:  mov DX, 3ah              ;;; Si en las unidades está el caracter 3Ah o :
                cmp [BX], DL
                je incrementa_ant        ;;; Saltar a la parte donde se incrementa la cifra anterior
                mov BX, SI               ;;; Restablecer la posición de las unidades en el registro original
                cmp AX, 0000h            ;;; Si el número de entrada no es 0
                jne unidad               ;;; Volver a incrementar unidades
                jmp retorno              ;;; Si no terminar rutina
incrementa_ant: mov DX, 30h              ;;; Se coloca el caracter '0' en la cifra actual
                mov [BX], DL
                dec BX                   ;;; Se mueve el índice a la cifra anterior
                mov DL, [BX]             ;;; Se incrementa la cifra indexada por BX
                inc DL
                mov [BX], DL
                cmp BX, offset emptyCell    ;;; Si el índice actual no es la direccion de la primera cifra
                jne revisar_cifra        ;;; revisar la cifra anterior para ver si nuevamente hay que incrementarla
                mov BX, SI               ;;; Reestablecer la posición de las unidades en el registro original
                cmp AX, 0000h            ;;; Si el número de entrada no es 0
                jne unidad               ;;; Volver a incrementar unidades
retorno:
endm
; ------------------------------------

mPrintTable macro
    mPrintMsg colName ;; Imprimimos el nombre de la columna

    mov DI, offset mainTable
		mov CX, 17        ;; 23 iteraciones, filas
impr_fila:	mov AX, 18
		sub AX, CX
		push CX
		mConvertToStr
		pop CX

		mov BX, offset emptyCell
		add BX, 04
		mov DX, BX        ;; se imprime el número de fila
		mov AH, 09
		int 21
		mov DL, 20        ;; dos espacios
		mov AH, 02
		int 21
		mov DL, 20
		mov AH, 02
		int 21
		push CX           ;; se guarda el contador del ciclo superior
		mov CX, 0b        ;; 11 iteraciones, columnas
impr_columna:	
		mov AX, [DI]
		push CX
		mConvertToStr
		pop CX
		mov DX, offset emptyCell        ;; se imprime el número leido de memoria
		mov AH, 09
		int 21
		
		add DI, 02
		cmp CX, 0001
		je ciclo_columna
		mov DL, 20
		mov AH, 02
		int 21
ciclo_columna:	loop impr_columna
		pop CX
		loop impr_fila
fin:
endm


; ------------------------------------
mEmptyBuffer macro buffer
    mov SI, offset buffer
    mov CL, [SI]
    mov CH, 00
    add SI, 02 ;; Nos vamos al tercer byte del buffer que es donde empieza la informacion del teclado
    mov AL, 00
endm

; ------------------------------------
; Macro para leer con el teclado y guardarlo en el buffer del teclado
mGetKey macro buffer
    mEmptyBuffer buffer
    mov AH, 01h
    int 16h
    mov [SI], AL
    inc SI
    inc CL
    mov [SI], CL
endm
; ------------------------------------