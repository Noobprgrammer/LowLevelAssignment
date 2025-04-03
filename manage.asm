.MODEL SMALL
.STACK 100H
.data
    correct DB "Wroks$"
    ; Main menu String
    mainMenu1 DB "1) Restock an Item$"
    mainMenu2 DB "2) Add Item to Cart$"
    mainMenu3 DB "3) Change details of Item$"
    mainMenu4 DB "4) Check Item price and quantity$"
    mainMenu5 DB "5) Daily Sales report$"
    
    wrongInputMessage DB "This is a Wrong Input"
    
    menuMessage DB "Enter a number (1-5): $"
    
    ;Array of main menu string
    mainMenu DW offset mainMenu1, offset mainMenu2, offset mainMenu3, offset mainMenu4, offset mainMenu5
    
    mainMenuSize DW 5
    
    ; Assigning Milk Data
    itemMilk DB "Milk$"
    milkQuantity DB "10$"
    milkPrice DB "2.00$"
    
    ; Assigning Potato Data
    itemPotato DB "Potato$"
    potatoQuantity DB "20$"
    potatoPrice DB "5.00$"
    
    ; Carriage Return + Line Feed (New Line)
    CRLF DB 13,10,'$'         

    ; Arrays storing addresses of Milk and Potato data
    milkArray dw offset itemMilk, offset milkQuantity, offset milkPrice
    potatoArray dw offset itemPotato, offset potatoQuantity, offset potatoPrice
    
    ; Array of pointers to the item arrays
    itemArray dw offset milkArray, offset potatoArray
    
    ; Storing the size of the array
    itemStrCount Dw 3  ; Number of strings per item
    itemNumber  DW 2   ; Number of items (milk and potato)

.CODE

DisplayArrayHori Macro array, arraySize
    mov cx, arraySize
    mov si, 0
    
loopArray:
    mov bx, si
    shl bx, 1
    mov dx, [array + bx]
    StringHori
    StringHoriDis CRLF
    add si, 1
    loop loppArray
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
    
    call MainMenuDisplay
    
    call GetUserInput
    
    mov ah, 4ch
    int 21h
    
MAIN ENDP
    
MainMenuDisplay PROC
    
    mov cx, 5
    mov si, 0
    
    
loopMenu:
    mov bx, si
    shl bx, 1
    mov dx, mainMenu[bx]
    StringHori
    StringHoriDis CRLF
    add si, 1
    loop loopMenu
    
    ret
MainMenuDisplay ENDP

GetUserInput PROC
    
    StringHoriDis menuMessage
    
    mov ah, 01h
    int 21h
    sub al,'0'
    StringHoriDis CRLF
    
    cmp al, 1
    jl wrongInput
    cmp al, 5
    jg wrongInput
    cmp al, 4
    DisplayArrayHori
    
    StringHoriDis correct
    StringHoriDis CRLF
    ret

wrongInput:
    StringHoriDis wrongInputMessage
    StringHoriDis CRLF
    StringHoriDis CRLF
    call MAIN
    
    ret
    
GetUserInput ENDP

MenuInputProcess PROC
    
    

END MAIN  
   