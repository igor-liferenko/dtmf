@ This program is for MT8870

@c

http://www.infidigm.net/projects/dtmf2/
integrate here hook.w (like it is integrated in main.w, but directly - to use just one AVR)

/*
 * ATmega16_DFMF_interfacing.c
 *
 * http://www.electronicwings.com
 */


#define F_CPU 16000000UL
#include <avr/io.h>
#include <avr/delay.h>
#include <avr/interrupt.h>

volatile int keydetect = 0;

ISR(INT0_vect)
{
        keydetect = true;
}

int main(void)
{
        DDRC = 0x00;            /* PORTC define as a input port */
        GICR = 1<<INT0;     /* Enable INT0*/
        MCUCR = 1<<ISC01 | 1<<ISC00;     /* Trigger INT0 on rising edge */

        sei();              /* Enable Global Interrupt */

    while(1)
    {
                if (keydetect)
                {
                        keydetect = false;
                        switch (PINC & 0x0F)
                        {
                                case (0x01):
                                ...
                                break;
...
