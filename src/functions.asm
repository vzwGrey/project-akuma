clear_screen:
	mov ah, 0x06 ; Scroll window function
	mov al, 0 ; 0 = clear
	mov bh, 0x07
	mov cx, 0x0000 ; Top left corner
	mov dx, 0x184F ; Bottom right corner (24 rows, 79 cols)
	int 0x10
	xor bx, bx ; Page number
	mov ah, 0x02 ; Move cursor function
	mov dx, 0x0000 ; Position
	int 0x10
	ret

move_cursor_back:
	mov ah, 0x03 ; Get cursor position
	int 0x10
	cmp dl, 0 ; Check if column is 0 to wrap back to previous line
	je .decrease_row
	dec dl ; Decrease column by 1
	jmp .end
.decrease_row:
	dec dh
.end:
	mov ah, 0x02 ; Set cursor position
	int 0x10
	ret

get_input:
	xor bx, bx
	xor ax, ax
	int 0x16
	cmp ah, 0x0E ; Check if scancode is backspace
	je .backspace
	cmp ah, 0x1C ; Check if scancode is enter
	je .enter_key
	mov [si], al ; Move character into string pointed to by si
	inc si ; Increase si to point to the next slot in the string
	mov ah, 0x0E
	int 0x10
	jmp get_input
.backspace:
	call move_cursor_back
	mov ah, 0x0E
	mov al, ' '
	int 0x10
	call move_cursor_back
	dec si
	jmp get_input
.enter_key:
	call end_line
	ret

string_equal:
	cmp BYTE [si], 0x00
	je .end_string
	cmp BYTE [di], 0x00
	je .end_string
	mov al, [di]
	cmp BYTE [si], al
	jne .end
	inc si
	inc di
	jmp string_equal
.end_string:
	mov al, [di]
	cmp [si], al
	ret
.end:
	ret
