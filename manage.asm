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
    
    menuMessage DB "Enter a number (1-6): $"
    
    ;Array of main menu string
    mainMenu DW offset mainMenu1, offset mainMenu2, offset mainMenu3, offset mainMenu4, offset mainMenu5, offset mainMenu6
    
    mainMenuSize DW 6
    
    tableHeader1 DB "Iteam$"
    tableHeader2 DB "Quan$"
    tableHeader3 DB "Price$"
    
    tableArray DW offset tableHeader1, offset tableHeader2, offset tableHeader3
    
    tableArraySize DW 3
    
    
    ; Assigning Milk Data
    itemMilk DB "Milk$"
    milkQuantity DB "10$"
    milkPrice DB "2.00$$"
    
    milkArray DW offset itemMilk, offset milkQuantity, offset milkPrice
    
    ; Assigning Potato Data
    itemPotato DB "Potato$"
    potatoQuantity DB "20$"
    potatoPrice DB "5.00$"        

    ; Arrays storing addresses of Milk and Potato data
    
    potatoArray dw offset itemPotato, offset potatoQuantity, offset potatoPrice
    
    itemArray Dw offset itemMilk, offset itemPotato
    
    itemArraySize DW 2
    
    ; Carriage Return + Line Feed (New Line)
    CRLF DB 13,10,'$' 
    
    ; Storing the size of the array
    itemStrCount Dw 3  ; Number of strings per item

.CODE

DisplayArrayHori Macro array, arraySize
    Local loopArrayVer
    mov cx, arraySize
    mov si, 0
loopArrayVer:
    mov bx, si
    shl bx, 1
    mov dx, [array + bx]
    StringHori
    CharHoriDis 09h
    add si, 1
    loop loopArrayVer
    StringHoriDis CRLF
EndM


PressKeyToContinue Macro
    StringHoriDis continueMessage
    mov ah,01h
    int 21h
ENDM

 
DisplayArrayVer Macro array, arraySize
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
    mov ah, 09h       
    int 21h           
EndM                 

MAIN PROC
    mov ax, @data
    mov ds, ax
    
    mov ah, 0
    mov al, 3
    int 10h
    
    DisplayArrayVer mainMenu, mainMenuSize
    
    call GetUserInput
    
MAIN ENDP

UserInput:
    mov ah, 01h
    int 21h
    sub al,'0'
    ret   

GetUserInput PROC
    
    StringHoriDis menuMessage
    
    call UserInput
    
    StringHoriDis CRLF
    
    cmp al, 1
    jl wrongInput
    cmp al, 6
    jg wrongInput
    cmp al, 1
    je RestockSection
    cmp al, 4
    je DisplayItem
    cmp al, 6
    je exitProgram
    
    
    StringHoriDis correct
    StringHoriDis CRLF
    ret
    
GetUserInput ENDP
 
    
wrongInput:
    StringHoriDis wrongInputMessage
    StringHoriDis CRLF
    StringHoriDis CRLF
    PressKeyToContinue
    jmp MAIN
    
    ret

exitProgram:
    mov ah, 4ch
    int 21h
    ret

RestockSection:
    call UserInput
    StringHoriDis correct
    StringHoriDis CRLF
    PressKeyToContinue
    
    jmp MAIN
    ret

DisplayItem:
    StringHoriDis CRLF
    DisplayArrayHori tableArray, tableArraySize
    DisplayArrayHori milkArray, itemStrCount
    DisplayArrayHori potatoArray, itemStrCount
    StringHoriDis CRLF
    PressKeyToContinue
    StringHoriDis CRLF
    StringHoriDis CRLF
    jmp MAIN
    ret



    
END MAIN  
   