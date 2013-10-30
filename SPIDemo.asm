/*
 * SPIDemo.asm
 *
 *  Created: 10/30/2013 5:01:01 PM
 *   Author: tjbell
 */ 

.include "m328pdef.inc"

.org $0000
	RJMP RESET;						Reset vector for the program

.org PCI1addr
	RJMP PCI1_INT;					Go to this label for interrupt handler

					; What is run on start up
					; Initialize Memory stack pointer
RESET:
	CLI;							Disable interrupts

	CLR r16;
	LDI r16, low(RAMEND);			Create the STACK
	OUT SPL, r16;
	CLR r16;
	LDI r16, high(RAMEND);
	OUT SPH, r16;

					; Set up SPI Registers
INITIALIZE_SPI:
	CLR r16;
					; SPI to be enabled, no interrupts, Master, MSB first, idle low, read/start High, 1/4 of Clock
	LDI r16, (0 << SPIE) | (1 << SPE) | (0 << DORD) | (1 << MSTR) | (0 << CPOL) | (0 << CPHA) | (0 << SPR1) | (0 << SPR0)
	OUT SPCR, r16;					Send to the SPI Register

					; Set the direction for SPI
INIT_SPI_DIRECTION_REGISTERS:
	CLR r16;

					; SPI to be MISO output, SCK out, and SS to be controlled here
	LDI r16, (1 << PB5) | (1 << PB3) | (1 << PB2);
	OUT DDRB, r16;					Ship it

SET_INTERRUPT:
	CLR r16;						Set the interrupt flag for PCI1
	LDI r16, ( 1 << PCIE1 );		PCIE1 enabled, the rest disabled
	STS PCICR, r16;

	CLR r16;
	LDI r16, ( 1 << PCINT13 );		Enable the interrupt for pin 28 (PCINT13)
	STS PCMSK1, r16;

SET_IO_PINS:
	CLR r16;
	LDI r16, 0x1F;					Set PinC5 as output
	OUT DDRC, r16;

	CLR r16;
	LDI r16, 0x20;					Enable the internal pull-up resistor for PinC5
	OUT PORTC, r16;

	SEI;

					; Loop forever
LOOP:
	RJMP LOOP;		Bye

PCI1_INT:
	CLI;							Disable interrupts

	CLR r16;
	CLR r17;

	IN r16, PINC;					Read in the data values
	LDI r17, (1 << PCINT13);
	AND r16, r17;					Mask off only to P5
	CPI r16, 0x00;					If PinC5 is high, send data
	BREQ WRITE_LOW;

WRITE_HIGH:
	CLR r16;
	LDI r16, 0x3F;
	OUT PORTC, r16;					Write out to all of the lights
	RJMP SEND_OUTPUT;				Send the data package

WRITE_LOW:
	CLR r16;
	LDI r16, 0x20;
	OUT PORTC, r16;					Write off to all of the lights
	RJMP END_PCI1;					End of the interrupt

SEND_OUTPUT:
					; Start Transmission
	CLR r16;
	CLR r17;
	
	LDI r16, (0 << PB2);			Send SS to low
	OUT PORTB, r16;

					; Send data
	LDI r17, 0xA;					Send over 1100
	OUT SPDR, r17;					Ship it

					; End Transmission
	CLR r16;
	LDI r16, (1 << PB2);

END_PCI1:
	SEI;
	RETI;