/* HW2- Stack Pointer
Name: Pengzhao Zhu    
Section#: 112D    
TA Name: Chris Crary    
Description: Stack Pointer Example. Trying to get myself familiar how to use stack pointers.

*/
.include "ATxmega128A1Udef.inc" 
.list 

.equ stack=0x2FFF
.EQU length= 10			;test vector length

.ORG 0x100
VECTOR:	.DB 1,2,3,4, 5, 6, 7, 8, 9       ;trying to mess around the table with pointers. but couldn't do it

.org 0x00
rjmp MAIN

.org 0x200
MAIN:
	ldi YL,low(stack)
	out CPU_SPL, YL
	ldi YH, high(stack)
	out CPU_SPH, YH
	ldi XL, 0x37    ;push 0x37
	push XL
	ldi XH, 0xAB    ;push 0xAB
	push XH
	ldi YL, 0x12    ;push EF12
	push YL
	ldi YH, 0xEF
	rcall routine   ;call the subroutine

	rjmp DONE

DONE: 
	rjmp DONE

routine:
ldi YH, 0x1C      ;the subroutine
push YH           ;push 
ret