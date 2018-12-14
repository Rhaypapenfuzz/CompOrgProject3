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
		li $t0, 32					#storing space into $t3
		li $t1, 0					#counter i = 0					
		li $s0, 0					#counter to help keep track of previous character. initialized as 0
		la $t3, char_array				#loading userInput address into register
		li $t4, 0					#number of characters = 0
		li $t5, 10					#loaded new line into $t5
		li $t6, 0					#second counter to track number of spaces before actual input

loop:
		lb $t7, 0($t3)					#get string input
		beq $t7, $t5, break_loop			#break if character is a newline char
	#branch instructions for different conditions
		beq $t7, $t0, skip_invalid_spaces         #if mycharacter is_not_a_space &
		bne $s0, $t0, skip_invalid_spaces         #if the previous_checked_character is a space &
		beq $t4, $0, skip_invalid_spaces          #if the number_of_previously_checked chars is not 0 &
		beq $t7, $0, skip_invalid_spaces          #character is not null &
		beq $t7, $t5, skip_invalid_spaces         #the character is not a new line then proceed else skip to skip_invalid_spaces label
	
	#if input is not_valid && string_is_too_long, choose string_is_too_long 
		
		sub $t3, $t1, $t6								
		addi $t3, $t3, 1							#increment register by 1
		li $t7, 4										
		ble $t3, $t7, skip_string_is_too_long_instead_do_notvalid     
		
		li $v0, 4
		la $a0,string_is_too_long
		
		syscall									
		jr $ra	
	
skip_string_is_too_long_instead_do_notvalid:

		li $v0, 4
		la $a0, not_valid
		syscall	
		
		li $v0, 10
		syscall
		
skip_invalid_spaces:
		beq $t7, $t0, dont_increase_number_of_characters		#branch if current character is a space else proceed
		addi $t4, $t4, 1						#number_of_characters + 1
dont_increase_number_of_characters:

		bne $t7, $t0, dont_increase_space_counter			#if current character is a space
		bne $t4, $0, dont_increase_space_counter			
		addi $t6, $t6, 1
		
dont_increase_space_counter:

		move $s0, $t7							#set previous character with current one
		addi $t3, $t3, 1						#incremented the address
		addi $t1, $t1, 1						#incremented i
		j loop
		
break_loop:

		li $t7, 4
		ble $t4, $t7, dont_print_string_is_too_long			#checks if userInput is more than 4
		
		li $v0, 4
		la $a0, string_is_too_long
		syscall								#print string_is_too_long_error if char>4
		li $v0, 10
		syscall
		
dont_print_string_is_too_long:
        
		bne $t4, $zero, dont_print_string_is_empty   #if user input is empty, and
		beq $t7, $t5, dont_print_string_is_empty     #if user input is a newline
		li $v0, 4
		la $a0, string_is_empty
      		syscall
		li $v0, 10
		syscall
dont_print_string_is_empty:
	
	#overwriting registers 
		la $s0, char_array		
	
