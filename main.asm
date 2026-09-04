%include "constants.asm"

extern savesettings, changesettings, restoresettings
extern openfile, filebuffer, totalfileread, noarguments
extern clearscreen, writetoscreen, movecursor

global _start
section .bss
	store_key_press: resb 1
	cursor_row: resb 1
	cursor_col: resb 1
	filepointer: resb 8
section .text
_start:	
	
.getargument:
	;check if users pass any argument
	mov rsi, [rsp]
	cmp rsi, 2
	jge .savepointer

	;else call no argument
	call noarguments
.savepointer:
	;save pointer to the first element of the array of argument in rsi
	mov rdi, [rsp + 16]
	mov [filepointer], rdi

	;raw mode
	call savesettings
	call changesettings
	
	;read file
	mov rdi, [filepointer]
	call openfile
	mov rbx, rax 	;saving buffer pointer


	;initialize cursor
	mov byte [cursor_row], 1
	mov byte [cursor_col], 1

.refreshscreen:
	;clear screen
	call clearscreen

	;write buffer data to screen
	mov rdi, rbx 
	mov rsi, [totalfileread]
	call writetoscreen


	;write buffer to screen
.writebuffer:

	
	;place cursor at user current editing position
	movzx rdi, byte [cursor_row]
	movzx rsi, byte [cursor_col]
	call movecursor

	;wait for input with sysread on stdin
	mov rdi, STDIN
	mov rsi, store_key_press
	mov rdx, 1
	mov rax, SYS_READ
	syscall

	cmp byte [store_key_press], 0x1B
	je .refreshscreen

;process user input
	cmp byte [store_key_press], 0x11
	je .restoreterminalsettings

	;if character is printable insert to buffer
	cmp byte [store_key_press], 0x20
	jl .unhandledkey
	cmp byte [store_key_press], 0x7E
	jg .unhandledkey

	;store key press to filebuffer
	mov rdi, rbx               ;rbx holds file pointer
	add rdi, [totalfileread]
	mov al, [store_key_press]
	mov [rdi], al

	inc qword [totalfileread]
	inc byte [cursor_col]
	
	;loop jump back to writing buffer to screen
	jmp .refreshscreen

.unhandledkey:
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
