@ @d F_CPU 16000000UL
@d BAUD 9600

@c
/* TODO: after you receive dtmf decoder, merge this with program for that (see file "NEW") */

#include <avr/io.h>
#include <util/delay.h>

int main (void)
{
	unsigned char sample;

	DDRB |= (1<<PB3) | (1<<PB1);
	ADMUX = 1 << REFS0 | 1 << ADLAR | 4;
	ADCSRA = 1 << ADEN; /* enable ADC */
        ADCSRA |= (1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0); /* prescaler of 128
                                                       (16000000/128 = 125000) */
        ADCSRA |= 1<<ADSC; /* start conversion */

        int flag=0;

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
		sample = ADCH;

		if (sample < 0x80) {
                  _delay_ms(50); /* debounce */
                  if (!flag) {
                    while(!(UCSR0A & (1<<UDRE0))) ; /* while the transmit buffer is not empty loop */
                    UDR0 = sample; /* when the buffer is empty write data to the transmitted */
                  }
		  PORTB |=   1<<PB1;  /* RED on  */
		  PORTB &= (unsigned char) ~ (unsigned char) (1<<PB3); /* GREEN off */
                  flag=1;
		}
		else {
                        flag = 0;
			PORTB |=   1<<PB3;  /* GREEN on  */
			PORTB &= (unsigned char) ~ (unsigned char) (1<<PB1); /* RED off */
		}
		ADCSRA |= (1<<ADSC); /* start conversion */
	}
}
