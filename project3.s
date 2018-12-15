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
        
		bne $t4, $zero, dont_print_string_is_empty   		#if user input is empty, and
		beq $t7, $t5, dont_print_string_is_empty     		#if user input is a newline
		li $v0, 4
		la $a0, string_is_empty
      		syscall
		li $v0, 10
		syscall
dont_print_string_is_empty:
	
	#overwriting registers 
		la $s0, char_array
		add $s0, $s0, $t6				#got the address of the start of the number
		
		addi $sp, $sp, -4				#allocate space
		sw $ra, 0($sp)						

		addi $sp, $sp, -8
		
		sw $s0, 0($sp)					#set address of start of number
		sw $t4, 4($sp)					#set length of number
		jal convert_number

		lw $t3, 0($sp)
		addi $sp, $sp, 4
		
		li $v0, 1									
		move $a0, $t3
		syscall						#display result
		
		lw $ra, 0($sp)					#restore return address
		addi $sp, $sp, 4						
		jr $ra
		
convert_number:

		lw $a0, 0($sp)
		lw $a1, 4($sp)
		addi $sp, $sp, 8	
		
		#store parameters of arrays
		addi $sp, $sp, -20							
		sw $ra, 0($sp)								
		sw $s0, 4($sp)					#s0  = used for address of array			
		sw $s1, 8($sp)							
		sw $s2, 12($sp)
		sw $s3, 16($sp)								

#transfer arguments to s-registers
		move $s0, $a0							
		move $s1, $a1		

		#base
		li $t3, 1
		bne $s1, $t3, ignore_number			#if length is equal 1
		lb $t7, 0($s0)					#load the first element of the array
		
		move $a0, $t7					#set character to argument for character_to_digit function
		jal character_to_digit
		move $t7, $v0					#get result
	
		move $t3, $t7					#put the first element in $t3, before it's put on the stack to be returned

		j leave_convert_number
ignore_number:

		addi $s1, $s1, -1							
	
		move $a0, $s1					#set arguments for power_to_31
		jal power_to_31
		move $s3, $v0								
	
		lb $t3, 0($s0)					#loads the first element of the array
		move $a0, $t3
		jal character_to_digit
		move $t3, $v0
		mul $s2, $t3, $s3
		addi $s0, $s0, 1				#increment ptr to start of array
	

	#recursion
		addi $sp, $sp, -8
		sw $s0, 0($sp)
		sw $s1, 4($sp)

		jal convert_number

		lw $t3, 0($sp)
		addi $sp, $sp, 4
		
		add $t3, $s2, $t3				#conversion result + first number and put the return value in $t3

leave_convert_number:

		lw $ra, 0($sp)								
		lw $s0, 4($sp)						
		lw $s1, 8($sp)								
		lw $s2, 12($sp)							
		lw $s3, 16($sp)
		addi $sp, $sp, 20							

		addi $sp, $sp, -4
		sw $t3, 0($sp)

		jr $ra
power_to_31:
		addi $sp, $sp, -4				#allocate space
		sw $ra, 0($sp)					#store returning address
		
		li $t3, 0
		bne $a0, $t3, ignore_zero_exponent
		li $v0, 1
		j leave_num_power
ignore_zero_exponent:

		addi $a0, $a0, -1				#setting argument for recursion call
		jal power_to_31
		move $t7, $v0
		li $t1,31									
		mul $v0, $t1, $t7				#put multiplication result into $v0

leave_num_power:

		lw $ra, 0($sp)					#restore address
		addi $sp, $sp, 4				
		
		jr $ra
		
character_to_digit:
		
		li $t1, 65
		li $t0, 85

	#convert uppercase letter to decimal
		blt $a0, $t1, skip_converting_capital_to_digit			#if ascii of char >= 65 and
