@ @d F_CPU 16000000UL

@c
/* TODO: after you receive dtmf decoder, see avrtel.w */

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
/* TODO: use another channel on optical relay to behave the same as button (with pullup - see below) on PD3 in
   main.w, and pick proper resistor to switch it on/off, and then this file may be removed

Если PORTxy=1 то вывод в режиме PullUp с подтяжкой резистором в 100к до питания.
При DDRxy=0 и PORTxy=1 замыкается ключ подтяжки и к линии подключается резистор в 100кОм, что моментально приводит неподключенную никуда линию в состояние лог1. Цель подтяжки очевидна — недопустить хаотичного изменения состояния на входе под действием наводок. Но если на входе появится логический ноль (замыкание линии на землю кнопкой или другим микроконтроллером/микросхемой), то слабый 100кОмный резистор не сможет удерживать напряжение на линии на уровне лог1 и на входе будет нуль. */

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
