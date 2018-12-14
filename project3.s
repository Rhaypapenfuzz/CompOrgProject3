.data		
#Invalid Messages
char_array:				.space 4000
string_is_too_long:			.asciiz "Input is too long."
not_valid:				.asciiz "Invalid base-31 number."
string_is_empty: 			.asciiz "Input is empty."

.text				
.globl main

main:
		li $v0, 8
		la $a0, char_array
		syscall
		li $t0, 32				#storing space into $t3
		li $t1, 0				#counter i = 0					
		li $s0, 0				#counter to help keep track of previous character. initialized as 0
		la $t3, char_array			#loading userInput address into register
		li $t4, 0				#number of characters = 0
		li $t5, 10				#loaded new line into $t5
		li $t6, 0				#second counter to track number of spaces before actual input

loop:
		lb $t7, 0($t3)				#get string character
		beq $t7, $t5, break_loop		#break if character is a newline char
	#branch instructions for different conditions
		beq $t7, $t0, skip_invalid_spaces         #if character is not a space and
		bne $s0, $t0, skip_invalid_spaces         #if the previous character is a space &
		beq $t4, $0, skip_invalid_spaces          #if the number of previously seen characters is not zero and
		beq $t7, $0, skip_invalid_spaces          #if the character is not null and
		beq $t7, $t5, skip_invalid_spaces         #if the character is not new line then print invalid
	
        li $v0, 4
        la $a0, not_valid
        syscall	
	
	#print invalid spaces
	li $v0, 10
	syscall
	
