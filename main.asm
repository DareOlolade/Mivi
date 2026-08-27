global _start
section .text
_start:
	;raw mode
	call savesettings
	call changesettings
	
	;read file
	call openfile
	
	;clear screen

	;write buffer to screen
	
	;place cursor at user current editing position
	
	;wait for input with sysread on stdin
	
	;update state when user press a key
	;if character is printable insert to buffer
	;if character is arrow update internal integer cursor coordinate
	;if character is ctrl+Q, break the loop

	;loop jump back to writing buffer to screen

	;restore old terminal settings
	
	;clear the screen

	;exit
