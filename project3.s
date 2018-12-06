.data           #Data declaration section
#Invalid Messages
char_array:			.space 4000
too_long:			.asciiz "Input is too long."
not_valid:			.asciiz "Invalid base-31 number."
empty_string_error: .asciiz "Input is empty."

.text           #Assembly language instruction
.globl main

main:
        li $v0, 8
        la $a0, char_array
        syscall
        la $t0, char_array			#loading address of userInput
	lb $t1, 0($t0)					#get string character
	li $t2, 0					#initializing counter i as zero
        li $t3, 32					#storing space char into $t3
        li $s0, 0					#counter to help keep track of previous character. initialized as 0
        li $t5, 0					#initialized number of chracters
        li $t6, 10					#loaded new line into $t6
	li $t7, 0					#another counter to help with number of spaces in front of actual input

loop:
        lb $t1, 0($t0)					#get string character
        beq $t1, $t6, break_loop        #break when character is a newline char
	#if statements for different conditions and actions
        beq $t1, $t3, dont_print_invalid_spaces         #if character is_not a space &
        bne $s0, $t3, dont_print_invalid_spaces         #if the previous_character is a space &
        beq $t5, $0, dont_print_invalid_spaces          #if the number_of_previously_seen_characters is not zero &
        beq $t1, $0, dont_print_invalid_spaces          #if the character is_not_null &
       	beq $t1, $t6, dont_print_invalid_spaces         #if the character is_not_new_line then print invalid
        li $v0, 4
        la $a0, not_valid
        syscall	
	
	#print invalid spaces
	li $v0, 10
	syscall
	
	dont_print_invalid_spaces:
        beq $t1, $t3, dont_incr_num_of_characters       #increase number of characters counter if character is not a space
        addi $t5, $t5, 1
	
	dont_incr_num_of_characters:
        bne $t1, $t3, dont_count_space          #if current character is a space and
        bne $t5, $0, dont_count_space           #if num of previous character is equal to 0 then count space
        addi $t7, $t7, 1
	
	dont_count_space:
        move $s0, $t1           #set previous character with current one
        addi $t0, $t0, 1        #incremented the address
        addi $t2, $t2, 1        #incremented i
        j loop
	
	break_loop:
        li $t1, 4
        ble $t5, $t1, dont_print_too_long       #checks if userInput is more than 4
        li $v0, 4
        la $a0, too_long
	syscall					#print too_long_error if char>4
	li $v0, 10
	syscall
	
	dont_print_too_long:
        bne $t5, $zero, dont_print_empty_string_error   #if user input is empty, and
        beq $t1, $t6, dont_print_empty_string_error     #if user input is a newline print invalid
        li $v0, 4
        la $a0, empty_string_error
        syscall
	li $v0, 10
	syscall
	
	dont_print_empty_string_error:
	#reusing registers apart from $t5- len(numofcharacters and $t7- numofspaces in front)
        li $t0, 0						#initialized counter i here
	addi $t1, $t5, -1					#initial j(length-1)
        la $s0, char_array					#gets the string address
        add $s0, $s0, $t7					#gets starting address of the number
        add $s0,$s0, $t1					#subtract -1 from the address(starts from the end)
        li $t4, 1						#power for calculation is 31
	li $t9, 0						#initial sum of decimal value = zero
        li $s3, 31						#constant for base-31
	convert_next_digit_loop:
	li $t8, -1      #initialized the digit to -1
	lb $s1, 0($s0)
	li $t2, 65							#smallest ascii value for capital letters-A
        li $t3, 85							#biggest ascii value for capital letters-U
        blt $s1, $t2, dont_convert_capital_letter_to_digit      #if ascii[j] >= 65 and
        bgt $s1, $t3, dont_convert_capital_letter_to_digit      #if ascii[j] <= 85
	addi $t8, $s1, -55					#got the decimal value of the capital letter
	dont_convert_capital_letter_to_digit:
        li $t2, 97						#smallest ascii value for my lowercase letters-a
        li $t3, 117						#biggest ascii value for my lowercase letters-u
        blt $s1, $t2, dont_convert_lowercase_letter_to_digit    #if ascii[j] >= 85 and
	bgt $s1, $t3, dont_convert_lowercase_letter_to_digit    #if ascii[j] <= 117
        addi $t8, $s1, -87						#got the decimal value of the capital letter
	dont_convert_lowercase_letter_to_digit:
        li $t2, 48							#smallest ascii value for capital letters
        li $t3, 57							#biggest ascii value for capital letters
	blt $s1, $t2, dont_convert_digit_to_digit       #if ascii[j] >= 48 and
        bgt $s1, $t3, dont_convert_digit_to_digit       #if ascii[j] <= 57
        addi $t8, $s1, -48						#got the decimal value of the capital letter
	dont_convert_digit_to_digit:
	li $s4, -1			 			#initialized -1 in $s4
	bne $t8, $s4, dont_print_invalid_symbol 		#if $t8 is -1 then print invalid_spaces
	li $v0, 4
	la $a0, not_valid
	syscall
	li $v0, 10
	syscall
	dont_print_invalid_symbol:
        mul $s2, $t8, $t4					#decimal = digit * power_of_31
        mul $t4, $t4, $s3					#power_of_base *= 31
        add $t9, $t9, $s2					#sum+= decimal
	addi $t0, $t0, 1					#incremented i
        addi $t1, $t1, -1					#decremented j
        addi $s0, $s0, -1					#incremented the address to get the next character
        blt $t0, $t5, convert_next_digit_loop
        li $v0, 1
	move $a0, $t9
        syscall								#prints userInput's decimal equivalent
	li $v0, 10
	syscall
        jr $ra
