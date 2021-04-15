#
# CMPUT 229 Student Submission License
# Version 1.0
#
# Copyright 2020 Raj Shreyas Penukonda
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

#.include "common.s"

#----------------------------------
#        STUDENT SOLUTION
#----------------------------------

checksum:
	addi sp, sp, -8
	sw ra, 0(sp) #Store ra into stack
	sw a0, 4(sp) #store argument into stack
	lw t0, 8(a0) #Get the number that contains the Header Checksum
	mv s4, a0
	mv s5, t0
	#Set header check sum to zero
	slli t0, t0, 16
	srli t0, t0, 16 
	sw t0, 8(a0) #Replace the Header checksum with 0x0000
	jal getHeaderLength
	mv t1, a0 #t1 <- Header length
	li t2, 0 #i <- 0
	li t6, 0 #t6 will store the checksum (Accumulator)
#Loop to calculate checksum
L1:
	beq t1, t2, endLoop #if i == 2*HeaderLength, goto endLoop
	lw t0, 4(sp) #t0 <- original argument of checksum
	lw a0, 0(t0) #Get the word stored at the t0
	slli a0, a0, 16
	srli a0, a0, 16 #a0 <- lower halfword
	
	addi sp, sp, -4
	sw t1, 0(sp) #Store t1 in stack in case it gets changed
	jal flipHalfwordBytes
	lw t1, 0(sp)
	addi sp, sp, 4
	mv t3, a0 #t3 <- flipped lower halfword

	lw t0, 4(sp) #t0 <- original argument of checksum
	lw a0, 0(t0) #a0 <- word stored at the t0
	srli a0, a0, 16 #a0 <- upper halfword
	
	addi sp, sp, -4
	sw t1, 0(sp) #Store t1 in stack in case it gets changed
	jal flipHalfwordBytes
	lw t1, 0(sp)
	addi sp, sp, 4
	mv t4, a0 #t3 <- flipped upper halfword
	
	add t5, t3, t4 #t5 <- flipped lower halfword + flipped upper halfword
	srli t3, t5, 16 #t3 <- CarryOut
	add t5, t3, t5 #t5 <- lower 2 bytes of sum + Carryout
	slli t5, t5, 16 #Making sure only the lower halfword is stored
	srli t5, t5, 16 #Making sure only the lower halfword is stored
	
	add t6, t6, t5 # t6 (Accumulator) <- Accumulator + (flipped lower halfword + flipped upper halfword)
	srli t4, t6, 16 # t4 <- Carry
	add t6, t4, t6 # t6 <- Carry + Accumulator
	slli t6, t6, 16 #Making sure only the lower halfword is stored
	srli t6, t6, 16 #Making sure only the lower halfword is stored
	
	addi t2, t2, 1 # i += 1
	lw t0, 4(sp) #Retrieve the address from stack
	addi t0, t0, 4 #Increment address by 4 to go to next word
	sw t0, 4(sp) #Replace the old address
	jal L1
endLoop:
	sw s5, 8(s4)
	mv a0, t6 #Store final sum into return varaible
	li t3, 0xffff
	xor a0, a0, t3 #Take the logical complement
	lw ra, 0(sp) #Restor return address
	addi sp, sp, 8
	jr ra #Return check sum

flipHalfwordBytes:
	mv t0, a0
	slli t0, t0, 24
	srli t0, t0, 16 #t0 <- the lower byte
	srli t1, a0, 8 #t1 <- the upper shifted to the left
	add a0, t0, t1 #a0 <- the lower byte + the upper shifted to the left
	jalr zero, ra, 0
	
getHeaderLength:
	lw t0, 0(a0) #Get the word storing the header length
	andi a0, t0, 0xF #a0 <- header length
	jalr zero, ra, 0
