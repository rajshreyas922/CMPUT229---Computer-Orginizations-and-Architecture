#
# CMPUT 229 Student Submission License
# Version 1.0
#
# Copyright 2020 <JASPREET KAUR SOHAL>
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
# CCID:      1620817           
# Lecture Section:      
# Instructor:           J. Nelson Amaral
# Lab Section:          
# Teaching Assistant:   
#---------------------------------------------------------------
# 



handlePacket:
	addi sp, sp, -8 #making space in stack for 2 more items
	sw a0, 4(sp)
	sw ra, 8(sp)
	mv a1, a0	#moving contents of a0 in a1
	jal validateIP  #calling function to check whether IP value is 4
	li t0, 1
	bne a0, t0, returnIP #if IP value is not 4, goto returnIP

	lw a0, 4(sp)
	jal validateTTL
	li t0, 1
	bne a0, t0, returnTTL #if not to be forwarded !=4, goto return
	lw a0, 4(sp)
	jal validateChecksum
	li t0, 1
	bne a0, t0, returnChecksum #if not to be forwarded !=4, goto return

	lw a0, 4(sp)
	lw s2, 8(a0)
	addi s2, s2, -1     #else decreasing value of TTL by 1
	sw s2, 8(a0)
	jal checksum
	jal flipHalfwordBytes
	mv t1, a0    #value of new checksum in little endian
	slli t1, t1, 16
	lw a0, 4(sp)
	lw t2, 8(a0)
	slli t2, t2, 16
	srli t2, t2, 16  #lower halfword
	add t1, t1, t2   #new 3rd word of IP packet
	sw t1, 8(a0)
	mv a1, a0
	li a0, 1
	lw ra,8(sp)
	jr ra


validateIP: 
	lw a2, 0(a0)	#loading start address of packet into a2 
	slli a2, a2, 24
	srli a2, a2, 28 #isolating the bit containing the version of IP
	mv a0, a2 
	li a2, 4
	bne a2, a0, doneIP
	li a0, 1     #ip not valid
	jr ra

doneIP:
	li a0, 0
	jr ra

returnIP:   #returns value of a0 and a1 when IP is not 4
	li a0, 0
	li a1, 2
	lw ra,8(sp)
	jr ra


##    if everything is correct this should happen
li a0, 1	    #a0<- 1
lw a1, 4(sp)	    #a1<-the starting address of the IP packet   
jr ra	   #returning to function called from




validateChecksum:
	addi sp, sp, -4
	sw ra, 0(sp)
	lw a0, 8(a0)
	srli a0, a0, 16   #isolating the upper halfword from lower
	jal flipHalfwordBytes
	mv a3, a0
	lw a0, 8(sp)
	addi sp, sp, -4
	sw a3, 0(sp) #store a3 in stack to save value
	jal checksum
	lw a3, 0(sp)
	addi sp, sp, 4
	bne a3, a0, doneChecksum
	li a0, 1
	lw ra, 0(sp)
	addi sp, sp, 4
	jr ra


doneChecksum:
	li a0, 0
	lw ra, 0(sp)
	addi sp, sp, 4
	jr ra


returnChecksum:   #returns value of a0 and a1 when IP is not 4
	li a0, 0
	li a1, 0
	lw ra,8(sp)
	jr ra


validateTTL:
	lw a0, 4(sp)
	lw s2, 8(a0)
	slli s2, s2, 24  #isolating byte containing TTL value
	srli s2, s2, 24
	mv a0, s2
	blt t0, a0, doneTTL
	li a0, 0
	li a1, 1
	jr ra	#return to function called from

doneTTL:
	li a0, 1
	jr ra
	
returnTTL:   #returns value of a0 and a1 when IP is not 4
	li a0, 0
	li a1, 1
	lw ra,8(sp)
	jr ra
