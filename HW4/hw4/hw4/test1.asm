.include "ATxmega128A1Udef.inc"        ;include the file
.list                                  ;list it 

.org 0x0000                            ;start our program here
rjmp MAIN                              ;jump to main

.equ stack_init=0x3FFF   ;initialize stack pointer
.equ BSELhigh=(((8)*((32000000/(16*115200))-1))>>8)
.equ BSEL=((8)*((32000000/(16*115200))-1))
;.equ BAUDB=(())*((32000000/(16*115200))-1)>>8)
.equ HI=(0b111100000000 >> 8)

MAIN:

.org 0x100

ldi r16, HI
ldi r17, low(BSEL)
ldi r18, high(BSEL)

ldi r16, 0b00101000
ldi r17, 0b10000000

or r16, r17

DONE: 
	rjmp DONE






