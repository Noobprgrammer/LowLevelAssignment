.MODEL SMALL
.STACK 100H
.data
    ;debug
    correct DB "Wroks$"
    continueMessage DB "Press a Key to Continue: $"
    ; Main menu String
    mainMenu1 DB "1) Restock an Item$"
    mainMenu2 DB "2) Add Item to Cart$"
    mainMenu3 DB "3) Change details of Item$"
    mainMenu4 DB "4) Check Item price and quantity$"
    mainMenu5 DB "5) Daily Sales report$"
    mainMenu6 DB "6) Exit Program$"
    
    wrongInputMessage DB "This is a Wrong Input$"
    
    menuMessage DB "Enter a number (1-5): $"
    
    ;Array of main menu string
    mainMenu DW offset mainMenu1, offset mainMenu2, offset mainMenu3, offset mainMenu4, offset mainMenu5, offset mainMenu6
    
    mainMenuSize DW 6
    
    ; Assigning Milk Data
    itemMilk DB "Milk$"
    milkQuantity DB "10$"
    milkPrice DB "2.00$"
    
    milkArray DW offset itemMilk, offset milkQuantity, offset milkPrice
    
    ; Assigning Potato Data
    itemPotato DB "Potato$"
    potatoQuantity DB "20$"
    potatoPrice DB "5.00$"
    
    ; Carriage Return + Line Feed (New Line)
    CRLF DB 13,10,'$'         

    ; Arrays storing addresses of Milk and Potato data
    
    potatoArray dw offset itemPotato, offset potatoQuantity, offset potatoPrice
    
    ; Storing the size of the array
    itemStrCount Dw 3  ; Number of strings per item

.CODE

DisplayArrayVer Macro array, arraySize
    Local loopArrayVer
    mov cx, arraySize
    mov si, 0
loopArrayVer:
    mov bx, si
    shl bx, 1
    mov dx, [array + bx]
    StringHori
    CharHoriDis ','
    CharHoriDis ' '
    add si, 1
    loop loopArrayVer
    StringHoriDis CRLF
EndM

PressKeyToContinue Macro
    StringHoriDis continueMessage
    mov ah,01h
    int 21h
ENDM
 
DisplayArrayHori Macro array, arraySize
    LOCAL loopArrayHori
    mov cx, arraySize
    mov si, 0
    
loopArrayHori:
    mov bx, si
    shl bx, 1
    mov dx, [array + bx]
    StringHori
    StringHoriDis CRLF
    add si, 1
    loop loopArrayHori
EndM
    
CharHoriDis Macro char
    mov dl, char
    mov ah, 02h
    int 21h
EndM

StringHori Macro
    mov ah, 09h
    int 21h
EndM

StringHoriDis Macro mess
    lea dx, mess
    mov ah, 09h       ; DOS function to display a string
    int 21h           ; Call DOS interrupt
EndM                 ; End of macro

MAIN PROC
    mov ax, @data
    mov ds, ax
    
    DisplayArrayHori mainMenu, mainMenuSize
    
    call GetUserInput
    
MAIN ENDP
    

GetUserInput PROC
    
    StringHoriDis menuMessage
    
    mov ah, 01h
    int 21h
    sub al,'0'
    StringHoriDis CRLF
    
    cmp al, 1
    jl wrongInput
    cmp al, 6
    jg wrongInput
    cmp al, 4
    je DisplayItem
    cmp al, 6
    je exitProgram
    
    StringHoriDis correct
    StringHoriDis CRLF
    ret
    
exitProgram:
    mov ah, 4ch
    int 21h
    ret

wrongInput:
    StringHoriDis wrongInputMessage
    StringHoriDis CRLF
    StringHoriDis CRLF
    call MAIN
    
    ret
    
GetUserInput ENDP

DisplayItem:
    StringHoriDis CRLF
    DisplayArrayVer milkArray, itemStrCount
    DisplayArrayVer potatoArray, itemStrCount
    StringHoriDis CRLF
    PressKeyToContinue
    StringHoriDis CRLF
    StringHoriDis CRLF
    call MAIN
    ret



    


END MAIN  
   