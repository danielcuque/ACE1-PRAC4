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

mPrintTable macro
    mPrintMsg colName ;; Imprimimos el nombre de la columna
    mov DI, offset mainTable

    mov CX, 17h ; 23 en decimal
    
    row_loop:
        mov AX, 18h ; Lo marcamos para que en la primera iteracion, el valor de CX es de 23
                    ; Entonces así 24 - 23 = 1 (fila 1)
                    ; Decrementamos en 1 el CX
                    ; La siguiente iteración será 24 - 22 = 2 (fila 1), y así sucesivamente
                    ; Cuando la operación sea 24 - 0 = 24, significa que terminaron las filas
        sub AX, CX
        cmp AX, 18h
        je end_row_loop ; Si no es igual, entonces imprimimos el numero de fila
        mov DX, AX
        mov AH, 09h
        int 21
        dec CX
        jmp row_loop
    end_row_loop:
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