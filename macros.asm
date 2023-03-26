;; MACROS
; ------------------------------------
; Servirá para mostrar un mensaje en pantalla
mPrintMsg macro str
    push AX
    push DX

    mov DX, offset str
    mov AH, 09h
    int 21h

    pop DX
    pop AX
endm

mPrintPartialDirection macro str
    push AX
    push DX

    mov DX, str
    mov AH, 09h
    int 21h

    pop AX
    pop DX
endm

; ------------------------------------
mWaitEnter macro
    LOCAL wait_enter
    wait_enter:
        mPrintMsg pressEnterMsg
        mov AH, 08h
        int 21
        cmp AL, 0Dh
        jne wait_enter
endm
; ------------------------------------

mStartProgram macro
    LOCAL startProgram, exitProgram
    startProgram:
        mPrintTable
        mGetInputKeyboard
        mEvaluatePrompt
        cmp isRunProgram, 00h
        je startProgram
    exitProgram:
        mPrintMsg colonChar
        mExit
endm

mEvaluatePrompt macro
    LOCAL startEvaluate, endEvaluate, commandNotFound
    push AX
    push DX
    push SI

    mov SI, offset keyBoardBuffer               ;; Cargamos a SI la dirección de memoria del buffer del teclado
    add SI, 02h

    mSkipWhiteSpace                             ;; Primero verificamos que el buffer no esté vacío
    cmp DL, 00h                                 ;; Como skipWhiteSpace carga a DL un 00h si está vacio, comparamos
    je commandNotFound

    mov DI, offset SALIRCommand
    mCompareStr
    cmp DL, 00
    jne exeSalir

    mov SI, offset keyBoardBuffer
    mov DI, offset GUARDARCommand
    mCompareStr
    cmp DL, 00
    jne exeGuardar


    jmp commandNotFound

    exeSalir:
        mExit
    exeGuardar:
        mPrintMsg testStr
        jmp endEvaluate

    
    commandNotFound:
        mPrintMsg errorCommand
        mPrintMsg newLine
        mWaitEnter
    
    endEvaluate:
        pop SI
        pop DX
        pop AX
endm


;; Este macro avanza el macro hasta encontrar una palabra
;; SI es la posicion del buffer
;; DL es 00 si se terminó el buffer
mSkipWhiteSpace macro
    LOCAL start, goWord, isWord, endBuffer
    mov DX, offset keyBoardBuffer
    add DX, 102h

    start:
        mov AL, [SI]

        cmp AL, 20h
        je goWord

        cmp AL, 0Dh
        je goWord

        cmp AL, 00h
        je endBuffer
        jmp isWord
        
    goWord:
        inc SI
        cmp SI, DX
        jae endBuffer
        jmp start
    endBuffer:
        mov DL, 00h
        jmp endSkip
    isWord:
        mov DL, 01h
    endSkip:
endm

;; Este macro necesita un valor en SI y DI
;; SI el offset de la cadena A, la cadena apunta al tamaño de la misma
;; DI al offset de la cadena B que se quiere comparar con A
;; CX guarda el tamaño de una de las cadenas
;; DL guarda si son iguales
;; DL == 0 si no son iguales
;; DL == 1 si sí son iguales
mCompareStr macro
    LOCAL compareLoop, equal, notEqual, endCompare
    push AX
    push BX

    mov DX, 00h       
    mov CL, [DI]
    inc DI
    compareLoop:
        mov AL, [DI]
        mov BL, [SI]
        cmp AL, BL
        jne endCompare
        inc DI
        inc SI
        loop compareLoop
    
    mov DL, 01

    endCompare:
    pop BX
    pop AX
endm


; ------------------------------------
mNumToString macro
    LOCAL extract, store, continueStore, addZeroToLeft, negative
    ;; Protegemos nuestros registros
    push AX
    push BX
    push CX
    push DX
    push SI
    push DI

    mov BX, 0Ah                             ;; Cargamos a BX con 10
    xor CX, CX                              ;; Limpiamos a cx
    mov AX, numberGotten                          ;; Le cargamos a AX el valor del numero que queremos convertir

    extract:
        xor DX, DX                          ;; Limpio a DX
        div BX                              ;; Obtengo el residuo de la division 
        add DX, 30h                         ;; Le sumo a DX el valor de 30 hexa para que el residuo se mueva hacia la posicion del no. ASCII
        push DX                             ;; Meto ese valor de DX en el top de la pila
        inc CX                              ;; Incremento a CX en 1 para asi poder ejecutar el loop
        cmp AX, 0                           ;; Si ax no es 0, entonces sigo ejecutando el bloque de codigo
        jne extract

    ;; En esta sección vamos a añadir los 0s que faltan al numero hacia la izquierda
    push DX                                 ;; Primero guardamos la informacion de DX para poder utilizarlo como registro de cuantos 0s faltan

    mov SI, 0                               ;; Colocamos a SI

    mov DX, 06h                             ;; Inicialmente serán 6, ya que si recibimos el valor de 1, entonces queremos que se muestre como 000001
    sub DX, CX                              ;; El valor de CX nos ayudará a saber el tamaño del numero, para el caso de 1, será 6 - 1 = 5
                                            ;; Por lo que agregaremos 5 0s
    mov [counterToGetIndexGotten], DX       ;; Muevo el valor en el que se quedó DX para poder correrme a esa posición de la cadena

    addZeroToLeft:
        cmp DX, 00h                         ;; Comparo si DX no es 0, si es cero, significa que el num es de 5 cifras
        je continueStore                    ;; Saltamos a otra etiqueta
        mov recoveredStr[SI], 30h           ;; Si no es asi, entonces modificamos la etiqueta recovered Str donde insertará los 0s que hagan falta
        dec DX                              ;; Decrementamos a DX para que poder acabar el ciclo
        inc SI                              ;; Incrementamos SI para avanzar en la cadena
        jmp addZeroToLeft                   ;; Creamos un pseudo loop para insertar los 0s

    continueStore:
        pop DX                              ;; Sacamos el valor de DX que estaba en el top para poder regresarlo a como estaba
        mov SI, 0                           ;; Inicializo a SI en 0
        add SI, [counterToGetIndexGotten]   ;; Nos movemos con SI, hacia el numero en memoria que le corresponde a la cadena

    ;; TODO: Convertir a negativo

    store:
        pop DX                              ;; Despues tengo que hacer la misma cantidad de pops que de push, e ir sacando los valores de DX 
        mov recoveredStr[SI], DL            ;; El resultado de las operaciones se almacenan en la parte baja de DX por lo que 
                                            ;; usamos D low (DL) 
        inc SI                              ;; Incrementamos en 1 la dirección de memoria para acceder al byte que le corresponde int SI += 1
        loop store                          ;; Se ejecuta el loop hasta que CX llegue a 0
    
    ; Regresamos sus registros al estado en el que estaban
    pop DI
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
    mov CX, 05h ; Cargo a CX con 5 para que ese sea el numero de repeticiones que haga el loop

    nextNum:
        mul BX 
        mov DL, number[SI]
        sub DL, 30h
        add AX, DX
        inc SI
        loop nextNum
    mov numberGotten, AX

    ;; Protejo los registros que voy a usar en el macros
    pop SI
    pop DX
    pop CX
    pop BX
    pop AX
endm
; ------------------------------------

; ------------------------------------
mPrintTable macro
    LOCAL printRows, printCols
    push BX
    push CX
    push DX
    push DI
    push SI

    mPrintMsg colName

    mov SI, offset mainTable                ;; Obtenemos la direccion de memoria del tablero
    mov BX, 01h                             ;; Colocamos en 0 a BX para llevar el registro del numero de filas

    mov CX, 17h                             ;; Colocamos en CX el numero de filas

    printRows:
        mov numberGotten, BX                ;; Cargamos a numberGotten con el registro contador, en este caso es BX
        mNumToString                        ;; Usamos el macro para convertir el número que se almacenó en numberGotten y covertilo a str
        
        push DX
        mov DX, offset recoveredStr
        add DX, 04h
        mPrintPartialDirection DX       ;; Le mandamos esa dirección de memoria a la macro
        mPrintMsg espacio               ;; Le damos un espacio para separarlo de la cuadricula
        pop DX

        push CX                         ;; Protegemos nuestro registro CX que guarda el contador para imprimir las filas
        mov CX, 0Bh                     ;; Lo inicializamos en B = 11 dec  para imprimir las columnas
        printCols:
            mov DI, offset numberGotten ;; Movemos la direccion de memoria del numero obtenido
            mov DX, [SI]                ;; Le cargamos a DX el valor de la posición del tablero
            mov [DI], DL                ;; Movemos el valor que se encuentra en la posición DI del arreglo 
            mPrintNumberConverted       ;; Imprimimos el valor de la celda
            add SI, 02h                 ;; Al ser una DW, es necesario avanzar 2 bytes
            loop printCols              ;; Ciclamos hasta que el contador llegue a 0 indicando que ya se imprimieron las columnas

            pop CX                      ;; Regresamos el valor del contador de las filas a su estado original
            inc BX                      ;; Incrementamos en 1 el contador que lleva el registro de las filas
            dec CX                      ;; Incrementamos CX para poder recorrer todo el arreglo
            cmp CX, 00h                 ;; Si CX no es cero, entones que siga imprimiendo filas
            jne printRows               ;; Regresamos a imprimir una nueva fila
    
    ;; Regresamos a su estado original los registros
    pop SI
    pop DI
    pop DX
    pop CX
    pop BX
endm
; ------------------------------------

mPrintNumberConverted macro
    mNumToString 
    mPrintMsg recoveredStr
    mPrintMsg espacio
endm

; ------------------------------------
mEmptyBuffer macro
    push SI
    push CX
    push AX

    mov SI, offset keyBoardBuffer
    mov CL, [SI]
    mov CH, 00
    add SI, 02

    mov AL, 00

    emptyBuffer:
        mov [SI], AL
        inc SI
        loop emptyBuffer

    pop DX
    pop CX
    pop SI
endm


; ------------------------------------
; Macro para leer con el teclado y guardarlo en el buffer del teclado
mGetInputKeyboard macro
    push DX
    push AX
    push CX

    mEmptyBuffer

    mPrintMsg colonChar

    mov DX, offset keyBoardBuffer
    mov AH, 0Ah
    int 21h

    pop CX
    pop AX
    pop DX
endm
; ------------------------------------
; ------------------------------------
; Macro para salir del programa
mExit macro
    mov AH, 4Ch ;4C en hexa servirá para cargar y generar la int del programa
    int 21h
endm
; ------------------------------------