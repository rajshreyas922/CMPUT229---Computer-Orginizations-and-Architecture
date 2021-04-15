#
# CMPUT 229 Student Submission License
# Version 1.0
# Copyright 2019 Raj Shreyas Penukonda
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
# CCID:                 1623713
# Lecture Section:      <    >
# Instructor:           <    >
# Lab Section:          <    >
# Teaching Assistant:   <    >
#---------------------------------------------------------------
# 

.include "common.s"
.data
Table: .space 8000

.text
RISCVtoWASM:
	addi sp, sp, -28
	sw a0, 0(sp) #Saving the address of RISCV Instr.
	sw a1, 4(sp) #Saving address of where to store WASM Instr.
	sw ra, 8(sp)
	sw s0, 12(sp)
	sw s1, 16(sp)
	sw s2, 20(sp)
	sw s3, 24(sp)
	li s3, 0
	mv t6, a0 #t6 <-- RISCV Instrs
	jal generateTargetTable


L1:		
	mv a0, t6 #a0 <-- Original address of RISCV Instr.
	lw a1, 0(sp) #Address of current Instr.
	li a2, 1 #Check if it is a target of forward branch
	jal readTargetCount
	add s3, s3, a0
	beq a0, zero, Bw #If BwCount is zero, go to Bw
	
	li t0, 0
	lw a1, 4(sp)# take current pointer to WASM Instructions
	
L2:	
	bge t0, a0, DoneL2 #If t0 < FwCount, DoneL2
	li t1, 0x0B
	sb t1, 0(a1) #Write END
	addi t0, t0, 1 #Increment iterator
	addi a1, a1, 1 #point to next place in WASM Instructions
	jal L2
DoneL2: 	sw a1, 4(sp)	
Bw:	
	mv a0, t6 #a0 <-- Original address of RISCV Instr.
	lw a1, 0(sp) #Address of current Instr.
	li a2, 0 #Check if it is a target of backward branch
	jal readTargetCount
	slli t0, a0, 1
	add s3, s3, t0
	beq a0, zero, Cont.L1 #If FwCount is zero, continue
	
	li t0, 0
	lw a1, 4(sp)# take current pointer to WASM Instructions
L3:	
	bge t0, a0, DoneL3 #If t0 >= FwCount, DoneL2
	li t1, 0x03
	sb t1, 0(a1) #Write LOOP
	addi a1, a1, 1 #point to next place in WASM Instructions
	li t1, 0x40
	sb t1, 0(a1) #Write VOID
	addi t0, t0, 1 #Increment iterator
	addi a1, a1, 1 #point to next place in WASM Instructions
	jal L3

	
	
DoneL3:	sw a1, 4(sp)
		
Cont.L1:	lw a0, 0(sp)  #Restoring the address of RISCV Instr.
	lw s0, 0(a0) #s0 <-- Getting the instruction
	andi t0, s0, 0x07F
	li t1, 0x33
	beq t0, t1, RType
	li t1, 0x13
	beq t0, t1, IType
	li t1, 0x63
	beq t0, t1, BrType

	
Back:	
	lw a0, 0(sp)
	addi a0, a0, 4
	sw  a0, 0(sp) #Saving the address of RISCV Instr.
	li t0, 0xFFFFFFFF
	beq t0, s0, DoneF
	jal L1
#When the sentinel Value is found the program ends
DoneF:
	lw a1, 4(sp)
	li t0, 0x20 #set_local
	sb t0, 0(a1)
	addi a1, a1, 1

	li t0, 0x00 #00
	sb t0, 0(a1)
	addi a1, a1, 1

	li t0, 0x0F #return
	sb t0, 0(a1)
	addi a1, a1, 1

	li t0, 0x0B #end
	sb t0, 0(a1)
	addi a1, a1, 1

	addi s3, s3, 4
	mv a0, s3 #Return total number of bytes
	#Restoring all s registers and ra value
	sw a1, 4(sp)
	lw ra, 8(sp)
	lw s0, 12(sp)
	lw s1, 16(sp)
	lw s2, 20(sp)
	lw s3, 24(sp)
	addi sp, sp, 28
	jr ra
#IType:
#Following set of lines assign the the values to a0, a1, a2 for calling the translateIType Function according this criteria:
#a0: Address to write instruction representation translated into WASM.
#a1: Address of the RISC-V instruction to parse.
#a2: 0x6A if addi, 0x71 if andi, 0x72 if ori, 0x75 if srai, 0x76 if srli
IType:
	lw a0, 4(sp)
	lw a1, 0(sp)
	li t0, 0x7000
	and t0, s0, t0
	srli t0, t0, 12 #Using mask to get func3, then comparing to constants to see which op it is
	li t1, 0x07
	beq t0, t1, ANDI
	li t1, 0x06
	beq t0, t1, ORI
	li t1, 0x00
	beq t0, t1, ADDI
	li t1, 0x05
	beq t0, t1, SRLI
	li t1, 0x01
	beq t0, t1, SLLI
ADDI:
	li a2, 0x6A
	jal translateIType
	add s3, s3, a0 #Adding the bytes added to total bytes written by this program
	lw a1, 4(sp)
	add a1, a0, a1 #Adding the bytes added to the address that will be written to next
	sw a1, 4(sp) #Updating the address
	jal Back
#All of the following are done similarly.
ANDI:
	li a2, 0x71
	jal translateIType
	add s3, s3, a0
	lw a1, 4(sp)
	add a1, a0, a1
	sw a1, 4(sp)
	jal Back
ORI:
	li a2, 0x72
	jal translateIType
	add s3, s3, a0
	lw a1, 4(sp)
	add a1, a0, a1
	sw a1, 4(sp)
	jal Back
#Here we check if the func3 is for slri or srai and assign a2 accordingly
SRAI:
	li t0, 0xF0000000
	and t0, s0, t0
	beq t0, zero, SRLI
	li a2, 0x75
	jal translateIType
	add s3, s3, a0
	lw a1, 4(sp)
	add a1, a0, a1
	sw a1, 4(sp)
	jal Back
SRLI:
	li a2, 0x76
	jal translateIType
	add s3, s3, a0
	lw a1, 4(sp)
	add a1, a0, a1
	sw a1, 4(sp)
	jal Back
SLLI:
	li a2, 0x74
	jal translateIType
	add s3, s3, a0
	lw a1, 4(sp)
	add a1, a0, a1
	sw a1, 4(sp)
	jal Back
#BRType:
#Following set of lines assign the the values to a0, a1, a2 for calling the translateBranch Function according this criteria:
#a0: Address to write instruction representation translated into WASM.
#a1: Address of the RISC-V instruction to parse.
#a2: 0x4E if bge, 0x46 if beq

BrType:
	lw a0, 4(sp)
	lw a1, 0(sp)
	li t0, 0x7000
	and t0, s0, t0
	srli t0, t0, 12
	beq t0, zero, BEQ #Checking func3
	
BGE:	li a2, 0x4E
	jal translateBranch
	add s3, s3, a0
	lw a1, 4(sp)
	add a1, a0, a1
	sw a1, 4(sp)
	jal Back
BEQ:
	li a2, 0x46
	jal translateBranch
	add s3, s3, a0
	lw a1, 4(sp)
	add a1, a0, a1
	sw a1, 4(sp)
	jal Back	
#RType:
#Following set of lines assign the the values to a0, a1, a2 for calling the translateRType Function according this criteria:
#a0: Address to write instruction representation translated into WASM.
#a1: Address of the RISC-V instruction to parse.
#a2: 0x6A if add, 0x6B if sub, 0x71 if and, 0x72 if or, 0x75 if sra, 0x76 if srl
RType:
	lw a0, 4(sp)
	lw a1, 0(sp)
	li t0, 0x7000
	and t0, s0, t0
	srli t0, t0, 12
	li t1, 0x07
	beq t0, t1, AND
	li t1, 0x06
	beq t0, t1, OR
	li t1, 0x00
	beq t0, t1, ADDorSUB
	li t1, 0x05
	beq t0, t1, SRL
	li t1, 0x01
	beq t0, t1, SLL
AND:
	li a2, 0x71
	jal translateRType
	add s3, s3, a0
	lw a1, 4(sp)
	add a1, a0, a1
	sw a1, 4(sp)
	jal Back
OR:
	li a2, 0x72
	jal translateRType
	add s3, s3, a0
	lw a1, 4(sp)
	add a1, a0, a1
	sw a1, 4(sp)
	jal Back
	
ADDorSUB:
	li t0, 0xF0000000
	and t0, s0, t0
	beq t0, zero, ADD
	li a2, 0x6B
	jal translateRType
	add s3, s3, a0
	lw a1, 4(sp)
	add a1, a0, a1
	sw a1, 4(sp)
	jal Back
ADD:
	li a2, 0x6A
	jal translateRType
	add s3, s3, a0
	lw a1, 4(sp)
	add a1, a0, a1
	sw a1, 4(sp)
	jal Back
SRL:
	li t0, 0xF0000000
	and t0, s0, t0
	beq t0, zero, SRAI
	li a2, 0x75
	jal translateRType
	add s3, s3, a0
	lw a1, 4(sp)
	add a1, a0, a1
	sw a1, 4(sp)
	jal Back
SRA:
	li a2, 0x76
	jal translateRType
	add s3, s3, a0
	lw a1, 4(sp)
	add a1, a0, a1
	sw a1, 4(sp)
	jal Back	
	
SLL:
	li a2, 0x74
	jal translateRType
	add s3, s3, a0
	lw a1, 4(sp)
	add a1, a0, a1
	sw a1, 4(sp)
	jal Back
	
#This function translates an I-Type RISC-V instruction into WASM. It also writes the translated instruction 
#to the binary representation of the WASM code.
#Arguments:
#	a0: Address to write instruction representation translated into WASM.
#	a1: Address of the RISC-V instruction to parse.
#	a2: WASM opcode for the WASM instruction to build. NOT the RISC-V opcode for the instruction.
#Return Values:
#	a0: The number of bytes in the translated WASM instruction.

translateIType:
	mv s1, a0
	addi sp, sp, -4
	sw ra, 0(sp)
	lw s0, 0(a1) #s0 <-- Instruction to translate
	
	li t4, 0x0F8000
	and a0, t4, s0
	srli a0, a0, 15 #Using mask and bit shifting to get the source register
	jal TranslatetoWASMVar	
	mv t0, a0 #t0 <-- s(WASM variable)
	
	#Checking how many bits the immediates are to use appropriate mask.
	li t4, 0x72
	beq a2, t4, twelveBitImm
	li t4, 0x6a
	beq a2, t4, twelveBitImm
	li t4, 0x71
	beq a2, t4, twelveBitImm
	
	#5 bit immediates:
	li t4, 0x01F00000
	and a0, t4, s0
	srai a0, a0, 20 #Using mask and bit shifting to get the target register
	addi sp, sp, -4
	sw t0, 0(sp)
	jal encodeLEB128
	mv s2, a1
	lw t0, 0(sp)
	addi sp, sp, 4
	mv t1, a0 #t1 <-- imm (LEB128 encoded)
	jal C1
#Gets the 12 bit immediate
twelveBitImm:
	li t4, 0xFFF00000
	and a0, t4, s0
	srai a0, a0, 20 #Using mask and bit shifting to get the target register
	addi sp, sp, -4
	sw t0, 0(sp)
	jal encodeLEB128
	mv s2, a1
	lw t0, 0(sp)
	addi sp, sp, 4
	mv t1, a0 #t1 <-- imm (LEB128 encoded)
	
C1:	li t4, 0x0F80
	and a0, t4, s0
	srli a0, a0, 7 #Using mask and bit shifting to get the destination register
	addi sp, sp, -8
	sw t0, 0(sp)
	sw t1, 4(sp)
	jal TranslatetoWASMVar
	lw t0, 0(sp)
	lw t1, 4(sp)
	addi sp, sp, 8
	mv t2, a0 #t2 <-- d (WASM Variable)
	
	li t5, 0x4100
	bne t0, t5, Continue1 #If not using zero register, goto Continue1
	addi sp, sp, -4
	sw t0, 0(sp)
	jal ZeroR	#Else insert 0x41 and 0x00
	lw t0, 0(sp)
	addi sp, sp, 4
	jal Continue2 #Dont insert 0x20 and value stored in t0
Continue1:
	li t4, 0x20 
	sb t4, 0(s1) #Insert 0x20 (get local)
	addi s1, s1, 1
	sb t0, 0(s1) #Insert value stored in t0 (source register)
	addi s1, s1, 1

Continue2:	
	li t4, 0x41
	sb t4, 0(s1) #Writing i32.const
	addi s1, s1, 1
	li t4, 1
	beq s2, t4, oneByte #If encoded immediate is one byte, goto oneByte
	li a0, 8
	andi t4, t1, 0x0FF #t4 <-- first byte
	sb t4, 0(s1) #Insert first byte
	addi s1, s1, 1
	srli t1, t1, 8 #t1 <-- second byte
	sb t1, 0(s1) #Insert secnod byte (imm)
	addi s1, s1, 1
	jal C2
#If the leb128 ecoded number is onebyte code continue here
oneByte:	
	sb t1, 0(s1)
	addi s1, s1, 1
	li a0, 7
C2:	
	sb a2, 0(s1) #Insert a2 (WASM OpCode)
	addi s1, s1, 1
Continue3:
	li t4, 0x21 
	sb t4, 0(s1)#Insert 0x21 (set local)
	addi s1, s1, 1
	sb t2, 0(s1) #Insert value stored in t1 (destination register)
	addi s1, s1, 1
					
C3:	lw ra, 0(sp)
	addi sp, sp, 4
	jr ra #Done
	

#This function translates an R-Type RISC-V instruction into WASM. It also writes the translated instruction to 
#the binary representation of the WASM code. 
#Arguments:
#	a0: Address to write instruction representation translated into WASM.
#	a1: Address of the RISC-V instruction to parse.
#	a2: Opcode for the WASM instruction to build. NOT the RISC-V opcode for the instruction.
#Return Values:
#	a0: The number of bytes in the translated WASM instruction.	

translateRType:
	mv s1, a0
	addi sp, sp, -4
	sw ra, 0(sp)
	lw s0, 0(a1) #s0 <-- Instruction to translate
	
	li t4, 0x0F8000
	and a0, t4, s0
	srli a0, a0, 15 #Using mask and bit shifting to get the source register
	jal TranslatetoWASMVar	
	mv t0, a0 #t0 <-- s(WASM variable)
	
	li t4, 0x01F00000
	and a0, t4, s0
	srli a0, a0, 20 #Using mask and bit shifting to get the target register
	addi sp, sp, -4
	sw t0, 0(sp)
	jal TranslatetoWASMVar
	lw t0, 0(sp)
	addi sp, sp, 4
	mv t1, a0 #t1 <-- t (WASM variable)
	
	li t4, 0x0F80
	and a0, t4, s0
	srli a0, a0, 7 #Using mask and bit shifting to get the destination register
	addi sp, sp, -8
	sw t0, 0(sp)
	sw t1, 4(sp)
	jal TranslatetoWASMVar
	lw t0, 0(sp)
	lw t1, 4(sp)
	addi sp, sp, 8
	mv t2, a0 #t2 <-- d (WASM Variable)
	
	li t5, 0x4100
	bne t0, t5, Continue1R #If not using zero register, goto Continue1
	addi sp, sp, -4
	sw t0, 0(sp)
	jal ZeroR	#Else insert 0x41 and 0x00
	lw t0, 0(sp)
	addi sp, sp, 4
	jal C1R #Dont insert 0x20, and value stored in t0
Continue1R:
	li t4, 0x20 
	sb t4, 0(s1) #Insert 0x20 (get local)
	addi s1, s1, 1
	sb t0, 0(s1) #Insert value stored in t0 (source register)
	addi s1, s1, 1
C1R:	
	bne t1, t5, Continue2R #If not using zero register, goto Continue2
	addi sp, sp, -4
	sw t0, 0(sp)
	jal ZeroR #Else insert 0x41 and 0x00
	lw t0, 0(sp)
	addi sp, sp, 4
	jal C2R
Continue2R:
	li t4, 0x20
	sb t4, 0(s1) #Insert 0x20 (get local)
	addi s1, s1, 1
	sb t1, 0(s1) #Insert value stored in t1 (target register)
	addi s1, s1, 1
C2R:	
	sb a2, 0(s1) #Insert a2 (WASM OpCode)
	addi s1, s1, 1

Continue3R:
	li t4, 0x21 
	sb t4, 0(s1)#Insert 0x21 (set local)
	addi s1, s1, 1
	sb t2, 0(s1) #Insert value stored in t1 (destination register)
	addi s1, s1, 1
					
C3R:	lw ra, 0(sp)
	addi sp, sp, 4
	li a0, 7
	jr ra #Done
	

#This function translates a branch RISC-V instruction into WASM, with special care being taking to account for differences in 
#forward and backward branches. It also writes the translated instruction to the binary representation of the WASM code.
#Arguments:
#	a0: Address to write instruction representation translated into WASM.
#	a1: Address of the RISC-V instruction to parse.
#	a2: Opcode for the WASM instruction to build. NOT the RISC-V opcode for the instruction.
#Return Values:
#	a0: The number of bytes in the translated WASM instruction.

translateBranch:
	mv s1, a0
	addi sp, sp, -4
	sw ra, 0(sp)
	lw s0, 0(a1) #s0 <-- Instruction to translate
	
	li t0, 0x80000000
	and t0, s0, t0
	beqz t0, Forward #If t0, is zero, goto Forward
#Backward:
	li t4, 0x0F8000
	and a0, t4, s0
	srli a0, a0, 15 #Using mask and bit shifting to get the source register
	jal TranslatetoWASMVar	
	mv t0, a0 #t0 <-- s(WASM variable)
	
	li t4, 0x01F00000
	and a0, t4, s0
	srli a0, a0, 20 #Using mask and bit shifting to get the target register
	addi sp, sp, -4
	sw t0, 0(sp)
	jal TranslatetoWASMVar
	lw t0, 0(sp)
	addi sp, sp, 4
	mv t1, a0 #t1 <-- t (WASM variable)
	
	li t5, 0x4100
	bne t0, t5, Continue1BR #If not using zero register, goto Continue1BR
	addi sp, sp, -4
	sw t0, 0(sp)
	jal ZeroR	#Else insert 0x41 and 0x00
	lw t0, 0(sp)
	addi sp, sp, 4
	jal C1BR #Dont insert 0x20, and value stored in t0
Continue1BR:
	li t4, 0x20 
	sb t4, 0(s1) #Insert 0x20 (get local)
	addi s1, s1, 1
	sb t0, 0(s1) #Insert value stored in t0 (source register)
	addi s1, s1, 1
C1BR:	
	bne t1, t5, Continue2BR #If not using zero register, goto Continue2
	addi sp, sp, -4
	sw t0, 0(sp)
	jal ZeroR #Else insert 0x41 and 0x00
	lw t0, 0(sp)
	addi sp, sp, 4
	jal C2BR
	
Continue2BR:
	li t4, 0x20
	sb t4, 0(s1) #Insert 0x20 (get local)
	addi s1, s1, 1
	sb t1, 0(s1) #Insert value stored in t1 (target register)
	addi s1, s1, 1
C2BR:	
	sb a2, 0(s1) #Insert a2 (WASM OpCode)
	addi s1, s1, 1
Continue3BR:
	li t4, 0x0D
	sb t4, 0(s1)#Insert 0x0D (br_if)
	addi s1, s1, 1
	li t4, 0x0
	sb t4, 0(s1) #Insert 0 in (br_if 0)
	addi s1, s1, 1
	li t4, 0x0B
	sb t4, 0(s1) #Insert end
	addi s1, s1, 1
					
C3BR:	lw ra, 0(sp)
	addi sp, sp, 4
	li a0, 8
	jr ra #Done
#If imm is positive, its a forward branch
Forward:
	li t4, 0x0F8000
	and a0, t4, s0
	srli a0, a0, 15 #Using mask and bit shifting to get the source register
	jal TranslatetoWASMVar	
	mv t0, a0 #t0 <-- s(WASM variable)
	
	li t4, 0x01F00000
	and a0, t4, s0
	srli a0, a0, 20 #Using mask and bit shifting to get the target register
	addi sp, sp, -4
	sw t0, 0(sp)
	jal TranslatetoWASMVar
	lw t0, 0(sp)
	addi sp, sp, 4
	mv t1, a0 #t1 <-- t (WASM variable)
	
	li t4, 0x02
	sb t4, 0(s1) #Insert 0x02 (block)
	addi s1, s1, 1
	li t4, 0x40
	sb t4, 0(s1) #Insert 0x40 (void)
	addi s1, s1, 1
	
	li t5, 0x4100
	bne t0, t5, Continue1BRN #If not using zero register, goto Continue1BRN
	addi sp, sp, -4
	sw t0, 0(sp)
	jal ZeroR	#Else insert 0x41 and 0x00
	lw t0, 0(sp)
	addi sp, sp, 4
	jal C1BRN #Dont insert 0x20, and value stored in t0
Continue1BRN:
	li t4, 0x20 
	sb t4, 0(s1) #Insert 0x20 (get local)
	addi s1, s1, 1
	sb t0, 0(s1) #Insert value stored in t0 (source register)
	addi s1, s1, 1
C1BRN:	
	bne t1, t5, Continue2BRN #If not using zero register, goto Continue2BRN
	addi sp, sp, -4
	sw t0, 0(sp)
	jal ZeroR #Else insert 0x41 and 0x00
	lw t0, 0(sp)
	addi sp, sp, 4
	jal C2RN
	
Continue2BRN:
	li t4, 0x20
	sb t4, 0(s1) #Insert 0x20 (get local)
	addi s1, s1, 1
	sb t1, 0(s1) #Insert value stored in t1 (target register)
	addi s1, s1, 1
C2RN:	
	sb a2, 0(s1) #Insert a2 (WASM OpCode)
	addi s1, s1, 1
Continue3BRN:
	li t4, 0x0D
	sb t4, 0(s1)#Insert 0x0D (br_if)
	addi s1, s1, 1
	li t4, 0x0
	sb t4, 0(s1) #Insert 0 in (br_if 0)
	addi s1, s1, 1
					
C3BRN:	lw ra, 0(sp)
	addi sp, sp, 4
	li a0, 9
	jr ra #Done


#If we're dealing with zero register, we use this funciton
ZeroR:
	addi sp, sp, -4
	sw ra, 0(sp)
	li t0, 0x41
	sb t0, 0(s1) #Inserts 0x41 
	addi s1, s1, 1
	li t0, 0x00
	sb t0, 0(s1) #Inserts 0x00
	addi s1, s1, 1
	sw ra, 0(sp)
	addi sp, sp, 4
	jr ra

#This function translates a RISCV register into WASM variable
#Arguments:
#	a0: RISC Register numbrt
#Return Values:
#	a0: WASM Var.
TranslatetoWASMVar:
	addi sp, sp, -4
	sw ra, 0(sp)
	li t0, 10
	bge a0, t0, Sub10 #For registers greater than x10, subtract 10
	beqz a0, Zero #If register is zero, return 0x4100
	addi a0, a0, 17 #Else, add 17
	lw ra, 0(sp)
	addi sp, sp, 4
	jr ra
#Special case if a0 is zero, return 0x4100 for letting the translater know that it has to write
#i32.const 0
Zero:
	li a0, 0x4100
	lw ra, 0(sp)
	addi sp, sp, 4
	jr ra
	
Sub10:
	addi a0, a0, -10
	lw ra, 0(sp)
	addi sp, sp, 4
	jr ra
	


#This function converts a 12-bit two-complement value into LEB128 representation.
#Arguments:
#	a0: A 12-bit two-complement value, stored in the lower half of the word, to be converted into LEB128 representation.
#Return Values:
#	a0: The LEB128 representation of the input value. The least-significant byte of the LEB128 representation should be in the least-significant byte of a0. Examples of conversions are shown here
#	a1: The number of bytes that were needed to represent the resulting LEB128 formatted value.
encodeLEB128:
	addi sp, sp, -4
	sw ra, 0(sp)
	bltz a0, Negative #If a0 is negative, goto Negative
	li t0, 64
	bge a0, t0, Two7 #If a0 is greater than 0x80, take lowest 14 bits
	jal One7 #Else take lowest 7 bits, since largest possbile is 2047
Negative:
	li t0, -64
	bge a0, t0, One7 #If a0 is greater than -64, take lowest 7 bits
	jal Two7 #Else take lowest 14, since smallest possbile is -2048
#lowest 7 bits
One7:
	li t0, 0x7F
	and t1, t0, a0 #Using mask to take lowset 7 bits
	andi a0, t1, 0x7F #Sentinel
	li a1, 1 
	lw ra, 0(sp)
	addi sp, sp, 4
	jr ra
#First 14 bits
Two7:
	li t0, 0x7F
	and t1, t0, a0 #t1 <-- Using mask to take lowset 7 bits
	srli a0, a0, 7
	and t2, t0, a0 #Using mask to take lowset 14 bits
	
	ori t1, t1, 0x80 #Set the MSB to 1 in all but the last group.
	andi t2, t2, 0x7F #Set the MSB to 0 in the last group.
	slli t2, t2, 8
	add a0, t1, t2 #Adding most significant 7 and 14 bits.
	li a1, 2
	lw ra, 0(sp)
	addi sp, sp, 4
	jr ra

#This function initializes one table of counts and then computes all forward and backward branch 
#target counts in the given RISC-V program. Criteria is that the nth pair (fw count, bw count) corresponds to
#nth function.
#Arguments:
#	a0: Pointer to the binary representation of the RISC-V program.
generateTargetTable:
	addi sp, sp, -12
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	la s1, Table
	mv s0, a0
L1B:	
	lw t0, 0(s0) #t0 <-- instr.
	li t1, 0xFFFFFFFF
	beq t1, t0, Done #If we reach end, Done
	andi t1, t0, 0x063
	li t2, 0x063
	beq t1, t2, Branch #If Instr is a branch go to branch
	addi s0, s0, 4 #Else check next instr.
	jal L1B
Done:
	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	addi sp, sp, 12
	jr ra
	
Branch:
	li t1, 0xFE000000
	and t1, t0, t1
	srli t1, t1, 25 #t0 <-- [12|10:5]
	
	li t2, 0xF80
	and t2, t0, t2
	srli t2, t2, 7 #t1 <-- [4:1|11]
	
	slli t1, t1, 5
	add t0, t1, t2
	andi t1, t0, 0x01 #t1 <-- 11th bit
	li t3, 0x800
	and t2, t0, t3 #t2 <-- 12th bit
	li t3, 0x7FE
	and t0, t0, t3
	#Moving 11th and 12th bit to correct places
	slli t2, t2, 1 
	slli t1, t1, 11
	#Adding the 11th and 12 bit to get the complete immediate
	add t0, t0, t2
	add t0, t0, t1
	#Sign Extending
	slli t0, t0, 19
	srai t0, t0 19
	
	
	bltz t0, Backward #If immediate is negative its a backward branch
	beq t0, zero, DoNothing
	#Else
	li a2, 1 #Forward branch
	add a1, s0, t0 #Add immediate to current address
	jal incrTargetCount
	addi s0, s0, 4
	jal L1B
DoNothing:
	addi s0, s0, 4
	jal L1B
Backward:
	li a2, 0 #Backward branch
	add a1, s0, t0 #Add immediate to current address
	jal incrTargetCount
	addi s0, s0, 4
	jal L1B

incrTargetCount:
	addi sp, sp, -4
	sw ra, 0(sp)
	la t0, Table
	sub t1, a1, a0 #t1 <-- index
	beqz a2, IncBw
IncFw:
	slli t1, t1, 1
	add t0, t0, t1
	lw t2, 4(t0)
	addi t2, t2, 1
	sw t2, 4(t0)
	lw ra, 0(sp)
	addi sp, sp, 4
	jr ra

IncBw:	
	slli t1, t1, 1
	add t0, t0, t1
	lw t2, 0(t0)
	addi t2, t2, 1
	sw t2, 0(t0)
	lw ra, 0(sp)
	addi sp, sp, 4
	jr ra
readTargetCount:
	addi sp, sp, -4
	sw ra, 0(sp)	
	sub t0, a1, a0 #t0 <-- Index
	beqz a2, BW
	slli t0, t0, 1
	la t1, Table
	add t0, t0, t1
	lw a0, 4(t0)
	lw ra, 0(sp)
	addi sp, sp, 4
	jr ra
BW:
	slli t0, t0, 1
	la t1, Table
	add t0, t0, t1
	lw a0, 0(t0)
	lw ra, 0(sp)
	addi sp, sp, 4
	jr ra
