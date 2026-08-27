global openfile, filebuffer
section .data
	error_message: db "Please pass in file name\n"
	error_message_length equ $ - error_message 
section .bss
	filebuffer: resb 4096
	filename: resb 16
	filedescriptor: resb 1

; constants
	;file descriptors
	%define STDIN 0
	%define STDOUT 1
	
	;system call identifiers
	%define SYS_OPEN 2
	%define SYS_READ 0
	%define SYS_WRITE 1
	%define SYS_CLOSE 3
	%define SYS_EXIT 60
	
	;constant parameters
	%define READONLY, 0

section .text

openfile:
	;check if users pass any argument
	mov rdi, [rsp]
	cmp rdi, 2
	jl noarguments
	
	;save pointer to the first element of the array of argument in rsi
	mov rsi, [rsp + 16]
	mov [filename], rsi

	;open and read file data
	mov rax, SYS_OPEN
	mov rdi, [filename]
	mov rsi, READONLY
	mov rdx, 0
	syscall
	
	mov [filedescriptor], rax
	;read file contents into buffer
readfile:
	mov rax, SYS_READ		
	mov rdi, [filedescriptor] 
	mov rsi, filebuffer
	mov rdx, 4096
	syscall
	
	cmp rax, 0
	jg readfile
	
closefile:
	enter 0, 0
	
	;close filie
	mov rax, SYS_CLOSE
	mov rdi, [filedescriptor]
	syscall
	
	;return
	leave
	ret	
noarguments:
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, error_message
	mov rdx, error_message_length
	syscall

	;exit
	mov rax, SYS_EXIT
	mov rdi, 1
	syscall
	
	
