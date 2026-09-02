%include "constants.asm"
global clearscreen, writetoscreen, movecursor

section .data
	
	;ANSI codes
	ansi_clear db 27,"[2J", 27, "[H"
	ansi_clear_len equ $ - ansi_clear
	
	esc_start db 27, "["
	esc_middle db ";"
	esc_end db "H"

section .bss
	ansi_move_buffer resb 32  ;holds the final string that represent cursor position
	number_buffer resb 10 ; for integer to ascii conversion



section .text
clearscreen:
	enter 0, 0
	
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, ansi_clear
	mov rdx, ansi_clear_len
	syscall

	leave
	ret

writetoscreen:
	enter 0, 16
	; rdi would hold screen buffer
	; rsi holds how much to write

	mov [rbp - 8], rdi
	mov [rbp -16], rsi

	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, [rbp-8]
	mov rdx, [rbp - 16]
	syscall

	leave
	ret

movecursor:
	enter 0, 16
	
	push rsi
	;curso position
	;row - rdi
	;column - rsi

	mov rdx, ansi_move_buffer
	mov byte [rdx], 27
	mov byte [rdx + 1], "["
	add rdx, 2     ;increment to point to where the next character would be added
	
	
	;convert to ascii
	mov rax, rdi
	call int_to_ascii

	;loop through x coordinate and write to ansi buffer
.loop_x_coordinate:
	mov sil, [r8]
	mov[rdx], sil
	inc rdx
	inc r8
	cmp r8, number_buffer+10
	jl .loop_x_coordinate
	
	mov byte [rdx], ';'
	inc rdx

	pop rax
	call int_to_ascii
	
	;loop through y coordinate and write to ansi buffer
.loop_y_coordinate:
	mov sil, [r8]
	mov[rdx], sil
	inc rdx
	inc r8
	cmp r8, number_buffer+10
	jl .loop_y_coordinate

	mov byte [rdx], 'H'
	inc rdx
	
	
	;move cursor
	mov rsi, ansi_move_buffer ;holds buffer pointer
	sub rdx, rsi		  ;calculate and save buffer length
	
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	syscall
	
	leave
	ret

int_to_ascii:
	enter 0, 16
	push rdx

	mov rbx, 10
	lea r8, [number_buffer + 10]
	

.push_digits:
	xor rdx, rdx
	div rbx
	add dl, '0'
	dec r8
	mov [r8], dl
	test  rax, rax
	jnz .push_digits
	
	pop rdx
	leave
	ret
	



	

