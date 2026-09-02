%include "constants.asm"
global _start
section .bss
	store_key_press: resb 1
	cursor_row: resb 1
	cursor_col: resb 1
section .text
_start:
	;raw mode
	call savesettings
	call changesettings
	
	;read file
	call openfile
	mov rbx, rax 	;saving buffer pointer

	;clear screen
	call clearscreen

	;write buffer to screen
.writebuffer:
	mov rdi, rbx 
	mov rsi, [totalfileread]
	call writetoscreen

	
	;place cursor at user current editing position
	call movecursor
	;wait for input with sysread on stdin
	mov rdi, STDIN
	mov rsi, store_key_press
	mov rdx, 1
	mov rax, SYS_READ
	syscall

	;update state when user press a key
	;if character is printable insert to buffer
	cmp byte [store_key_press], 0x20
	jl continue
	cmp byte [store_key_press], 0x7E
	jg continue

	;else write it to screen
	mov rax, SYS_write
	mov rdi, STDOUT
	mov rsi, [store_key_press]
	mov rdx, filebuffer
	add rdx, [totalfileread]
	syscall
	
	inc [cursor_col]
	;if character is arrow update internal integer cursor coordinate
continue:
	
	;if character is ctrl+Q, break the loop
	cmp byte [store_key_press], 0x11 	;0x11 ascii for ctrl+Q
	je .restorterminalsettings

	;loop jump back to writing buffer to screen
	jmp .writebuffer

	;restore old terminal settings
.restoreterminalsettings:
	call restoresettings

	;clear the screen
	call clearscreen

	;exit
	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall
