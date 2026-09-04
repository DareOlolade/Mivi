%include "constants.asm"
global openfile, filebuffer, totalfileread, noarguments

section .data
	noarg_err_msg: db "Please pass in file name\n"
	noarg_err_msg_len equ $ - noarg_err_msg 

	err_opening_file_msg: db "Error opening file\n"
	err_opening_file_msg_len equ $ - err_opening_file_msg

	offset: dq 0
	
section .bss
	filebuffer: resb 4096
	filedescriptor: resb 8
	totalfileread: resb 8


section .text
openfile:
	enter 0, 0
	;file name passed in rdi
	
	mov qword [offset], 0
	;open and read file data
	mov rax, SYS_OPEN
	mov rsi, READONLY
	mov rdx, 0
	syscall
	

	cmp rax, 0
	jl error_opening_file
	
	mov qword [filedescriptor], rax
	;read file contents into buffer
readfile:
	mov rax, SYS_READ		
	mov rdi, [filedescriptor] 
	mov rsi, filebuffer
	add rsi, [offset]
	mov rdx, 4096 
	sub rdx, [offset]
	syscall
	
	cmp rax, 0
	jle closefile

	add [offset], rax
	
	cmp qword [offset], 4096
	jl readfile
 
closefile:
	
	mov rax, [offset]
	mov [totalfileread], rax
	

	;close filie
	mov rax, SYS_CLOSE
	mov rdi, [filedescriptor]
	syscall
	
	;return
	mov rax, filebuffer
	leave
	ret	
noarguments:
	enter 0, 0

	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, noarg_err_msg
	mov rdx, noarg_err_msg_len
	syscall

	;exit
	mov rax, SYS_EXIT
	mov rdi, 1
	syscall
	
error_opening_file:
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, err_opening_file_msg
	mov rdx, err_opening_file_msg_len
	syscall

	;exit
	mov rax, SYS_EXIT
	mov rdi, 1
	syscall
