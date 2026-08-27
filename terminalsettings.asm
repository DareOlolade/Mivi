global savesettings, changesettings, restoresettings
section .bss
	 old_terminal_settings: resb 60
	 new_terminal_settings: resb 60
	
; constants
	%define STDIN 0
	
	;system call identifiers
	%define SYS_IOCTL 16
	%define SYS_READ 0
	%define SYS_EXIT 60

	;Terminal related ioctl parameters
	%define TCGETS 0x5401
	%define TCSETS 0x5402
	
	;local flags
	%define ECHO 0x00000008
	%define ICANON 0x00000002

section .text

savesettings:
	enter 0, 0

	mov rax, SYS_IOCTL
	mov rdi, STDIN
	mov rsi, TCGETS
	lea rdx, [old_terminal_settings]
	syscall
	
	;check if it was successful
	cmp rax, 0
	jl error
	
	;return
	leave
	ret

changesettings:
	enter 0, 0

	;first copy old settings
	cld
	mov rcx, 60
	lea rsi, old_terminal_settings
	lea rdi, new_terminal_settings
	rep movsb

	;modify the settings to put terminal in raw mode
	mov eax, [new_terminal_settings + 12]
	
	and eax, ~ECHO 
	and eax, ~ICANON 
	mov [new_terminal_settings+12], eax

	;apply settings
	mov rax, SYS_IOCTL
	mov rdi, STDIN
	mov rsi, TCSETS
	lea rdx, [new_terminal_settings]
	syscall
	
	;check if it was successful	
	cmp rax, 0
	jl error
	
	;return
	leave
	ret

restoresettings:
	enter 0, 0
	
	;restore back old settings
	mov rax, SYS_IOCTL
	mov rdi, STDIN
	mov rsi, TCSETS
	lea rdx, [old_terminal_settings]
	syscall
	
	;check if it was successful
	cmp rax, 0
	jl error

	;return
	leave
	ret
error:
	mov rax, SYS_EXIT
	mov rdi, 1
	syscall
	
