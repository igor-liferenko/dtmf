@ @d F_CPU 16000000UL

@c
/* TODO: after you receive dtmf decoder, see file "tel.w" in this directory */

#include <avr/io.h>

int main (void)
{
	unsigned char sample;

	DDRB |= (1<<PB3) | (1<<PB1);
	ADMUX = 1 << REFS0 | 1 << ADLAR | 4;
	ADCSRA = 1 << ADEN; /* enable ADC */
        ADCSRA |= (1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0); /* prescaler of 128
                                                       (16000000/128 = 125000) */
        ADCSRA |= 1<<ADSC; /* start conversion */

        DDRD |= 1 << PD4;

	while(1) {
		while(ADCSRA & (1<<ADSC));
		sample = ADCH;
		if (sample < 150) {
                  PORTD |= 1<<PD4; /* off-hook */
		  PORTB |= 1<<PB1;  /* GREEN on */
		  PORTB &= (unsigned char) ~ (unsigned char) (1<<PB3); /* RED off */
		}
		else {
                        PORTD &= (unsigned char) ~ (unsigned char) (1<<PD4); /* on-hook */
			PORTB |= 1<<PB3;  /* RED on */
			PORTB &= (unsigned char) ~ (unsigned char) (1<<PB1); /* GREEN off */
		}
		ADCSRA |= 1<<ADSC; /* start conversion */
	}
}
