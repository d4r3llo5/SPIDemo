/*
 * SPIDemo.asm
 *
 *  Created: 10/30/2013 5:01:01 PM
 *   Author: tjbell
 */ 

.include "m328pdef.inc"

.org $0000
	RJMP RESET;						Reset vector for the program

									; What is run on start up
									; Initialize Memory stack pointer
RESET:
	CLI;							Disable interrupts
	LDI r16, low(RAMEND);			Create the STACK
	OUT SPL, r16;
	LDI r16, high(RAMEND);
	OUT SPH, r16;



