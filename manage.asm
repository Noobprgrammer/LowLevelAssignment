.MODEL SMALL
.STACK 100H

.DATA
; Messages
menuMessage DB "Enter a number (1-6): $"
wrongInputMessage DB "Invalid input. Press a key to retry.$"
continueMessage DB "Press any key to continue...$"

; Main Menu Text
mainMenu1 DB "1) Restock an Item$"
mainMenu2 DB "2) Add Item to Cart$"
mainMenu3 DB "3) Change details of Item$"
mainMenu4 DB "4) Check Item price and quantity$"
mainMenu5 DB "5) Daily Sales Report$"
mainMenu6 DB "6) Exit Program$"

mainMenu DW offset mainMenu1, offset mainMenu2, offset mainMenu3, offset mainMenu4, offset mainMenu5, offset mainMenu6
mainMenuSize DW 6

; Number of items in inventory
NUM_ITEMS EQU 5    ; Define number of items as a constant

; Items
itemNames DB "Milk$"
          DB 50 DUP(0)    ; Reserve 50 bytes for the name
          DB "Potato$"
          DB 50 DUP(0)
          DB "Bread$"
          DB 50 DUP(0)
          DB "Apple$"
          DB 50 DUP(0)
          DB "Coffee$"
          DB 50 DUP(0)

; Item name pointers array
itemPtrs  DW 5 DUP(?)     ; Will be initialized in startup

; Quantities
quantities DB 10, 20, 15, 30, 5    ; Initial quantities for all 5 items

; Prices
prices     DB 2, 5, 3, 1, 7        ; Prices for all 5 items

; Sales Tracking
sales      DB 5 DUP(0)            ; Sales counter for each item
totalEarnings DB 0                ; To store accumulated earnings

; String literals for various messages
welcomeMessage DB "Welcome to Meekail Store$"
itemPrompt     DB "Select item (1-Milk,2-Potato,3-Break,4-Apple,5-Coffee): $"
quantityPrompt DB "Enter quantity: $"
stockUpdatedMsg DB "Stock updated!$"
purchaseSuccessMsg DB "Purchase successful!$"
notEnoughStockMsg DB "Not enough stock!$"
changePricePrompt DB "Enter new price (single digit): $"
priceUpdatedMsg DB "Price updated!$"
itemTableHeader DB "Item       Quantity     Price$"
colItem DB "Item    : $"
colQuantity DB "Quantity : $" 
colPrice DB "Price   : $"
salesReportHeader DB "Daily Sales Report:$"
totalEarningsLabel DB "Total Earnings: $"
soldLabel DB " sold: $"

; For CRLF
CRLF DB 13,10,'$'

.CODE

; Macros
StringHoriDis MACRO message
    push dx
    lea dx, message
    mov ah, 09h
    int 21h
    pop dx
ENDM

CharHoriDis MACRO character
    push dx
    mov dl, character
    mov ah, 02h
    int 21h
    pop dx
ENDM

; Modified PressKeyToContinue with screen clearing
PressKeyToContinue MACRO
    StringHoriDis CRLF
    StringHoriDis continueMessage
    mov ah, 01h
    int 21h
    
    ; Clear screen after key press
    mov ax, 0003h
    int 10h
ENDM

; Helper procedure to show error message
ShowInvalidInput PROC
    StringHoriDis CRLF
    StringHoriDis wrongInputMessage
    PressKeyToContinue
    ret
ShowInvalidInput ENDP

; Single Digit Number Reader
ReadNumber PROC
    mov ah, 01h
    int 21h
    sub al, '0'
    ret
ReadNumber ENDP

; Main Program
MAIN PROC
    mov ax, @data
    mov ds, ax

    ; Set up item pointers array
    call InitializeItemPointers

    mov ah, 0
    mov al, 3
    int 10h
    
MainMenu:
    StringHoriDis welcomeMessage
    StringHoriDis CRLF
    StringHoriDis CRLF
    call DisplayMainMenu
    call GetUserChoice
    jmp MainMenu
MAIN ENDP

; Initialize pointers to item names
InitializeItemPointers PROC
    mov si, OFFSET itemNames   ; Start of the first item name
    mov di, OFFSET itemPtrs    ; Pointer array
    mov cx, NUM_ITEMS          ; Number of items
    
init_loop:
    mov [di], si               ; Store pointer to current item name
    add di, 2                  ; Next pointer slot (word size)
    
    ; Skip to next item name (find $ terminator and add 1)
    push cx
    mov cx, 50                 ; Maximum bytes to search
    
find_end:
    cmp BYTE PTR [si], '$'
    je found_end
    inc si
    loop find_end
    
found_end:
    inc si                     ; Move past the $ to the blank space
    add si, 50                 ; Skip to next item block (fixed size)
    pop cx
    
    loop init_loop
    ret
InitializeItemPointers ENDP

DisplayMainMenu PROC
    mov cx, mainMenuSize
    mov si, 0
MenuLoop:
    mov bx, si
    shl bx, 1
    mov dx, [mainMenu+bx]
    push dx
    mov ah, 09h
    int 21h
    pop dx
    StringHoriDis CRLF
    inc si
    loop MenuLoop
    ret
DisplayMainMenu ENDP

GetUserChoice PROC
    StringHoriDis CRLF
    StringHoriDis menuMessage
    call ReadNumber

    ; Use simple compare and call approach
    cmp al, 1
    jne Check_Choice2
    call RestockSection
    jmp Choice_End
    
Check_Choice2:
    cmp al, 2
    jne Check_Choice3
    call AddItemToCart
    jmp Choice_End
    
Check_Choice3:
    cmp al, 3
    jne Check_Choice4
    call ChangeItemDetails
    jmp Choice_End
    
Check_Choice4:
    cmp al, 4
    jne Check_Choice5
    call DisplayItems
    jmp Choice_End
    
Check_Choice5:
    cmp al, 5
    jne Check_Choice6
    call DailySalesReport
    jmp Choice_End
    
Check_Choice6:
    cmp al, 6
    jne InvalidChoice
    call ExitProgram
    jmp Choice_End

InvalidChoice:
    call ShowInvalidInput
    
Choice_End:
    ret
GetUserChoice ENDP

ExitProgram PROC
    mov ah, 4Ch
    int 21h
ExitProgram ENDP

; Validate item number in AL, returns carry flag if invalid
ValidateItemNumber PROC
    cmp al, 1           ; Must be at least 1
    jb invalidItem
    cmp al, NUM_ITEMS   ; Must not exceed number of items
    ja invalidItem
    clc                 ; Clear carry flag (valid)
    ret
    
invalidItem:
    stc                 ; Set carry flag (invalid)
    ret
ValidateItemNumber ENDP

; Define NotEnoughStock procedure
NotEnoughStock PROC
    StringHoriDis CRLF
    StringHoriDis notEnoughStockMsg
    PressKeyToContinue
    ret
NotEnoughStock ENDP

; Restocking items
RestockSection PROC
    StringHoriDis CRLF
    StringHoriDis itemPrompt
    call ReadNumber
    
    call ValidateItemNumber
    jc Restock_Invalid
    
    ; Convert to zero-based index
    dec al
    
    ; Save item index
    mov bl, al
    
    ; Prompt for quantity
    StringHoriDis CRLF
    StringHoriDis quantityPrompt
    call ReadNumber
    
    ; Get pointer to quantity
    mov bh, 0      ; Clear high byte
    add bx, OFFSET quantities
    
    ; Add quantity to stock
    add [bx], al
    
    StringHoriDis CRLF
    StringHoriDis stockUpdatedMsg
    PressKeyToContinue
    jmp End_Restock
    
Restock_Invalid:
    call ShowInvalidInput
    
End_Restock:
    ret
RestockSection ENDP

; Define Buy_Invalid handler before it's used
Buy_Invalid_Handler PROC
    call ShowInvalidInput
    ret
Buy_Invalid_Handler ENDP

; Adding items to cart (buying)
AddItemToCart PROC
    StringHoriDis CRLF
    StringHoriDis itemPrompt
    call ReadNumber
    
    call ValidateItemNumber
    jc Buy_Invalid
    jmp Continue_Buy
    
Buy_Invalid:
    call Buy_Invalid_Handler
    jmp End_Buy
    
Continue_Buy:
    ; Convert to zero-based index
    dec al
    
    ; Save item index
    mov bl, al
    
    ; Prompt for quantity
    StringHoriDis CRLF
    StringHoriDis quantityPrompt
    call ReadNumber
    
    ; Save quantity in DL for later use
    mov dl, al
    
    ; Check if we have enough stock
    mov bh, 0
    mov si, bx          ; Save item index in SI
    add bx, OFFSET quantities
    
    ; Compare requested quantity with available stock
    mov al, dl          ; Restore quantity to AL
    cmp al, [bx]        ; Compare with available stock
    ja Buy_NotEnough    ; Jump if quantity requested > available
    
    ; Calculate and add earnings
    mov cl, al          ; Save quantity in CL
    mov bx, si          ; Restore item index to BX
    add bx, OFFSET prices
    mov al, cl          ; Restore quantity to AL
    mul BYTE PTR [bx]   ; AL = AL * price
    add totalEarnings, al ; Add to total earnings
    
    ; Update stock
    mov al, cl          ; Restore quantity to AL
    mov bx, si          ; Restore item index
    add bx, OFFSET quantities
    sub [bx], al        ; Subtract from stock
    
    ; Update sales counter
    mov bx, si
    add bx, OFFSET sales
    add [bx], al        ; Add to sales counter
    
    StringHoriDis CRLF
    StringHoriDis purchaseSuccessMsg
    PressKeyToContinue
    jmp End_Buy
    
Buy_NotEnough:
    call NotEnoughStock
    
End_Buy:
    ret
AddItemToCart ENDP

; Changing item details (price)
ChangeItemDetails PROC
    StringHoriDis CRLF
    StringHoriDis itemPrompt
    call ReadNumber
    
    call ValidateItemNumber
    jc Change_Invalid
    
    ; Convert to zero-based index
    dec al
    
    ; Save item index
    mov bl, al
    
    ; Prompt for new price
    StringHoriDis CRLF
    StringHoriDis changePricePrompt
    call ReadNumber
    
    ; Update price
    mov bh, 0
    add bx, OFFSET prices
    mov [bx], al
    
    StringHoriDis CRLF
    StringHoriDis priceUpdatedMsg
    PressKeyToContinue
    jmp End_Change
    
Change_Invalid:
    call ShowInvalidInput
    
End_Change:
    ret
ChangeItemDetails ENDP

; Helper procedure to display a number properly
DisplayNumber PROC
    ; Convert number in AL to its decimal representation
    xor ah, ah  ; Clear AH to use AX
    mov bl, 10
    div bl      ; Divide AX by 10, quotient in AL, remainder in AH
    
    ; If quotient is not zero, display it
    cmp al, 0
    je SkipTens
    add al, '0'
    mov dl, al
    push ax     ; Save AX (including remainder in AH)
    mov ah, 02h
    int 21h
    pop ax      ; Restore AX to get remainder
    
SkipTens:
    ; Display remainder/ones digit
    mov al, ah
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    ret
DisplayNumber ENDP

; Display Items with proper quantity formatting
DisplayItems PROC
    mov cx, NUM_ITEMS   ; Number of items to display
    xor si, si          ; Start with item 0
    
display_loop:
    push cx             ; Save loop counter
    
    StringHoriDis CRLF
    
    ; Display item name
    StringHoriDis colItem
    mov bx, si
    shl bx, 1           ; Multiply by 2 for word offset
    mov dx, [itemPtrs+bx] ; Get pointer to item name
    mov ah, 09h
    int 21h
    StringHoriDis CRLF
    
    ; Display quantity
    StringHoriDis colQuantity
    mov bx, si
    add bx, OFFSET quantities
    mov al, [bx]
    call DisplayNumber
    StringHoriDis CRLF
    
    ; Display price
    StringHoriDis colPrice
    CharHoriDis '$'
    mov bx, si
    add bx, OFFSET prices
    mov al, [bx]
    call DisplayNumber
    StringHoriDis CRLF
    
    inc si              ; Next item
    pop cx              ; Restore loop counter
    loop display_loop
    
    PressKeyToContinue
    ret
DisplayItems ENDP

; Daily sales report
DailySalesReport PROC
    StringHoriDis CRLF
    StringHoriDis salesReportHeader
    StringHoriDis CRLF
    
    ; Display sales for each item
    mov cx, NUM_ITEMS
    xor si, si          ; Start with item 0
    
sales_loop:
    push cx             ; Save loop counter
    
    ; Display item name
    mov bx, si
    shl bx, 1           ; Multiply by 2 for word offset
    mov dx, [itemPtrs+bx] ; Get pointer to item name
    mov ah, 09h
    int 21h
    
    ; Display "sold: "
    StringHoriDis soldLabel
    
    ; Display sales quantity
    mov bx, si
    add bx, OFFSET sales
    mov al, [bx]
    call DisplayNumber
    StringHoriDis CRLF
    
    inc si              ; Next item
    pop cx              ; Restore loop counter
    loop sales_loop
    
    ; Display total earnings
    StringHoriDis CRLF
    StringHoriDis totalEarningsLabel
    CharHoriDis '$'
    mov al, totalEarnings
    call DisplayNumber
    
    StringHoriDis CRLF
    PressKeyToContinue
    ret
DailySalesReport ENDP

END MAIN 