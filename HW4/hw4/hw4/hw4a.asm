/* HW 4 Part A
   Name: Pengzhao Zhu
   Section#: 112D
   TA Name: Chris Crary
   Description: This Program outputs the ASCII chacter "U" to Putty continously 
				
*/


.include "ATxmega128A1Udef.inc"        ;include the file
.list                                  ;list it 

.org 0x0000                            ;start our program here
rjmp MAIN                              ;jump to main

.equ stack_init=0x3FFF   ;initialize stack pointer
.equ BSELHIGH=(((8)*((32000000/(16*115200))-1))>>8)
.equ BSEL=((8)*((32000000/(16*115200))-1))

.org 0x100

MAIN:
ldi r23, 0x00   ;setting for 32MHZ subroutine

rcall CLK

ldi YL, low(stack_init)    ;Load 0xFF to YL
out CPU_SPL, YL			   ;transfer to CPU_SPL
ldi YL, high(stack_init)   ;Load 0x3F to YH
out CPU_SPH, YL			   ;transfer to CPU_SPH

ldi r17, 0x55       ;ASCII hex code for �U". Used in the OUT_CHAR subroutine

rcall USART        ;call subroutine to set up USART system

LOOP:               
rcall OUT_CHAR      ;call OUT_CHAR subroutine
rjmp LOOP			;infinite loop to output "U"

USART:
push r16                  ;push r16
push r18
ldi r16, 0x08             ;load r16 with 0x08
sts PORTD_DIRSET, r16     ;set receiver as output
ldi r16, 0x04             ;load r16 with 0x04
sts PORTD_DIRCLR, r16     ;set transmitter as input

ldi r16, 0x18   
sts USARTD0_CTRLB, r16          ;enable receiver and transmitter

ldi r16, 0x33      ;USART asynchronous, 8 data bit, odd parity, 1 stop bit
sts USARTD0_CTRLC, r16

ldi r16, low(BSEL)                     ;8 bit BSEL value
sts USARTD0_BAUDCTRLA, r16

ldi r16, low(BSELHIGH)
ldi r18, 0xD0
or r16, r18                    ;BSCALE of -3, ignoring highest 4 bit

sts USARTD0_BAUDCTRLB, r16     ;load BAUDCTRLB with BSCALE and highest 4 bits of BSEL

ldi r16, 0x04                  ;turn the transmit pin idle by writing a one to it. pin2 is the transmit pin
sts PORTD_OUTSET, r16			;turn the transmit pin idle

pop r18
pop r16
ret


OUT_CHAR:               ;OUT_CHAR subroutine
push r16

/*
WAIT:
lds r16, USARTD0_STATUS
bst r16, 6    ;check TXCIF (bit 6, TXCIF:Transmit Complete Interrupt Flag) to see if there is any ongoing transmission
brts COMPLETE
brtc WAIT
*/

COMPLETE:
lds r16, USARTD0_STATUS  
bst r16, 5				;check the DREIF (Data register empty flag)
brts LOAD
brtc COMPLETE

LOAD:
sts USARTD0_DATA, r17               ;transit "U" to the data register

pop r16
ret





CLK:   ;take in a r17 value for prescaler. 32MHZ = 0x00 for prescale
push r16              ;push r16
ldi r16, 0b00000010   ;bit 1 is the 32Mhz oscillator
sts OSC_CTRL, r16     ;store r16 into the OSC_CTRL

NSTABLE:
lds r16, OSC_STATUS     ;load oscillator status into r16
bst r16, 1              ;check if 32Mhz oscillator is stable
brts STABLE             ;branch if stable
brtc NSTABLE            ;loop again if non-stable

STABLE:
ldi r16, 0xD8   ;writing IOREG to r16
sts CPU_CCP, r16 ;write IOREG to CPU_CCP to enable change 
ldi r16, 0b00000001  ;write this to r16. corresponds to 32Mhz oscillator
sts CLK_CTRL, r16    ;select the 32Mhz oscillator

ldi r16, 0xD8    ;writing IOREG for prescaler
sts CPU_CCP, r16 ;for prescaler
sts CLK_PSCTRL, r23  ;r23 will be initialized outside the subroutine for prescale. 32/8=4MHZ

pop r16          ;pop r16
ret              ;return to main routine
