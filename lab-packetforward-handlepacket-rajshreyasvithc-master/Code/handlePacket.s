#
# CMPUT 229 Student Submission License
# Version 1.0
#
# Copyright 2020 <student name>
#
# Redistribution is forbidden in all circumstances. Use of this
# software without explicit authorization from the author or CMPUT 229
# Teaching Staff is prohibited.
#
# This software was produced as a solution for an assignment in the course
# CMPUT 229 - Computer Organization and Architecture I at the University of
# Alberta, Canada. This solution is confidential and remains confidential 
# after it is submitted for grading.
#
# Copying any part of this solution without including this copyright notice
# is illegal.
#
# If any portion of this software is included in a solution submitted for
# grading at an educational institution, the submitter will be subject to
# the sanctions for plagiarism at that institution.
#
# If this software is found in any public website or public repository, the
# person finding it is kindly requested to immediately report, including 
# the URL or other repository locating information, to the following email
# address:
#
#          cmput229@ualberta.ca
#
#---------------------------------------------------------------
# CCID:		penukond              
# Lecture Section:	LEC A1    
# Instructor:	J. Nelson Amaral
# Lab Section:	LAB D06
# Teaching Assistant:	Noah Gergel
#---------------------------------------------------------------
# 

#-------------------start of common file-----------------------------------------------

#----------------------------------
#        STUDENT SOLUTION
#----------------------------------

#-------------------start of common file-----------------------------------------------

.include "common.s"
.include "checksum.s"
#----------------------------------
#        STUDENT SOLUTION
#----------------------------------

#Main function
handlePacket:
	#Storing ra, s registers and the arg into stack
	addi sp, sp, -16
	sw ra, 12(sp)
	sw s1, 8(sp)
	sw s0, 4(sp)
	sw a0, 0(sp)
	li s0, 2 #s0 <- initial return value of a1 if invalid IP
	jal validateIP
	beq a0, zero, Invalid #If validateIP returns 0, goto Invalid
	addi s0, s0, -1 #Decrement s0 since it has valid IP
	lw a0, 0(sp) #a0 <- Starting address of IP
	jal validateTTL
	beq a0, zero, Invalid #If validateTTL returns 0, goto Invalid
	addi s0, s0, -1 #Decrement s0 since it has valid TTL
	lw a0, 0(sp) #a0 <- Starting address of IP
	jal validateChecksum
	beq a0, zero, Invalid #If validateChecksum returns 0, goto Invalid
	jal Valid #If IP passes all the tests above, it will considered a valid IP and is ready
		  #to be forwarded
Invalid:
	mv a0, zero #a0 <- 0
	mv a1, s0 #a1 <- s0 (reason for invalid IP)
	lw s0, 4(sp) #Restore saved register
	lw s1, 8(sp) #Restore saved register
	lw ra, 12(sp) #Restore ra
	addi sp, sp, 16
	jr ra #Return
	
Valid:
	lw a1, 0(sp) #a1 <- starting address of IP from stack
	lw t0, 8(a1) #Get the word that has the TTL
	addi t0, t0, -1 #Decrement TTL
	sw t0, 8(a1) #Replace the TLL
	mv a0, a1 #Prepare a0 for calling checksum
	jal checksum #Calculate checksum
	jal flipHalfwordBytes #Convert to little endian
	lw t0, 8(a1) #Get the word containing header checksum
	slli t0, t0, 16 #t0 << 16
	srli t0, t0, 16 #t0 >> 16
	slli a0, a0, 16 #a0 << 16
	add t0, t0, a0 #t0 = t0 + a0
	sw t0, 8(a1) #Store new word in memory
	li a0, 0x001 #a0 <- 1
	lw s0, 4(sp) #Restore the saved registers
	lw s1, 8(sp) #Restore the saved registers
	lw ra, 12(sp) #Restore ra
	addi sp, sp, 16
	jr ra #Return
#Checks if IP is 4
validateIP:
	addi sp, sp, -4 
	sw ra, 0(sp) #Saving ra
	lw t0, 0(a0) #t0 <- Starting address of IP
	srli t0, t0, 4
	andi t0, t0, 0x00F #t0 <- IP
	li t1, 4 
	beq t0, t1, validIP #If IP = 4, goto validIP
	li a0, 0 #Else a0 <- 0
	addi sp, sp, 4
	jr ra #Return
validIP:
	lw ra, 0(sp) #Restore ra
	addi sp, sp, 4
	li a0, 1 #a0 <- 1
	jr ra #Return
#Checks if TTL is greater than 1
validateTTL:
	addi sp, sp, -4
	sw ra, 0(sp) #Saving ra
	lw t0, 8(a0) #Load the word that contains the TTL
	andi t0, t0, 0x0FF #t0 <- TTL
	li t1, 1
	ble t0, t1, InvalidTTL #If TTL <= 1, goto Failed
	li a0, 1 #Else a0 <- 1
	addi sp, sp, 4
	jr ra #Return
	
InvalidTTL:
	lw ra, 0(sp) #Restore ra
	addi sp, sp, 4
	li a0, 0 #a0 <- 0
	jr ra #Return
	
#Checks for correct CheckSum
validateChecksum:
	addi sp, sp, -8
	sw ra, 4(sp) #Store ra into stack
	sw a0, 0(sp) #Prepare a0 for calling checksum
	jal checksum #Call checksum
	mv s1, a0 #s1 <- calculated checksum
	lw a0, 0(sp) #Restore the starting address
	lw a0, 8(a0) #Get the word containing the header checksum
	srli a0, a0, 16 #Get the checksum
	jal flipHalfwordBytes #Convert to big endian
	beq s1, a0, validChecksum #if(calculated checksum = header checksum), go to Pass1
	li a0, 0 #Else a0 <- 0
	lw ra, 4(sp) #Restore ra
	addi sp, sp, 8
	jr ra #Return
	
validChecksum:
	li a0, 1 #a0 <- 1
	lw ra, 4(sp) #restore ra
	addi sp, sp, 8
	jr ra #Return



