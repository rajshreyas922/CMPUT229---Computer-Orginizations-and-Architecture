#------------------------------------------------------------------------------
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
#------------------------------------------------------------------------------
# SIRD-Model lab student solution
#
# Lab:             Lab 5
# Author:          <Student_Name>
# Due Date:        <Date>
# Unix ID:         <CCID>
# Lecture Section: <>
# Instructor:      <>
# Lab Section:     <>
# TA:              <>
#------------------------------------------------------------------------------

.include "common.s"


#----------------------------------
#        STUDENT SOLUTION
#----------------------------------


.data
.align 2
DISPLAY_CONTROL:	.word 0xFFFF0008
DISPLAY_DATA:		.word 0xFFFF000C
String:			.asciz "Person "
String1:			.asciz " - "
INTERRUPT_ERROR:	.asciz "Error: Unhandled interrupt with exception code: "
INSTRUCTION_ERROR:	.asciz "\n   Originating from the instruction at address: "
POPULATION: .asciz "SSSSSSSSSS"
TIMERS: .byte 0,0,0,0,0,0,0,0,0
SPACE: .byte 0,0
InSTRING: .asciz ""
SPACE1: .byte 0,0
FOURTEEN: .asciz "14"
THIRTEEN: .asciz "13"
TWELVE: .asciz "12"
ELEVEN: .asciz "11"
TEN: .asciz "10"




.text
#------------------------------------------------------------------------------
# sird
#
# A sample function template is provided. Students may build off  of this or 
# rewrite it as they see fit.
#------------------------------------------------------------------------------
sird:
	addi sp, sp, -4
	sw ra, 0(sp)
	la t4, handler
	csrw t4, 5
	li t0, 0x10010000
	csrw t0, 0x040
	li t3, 0x110
	csrrw zero, 4, t3 #Uie
	csrrwi zero, 0, 0x1 #ustatus
	li t1, 0xffff0000
	li t2, 0x10
	sb t2, 0(t1)
	jal printCurrentState
	
	
	
 	
 Lo1: 	la t0, iTrapData
	csrw t0, 0x040
	csrrwi zero, 0, 0x1 #ustatus
	li t1, 0xffff0000
	li t2, 0x10
	sb t2, 0(t1)

 	la t0, InSTRING
 	lb t0, 0(t0)
 	li t1, 0x71
 	beq t0, t1, sirdDone
 	jal Lo1 #Forever loop

	# 	End of program
sirdDone:	
	lw ra, 0(sp)
	addi sp, sp, 4
	jr 		ra

#Prints the initial status of people
printCurrentState:
	addi sp, sp, -4
	sw ra, 0(sp)
	li t1, 0x30 #t1 <- "0" (Will be used for printing and indexing)
L1:	li t3, 0x39
   	bgt t1, t3, Terminate #If i > 9, goto Terminate
	la    t0, String
    	mv    a0, t0       # a0 <- strAddr
   	addi t3, t1, -0x30 #Convert to integer
   	mv a1, t3 #a1 <- row = i
   	li    a2, 0 # a2 <- col = 0
   	
   	addi sp, sp, -4
	sw t1, 0(sp) #Store t variable before calling function
   	jal   printStr #Prints "Person "
   	lw t1, 0(sp) #Restore t1
   	addi sp, sp, 4
   	
   	
   	
   	mv a0, t1 #a0 <- "0"
   	addi t3, t1, -0x30 #Convert to integer
   	mv a1, t3 #a1 <- row = i
   	li a2, 7 #a2 <- 7 (This is constant since we are printing "Person" in every line)
   	
   	addi sp, sp, -4
	sw t1, 0(sp) #Store t variable before calling function
   	jal printChar #Prints the value of i
   	lw t1, 0(sp)#Restore t1
   	addi sp, sp, 4
   	
   	la t0, String1 #t0 stores address of " - "
   	mv a0, t0
   	addi t3, t1, -0x30
   	mv a1, t3
   	li a2, 8
   	addi sp, sp, -4
	sw t1, 0(sp) #Store t variable before calling function
	jal printStr
	lw t1, 0(sp)#Restore t1
   	addi sp, sp, 4
   	
   	
   	
   	la t0, POPULATION #t0 <- address of POPULATION
   	addi a1, t1, -0x30
   	mv a0, a1
   	jal getStatus #a0 <- get status of person i (a1)
   	li a2, 11
   	addi sp, sp, -4
	sw t1, 0(sp) #Store t variable before calling function
   	jal printChar #Print corresponding state of i
   	lw t1, 0(sp)#Restore t1
   	addi sp, sp, 4
   	
   	la t0, TIMERS
   	addi t2, t1, -0x30
   	add t0, t0, t2
   	lb t3, 0(t0)
   	ble t3, zero, Remove
   	li t4, 10
   	bge t3, t4, Special
   	
   	li a0, 0x30
   	mv a1, t2
   	li a2, 13
   	addi sp, sp, -4
	sw t1, 0(sp) #Store t variable before calling function
   	jal printChar
   	lw t1, 0(sp)#Restore t1
   	addi sp, sp, 4
   	
   	li a0, 0x3a
   	mv a1, t2
   	li a2, 12
   	addi sp, sp, -4
	sw t1, 0(sp) #Store t variable before calling function
   	jal printChar
   	lw t1, 0(sp)#Restore t1
   	addi sp, sp, 4
   	

	addi t3, t3, 0x30
   	mv a0, t3
   	mv a1, t2
   	li a2, 14
   	addi sp, sp, -4
	sw t1, 0(sp) #Store t variable before calling function
   	jal printChar
   	lw t1, 0(sp)#Restore t1
   	addi sp, sp, 4
   	jal Cont.
Special:
	mv a0, t3
	li a1, 0x0a
	beq a0, a1, StoreZero
	addi a1, a1, 1
	beq a0, a1, StoreOne
	addi a1, a1, 1
	beq a0, a1, StoreTwo
	addi a1, a1, 1
	beq a0, a1, StoreThree
	addi a1, a1, 1
	beq a0, a1, StoreFour
StoreFour:
	la a0, FOURTEEN #(CHange to 14)
	jal PrintIt
StoreThree:
	la a0, THIRTEEN #(CHange to 14)
	jal PrintIt
StoreTwo:
	la a0, TWELVE #(CHange to 14)
	jal PrintIt
StoreOne:
	la a0, ELEVEN #(CHange to 14)
	jal PrintIt
StoreZero:
	la a0, TEN #(CHange to 14)
	jal PrintIt
PrintIt:	
	mv t5, a0
	li a0, 0x3a
   	mv a1, t2
   	li a2, 12
   	addi sp, sp, -4
	sw t1, 0(sp) #Store t variable before calling function
   	jal printChar
   	lw t1, 0(sp)#Restore t1
   	addi sp, sp, 4
   	mv a0, t5
	mv a1, t2
	li a2, 13
	addi sp, sp, -4
	sw t1, 0(sp) #Store t variable before calling function
   	jal printStr
   	lw t1, 0(sp)#Restore t1
   	addi sp, sp, 4
	jal Cont.
	
	
Cont.:	
	
	addi t1, t1, 1
   	li t3, 0x39
   	bgt t1, t3, Terminate #If i > 9, goto Terminate
   	jal L1
   	
Remove: 	
	li a0, 0x20
   	mv a1, t2
   	li a2, 12
   	addi sp, sp, -4
	sw t1, 0(sp) #Store t variable before calling function
   	jal printChar
   	lw t1, 0(sp)#Restore t1
   	addi sp, sp, 4

	li a0, 0x20
   	mv a1, t2
   	li a2, 13
   	addi sp, sp, -4
	sw t1, 0(sp) #Store t variable before calling function
   	jal printChar
   	lw t1, 0(sp)#Restore t1
   	addi sp, sp, 4
   	
   	li a0, 0x20
   	mv a1, t2
   	li a2, 14
   	addi sp, sp, -4
	sw t1, 0(sp) #Store t variable before calling function
   	jal printChar
   	lw t1, 0(sp)#Restore t1
   	addi sp, sp, 4
   	jal Cont.
Terminate:
	lw ra, 0(sp)
	addi sp, sp, 4
   	jr ra
	
random:
	addi sp, sp, -4 # Create space for storing ra
	sw ra, 0(sp) # Store ra in stack
	la t0, XiVar # t0 <- address of X_i-1
	lw t1, XiVar # t1 <- X_i-1
	lw t2, aVar # t2 <- a
	lw t3, cVar # t3 <- c
	lw t4, mVar # t4 <- m
	mul t1, t1, t2 # t1 <- a*(X_i-1)
	add t1, t1, t3 # t1 <- a*(X_i-1) + c
	rem t1, t1, t4 # t1 <- (a*(X_i-1) + c) mod m
	mv a0, t1 # a0 <- t1
	sw t1, 0(t0) # Store current Xi in XiVar
	lw ra, 0(sp) #Restore ra
	addi sp, sp, 4
	jr ra #Return
setStatus:
	addi sp, sp, -4
	sw ra, 0(sp)
	la t0, POPULATION #t0 <- starting address of array
	add t0, t0, a0 #t0 <- t0 + i
   	sb a1, 0(t0) #0(t0) <- a1
   	lw ra, 0(sp) #Restore ra
   	addi sp, sp, 4
   	jr ra
getStatus:
	addi sp, sp, -4
	sw ra, 0(sp)
	la t0, POPULATION #t0 <- starting address of array
	add t0, t0, a0 #t0 <- t0 + i
	lb a0, 0(t0) #t0 <- 0(t0)
	lw ra, 0(sp) #Restore ra
   	addi sp, sp, 4
   	jr ra

#------------------------------------------------------------------------------
# printStr
# Args:
# 	a0: strAddr - The address of the null-terminated string to be printed.
# 	a1: row - The row to print on.
# 	a2: col - The column to start printing on.
#
# Prints a string in the Keyboard and Display MMIO Simulator terminal at the
# given row and column.
#------------------------------------------------------------------------------
printStr:
	# Stack
	addi	sp, sp, -16
	sw	ra, 0(sp)
	sw	s0, 4(sp)
	sw	s1, 8(sp)
	sw	s2, 12(sp)
	
	mv	s0, a0
	mv	s1, a1
	mv	s2, a2
	printStrLoop:
		# Check for null-character
		lb	t0, 0(s0)	# t0 <- char = str[i]
		# Loop while(str[i] != '\0')
		beq	t0, zero, printStrLoopEnd
		
		# Print character
		mv	a0, t0		# a0 <- char
		mv	a1, s1		# a1 <- row
		mv	a2, s2		# a2 <- col
		jal	printChar
		
		addi	s0, s0, 1	# i++
		addi	s2, s2, 1	# col++
		j	printStrLoop
	printStrLoopEnd:
	
	# Unstack
	lw	ra, 0(sp)
	lw	s0, 4(sp)
	lw	s1, 8(sp)
	lw	s2, 12(sp)
	addi	sp, sp, 16
	jalr	zero, ra, 0

	
#------------------------------------------------------------------------------
# printChar
# Args:
#	a0: char - The character to print
#	a1: row - The row to print the given character
#	a2: col - The column to print the given character
#
# Prints a single character to the Keyboard and Display MMIO Simulator terminal
# at the given row and column.
#------------------------------------------------------------------------------
printChar:
	# Stack
	addi	sp, sp, -16
	sw	ra, 0(sp)
	sw	s0, 4(sp)
	sw	s1, 8(sp)
	sw	s2, 12(sp)
	
	# Save parameters
	add	s0, a0, zero
	add	s1, a1, zero
	add	s2, a2, zero
	
	jal	waitForDisplayReady	# Wait for display before printing
	
	# Load bell and position into a register

	addi	t0, zero, 7	# Bell ascii
	slli	s1, s1, 8	# Shift row into position
	slli	s2, s2, 20	# Shift col into position
	or	t0, t0, s1
	or	t0, t0, s2	# Combine ascii, row, & col
	
	# Move cursor
	lw	t1, DISPLAY_DATA
	sw	t0, 0(t1)
	
	jal	waitForDisplayReady	# Wait for display before printing
	
	# Print char
	lw	t0, DISPLAY_DATA
	sw	s0, 0(t0)
	
	# Unstack
	lw	ra, 0(sp)
	lw	s0, 4(sp)
	lw	s1, 8(sp)
	lw	s2, 12(sp)
	addi	sp, sp, 16
	jalr    zero, ra, 0
	
	
#------------------------------------------------------------------------------
# waitForDisplayReady
#
# A method that will check if the Keyboard and Display MMIO Simulator terminal
# can be writen to, busy-waiting until it can.
#------------------------------------------------------------------------------
waitForDisplayReady:
	# Loop while display ready bit is zero
	lw	t0, DISPLAY_CONTROL
	lw	t0, 0(t0)
	andi	t0, t0, 1
	beq	t0, zero, waitForDisplayReady
	
	jalr    zero, ra, 0
	

#------------------------------------------------------------------------------
# handler
#
# handlerTerminate is run when the interrupt/exception is unhandled by the
# student handler, terminating the program and providing debuging messages.
#------------------------------------------------------------------------------

handler:
	
	#--------------------
	#   STUDENT HANDLER
	#--------------------
	li t0, 0x10010000
	csrw t0, 0x040
	csrrw a0, 0x040, a0
	sw      t0, 0(a0)         # save PROGRAMt0
    	sw      t1, 4(a0)         # save PROGRAMs0
    	sw      t2, 8(a0) 
    	sw      t3, 12(a0) 
	sw      t4, 16(a0) 
	sw      t5, 20(a0) 
	sw      t6, 24(a0) 
	sw      s1, 28(a0) 
	sw      s2, 32(a0) 
	sw      s3, 36(a0) 
	sw      a1, 40(a0) 
	csrrw t0, 0x040, t0 	# t0 <- PROGRAMa0
    	sw      t0, 44(a0)         # save PROGRAMa0
    	mv s4, a0

	la s0, InSTRING
	li s1, 0xffff0004
	li s2, 0xffff0000
	la s3, TIMERS
	li t0, 0x80000008
	csrr t1, 66
	beq t0, t1, Load
#Decreases the timer, and assigns the times in the array, and decided whether to giv R or D
UpdateTimer:
	jal random
	li t2, 0
	mv t4, a0
Iter1:	
	li t6, 9
	bgt t2, t6, DoneIter1
	lb t0, 0(s3)
	bgt t0, zero, Decrement
	addi s3, s3, 1
	addi t2, t2, 1
	jal Iter1
DoneIter1:
	li t1, 0xFFFF0020
	lw t0, 0xFFFF0018
	addi t0, t0, 1000
	sw t0, 0(t1)
	jal printCurrentState
	jal handlerDone
#Subtracts one from all positive integers in the TIMER array
Decrement:
	addi t0, t0, -0x01
	sb t0, 0(s3)
	bne t0, zero, Nothing
	li t5, 500
	blt t4, t5, Recover
	mv a0, t2
	li a1, 0x44
	jal setStatus
	jal printCurrentState
	jal Nothing
Recover:
	mv a0, t2
	li a1, 0x52
	jal setStatus
	jal printCurrentState
Nothing:
	addi s3, s3, 1
	addi t2, t2, 1
	jal Iter1

	
Load:	
	lb t0, 0(s1)
	li t1, 0x0a
	lb t2, 0(s2)
	beq t0, t1, doneString
	sb t0, 0(s0)
	addi s0, s0, 1
	
L3:	lb t2, 0(s2)
	andi t2, t2, 0x01
	beq t2, zero, L3
	jal Load
	
doneString:
	sb t1, 0(s0)
	la s0, InSTRING
	lb a0, 0(s0) 
#String Iterator
	addi s0, s0, 1
	lb t4, 0(s0)
	li t1, 0x5e
	beq t4, t1, Contact
	li t1, 0x21
	beq t4, t1, Infect
	li t1, 0x63
	beq a0, t1, Reset
	li t1, 0x71
 	beq a0, t1, End
#Decides how contact between two people should be handled
Contact:
	la s0, InSTRING
	li t3, 0
	li t4, 0
	lb t0, 0(s0)
	lb t1, 2(s0)
	addi t0, t0, -0x30
	addi t1, t1, -0x30
	mv a0, t0
	jal getStatus
	li t0, 0x53
	bne a0, t0, Next
	jal Flag1
Next:	lb t1, 2(s0)
	addi t1, t1, -0x30
	mv a0, t1
	jal getStatus
	li t0, 0x53
	bne a0, t0, Next1
	jal Flag2
Next1:	xor t5, t3, t4
	beq t5, zero, End
	addi s4, s4, -8
	sw t3, 0(s4)
	sw t4, 4(s4)
	jal random
	lw t3, 0(s4)
	lw t4, 4(s4)
	addi s4, s4, 8
	li t0, 500
	blt a0, t0, End
	bne t3, zero, InfectCurr
	lb a0, 2(s0) ################
	jal Infect
InfectCurr:
	lb a0, 0(s0) ##################
	jal Infect

End:
	csrrwi zero, 0, 0x1 #ustatus
	li t1, 0xffff0000
	li t2, 0x10
	sb t2, 0(t1)
	jal handlerDone

Flag1:
	addi s4, s4, -4
	sw ra, 0(s4)
	li t3, 1
	lw ra, 0(s4)
	addi s4, s4, 4
	jr ra
Flag2:
	addi s4, s4, -4
	sw ra, 0(s4)
	li t4, 1
	lw ra, 0(s4)
	addi s4, s4, 4
	jr ra

Reset:
	li s0, 0
Iter:	mv a0, s0
	jal getStatus
	li t1, 0x53
	beq a0, t1, dontHeal
#Heal
	mv a0, s0
	li a1, 0x53
	jal setStatus
dontHeal:	addi s0, s0, 1
	li t0, 9
	bgt s0, t0, EndR
	jal Iter
	
EndR:	csrrwi zero, 0, 0x1 #ustatus
	li t1, 0xffff0000
	li t2, 0x10
	sb t2, 0(t1)
	lw ra, 0(sp)
	jal printCurrentState
	jal handlerDone
	
Infect:
	addi a0, a0, -0x30
	add t0, a0, s3
	li t1, 14
	sb t1, 0(t0)
	li a1, 0x49
	jal setStatus
	jal printCurrentState
	
	li t1, 0xFFFF0020
	lw t0, 0xFFFF0018
	addi t0, t0, 1000
	sw t0, 0(t1)
	
	jal handlerDone
	

	# 	Terminate program if the interrupt/exception is unhandled
handlerTerminate:
	# 	Print error msg before terminating
	li	a7, 4
	la	a0, INTERRUPT_ERROR
	ecall
	li	a7, 34
	csrrci	a0, 66, 0
	ecall
	li	a7, 4
	la	a0, INSTRUCTION_ERROR	
	ecall
	li	a7, 34
	csrrci	a0, 65, 0
	ecall
	#	Quit execution
handlerQuit:
	li	a7, 10
	ecall		# End of program

handlerDone:	
	# 	Unstack used registers then return control back to the program
	lw      t0, 0(s4)        
    	lw      t1, 4(s4)       
    	lw      t2, 8(s4) 
    	lw      t3, 12(s4) 
	lw      t4, 16(s4) 
	lw      t5, 20(s4) 
	lw      t6, 24(s4) 
	lw      s1, 28(s4) 
	lw      s2, 32(s4) 
	lw      s3, 36(s4)
	lw      a1, 40(s4)       
    	lw      a0, 44(s4)
   
	uret
