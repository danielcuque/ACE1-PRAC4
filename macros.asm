;; MACROS
; ------------------------------------
; Servirá para mostrar un mensaje en pantalla
mPrintMsg macro str
    mov DX, offset str
    mov AH, 09h
    int 21h
endm

mPrintMsgWithReg macro reg
    push AX

    mov AX, reg
    mov AH, 09
    int 21

    pop AX
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
mNumToString macro
    push AX
    push BX
    push CX
    push DX
    push SI

    mov BX, 0Ah ;; Cargamos a BX con 10
    xor CX, CX ;; Limpiamos a cx
    mov AX, gotten ;

    extract:
        xor DX, DX
        div BX
        add DX, 30h
        push DX
        inc CX
        cmp ax, 0
        jne extract
    
    mov SI, 0

    store:
        pop DX
        mov recoveredStr[SI], DL
        inc SI
        loop store
    
    pop SI
    pop DX
    pop CX
    pop BX
    pop AX
endm 
; ------------------------------------

; ------------------------------------
mStringToNum macro number
    ;; Protejo los registros que voy a usar en el macros
    push AX
    push BX
    push CX
    push DX
    push SI

    xor SI, SI ; Limpio SI
    xor AX, AX ; Limpio AX
    xor DX, DX ; Limpio DX
    mov BX, 0Ah ; Cargo a BX con 10 decimal
    mov CX, 5 ; Cargo a CX con 5 para que ese sea el numero de repeticiones que haga el loop

    nextNum:
        mul BX 
        mov DL, number[SI]
        sub DL, 30h
        add AX, DX
        inc SI
        loop nextNum
    mov gotten, AX

    pop SI
    pop DX
    pop CX
    pop BX
    pop AX
    ;; Protejo los registros que voy a usar en el macros
endm
; ------------------------------------
; ------------------------------------
mPrintTable macro
    mPrintMsg colName

    mov DI, offset mainTable
    mov CX, 17h ;; Le cargamos a CX el valor del numero de filas
    mov AX, 01h ;; Cargamos a AX como 0 para que vaya incrementando

    printRows:
        cmp AX, CX
        je endPrint
        mNumToString AX
        mPrintMsg recoveredStr
        inc AX
        jmp printRows
endPrint:
endm
; ------------------------------------

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
; ------------------------------------
; Macro para salir del programa
mExit macro
    mov AH, 4Ch ;4C en hexa servirá para cargar y generar la int del programa
    int 21h
endm
; ------------------------------------