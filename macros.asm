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
    mov AX, gotten ; Le cargamos a AX el valor del numero que queremos convertir

    extract:
        xor DX, DX ; Limpio a DX
        div BX ; Obtengo el residuo de la division 
        add DX, 30h ; Le sumo a DX el valor de 30 hexa para que el residuo se mueva hacia la posicion del no. ASCII
        push DX ; Meto ese valor de DX en el top de la pila
        inc CX ; Incremento a CX en 1 para asi poder ejecutar el loop
        cmp ax, 0 ; Si ax no es 0, entonces sigo ejecutando el bloque de codigo
        jne extract
    
    mov SI, 0 ;Inicializo a SI en 0

    store:
        pop DX ; Despues tengo que hacer la misma cantidad de pops que de push, e ir sacando los valores de DX 
        mov recoveredStr[SI], DL ; El resultado de las operaciones se almacenan en la parte baja de DX por lo que 
                                 ; usamos D low (DL) 
        inc SI                   ; Incrementamos en 1 la dirección de memoria para acceder al byte que le corresponde int SI += 1
        loop store               ; Se ejecuta el loop hasta que CX llegue a 0
    
    ; Regresamos sus registros al estado en el que estaban
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
    push AX
    push BX
    push CX
    push DI
    mPrintMsg colName

    mov DI, offset mainTable
    xor AX, AX
    xor BX, BX ;; Mostramos en 0 el registro AX
    mov BX, 18h ;; Le cargamos a BX el numero de filas
    mov CX, 0Bh ;; Le cargamos a CX el valor del numero de las columnas

    printRows:
        cmp AX, CX ;; Comparamos si el valor de AX es igual al de CX if(ax == cx)
        je endPrint ;; Si es menor o igual
        mov gotten, AX ;; Le cargamos a gotten el valor del numbero AX, para que pueda ser representado por el macro
        mNumToString;; De lo contrario, entonces convertimos el contador en Str y lo mostramos
        mPrintMsg recoveredStr


        printCols:
            mov DX, [DI]
            loop printCols

        inc BX ;; Incrementamos en 1 la variable de AX int AX += 1
        jmp printRows ;; Y repetimos lo de imprimir las filas
endPrint:
    pop DI
    pop CX
    pop BX
    pop AX
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