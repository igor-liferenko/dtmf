@ @d F_CPU 16000000UL
@d BAUD 9600

@c
/*
  adctest.c
  David Rowe
  15 Sep 2007

  Compares the ADC to two thresholds, lights RED if beneath
  threshold, lights GREEN if above.  Blinks YELLOW on every ADC
  conversion.
*/

/* TODO: after you receive dtmf decoder, do this via interrupt like dtmf is done now */

//#include <inttypes.h>
#include <avr/io.h>
//#include <avr/interrupt.h>
//#include <avr/sleep.h>

int main (void)
{
	unsigned char sample;

	DDRB |= (1<<PB3) | (1<<PB1) | (1<<PB2);
	ADMUX = 1 << REFS0 | 1 << ADLAR | 4;
	ADCSRA = 1 << ADEN; /* enable ADC */
        ADCSRA |= (1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0); /* prescaler of 128
                                                       (16000000/128 = 125000) */
        ADCSRA |= 1<<ADSC; /* start conversion */

  #include <util/setbaud.h>
  UBRR0H = UBRRH_VALUE;
  UBRR0L = UBRRL_VALUE;
  #if USE_2X
    UCSR0A |= (1<<U2X0);
  #endif
  UCSR0B |= 1 << TXEN0;
  UCSR0C |= 1 << UCSZ01 | 1 << UCSZ00;


	while(1) {
		while(ADCSRA & (1<<ADSC));
		PORTB &= (unsigned char) ~ (unsigned char) (1<<PB2);         /* YELLOW off  */

		sample = ADCH;

    while(!(UCSR0A & (1<<UDRE0))); /* while the transmit buffer is not empty loop */
    UDR0 = sample; /* when the buffer is empty write data to the transmitted */

		if (sample < 0x80) {
			PORTB |=   1<<PB3;  /* RED on  */
			PORTB &= (unsigned char) ~ (unsigned char) (1<<PB1); /* GREEN off */
		}
		else {
			PORTB |=   1<<PB1;  /* GREEN on  */
			PORTB &= (unsigned char) ~ (unsigned char) (1<<PB3); /* RED off */
		}
		ADCSRA |= (1<<ADSC); /* start conversion */
		PORTB |= 1 << PB2;          /* YELLOW on */
	}
}
