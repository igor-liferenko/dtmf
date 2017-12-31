@ This program is for MT8870.

@d F_CPU 16000000UL

@c
#include <avr/io.h>
#include <avr/interrupt.h>

volatile int keydetect = 0;

ISR(INT0_vect)
{
  keydetect = 1;
}

void main(void)
{
  unsigned char digit;

  @<Put all pins to pullup mode@>@;
  PORTD &= (unsigned char) ~ (unsigned char) (1 << PD2); /* STQ */
  PORTD &= (unsigned char) ~ (unsigned char) (1 << PD4); /* 4 */
  PORTD &= (unsigned char) ~ (unsigned char) (1 << PD5); /* 3 */
  PORTD &= (unsigned char) ~ (unsigned char) (1 << PD6); /* 2 */
  PORTD &= (unsigned char) ~ (unsigned char) (1 << PD7); /* 1 */

  PORTB &= (unsigned char) ~ (unsigned char) (1 << PB5);
  DDRB |= 1 << PB5;

  @<Initialize UART@>@;

  EICRA |= 1 << ISC01 | 1 << ISC00; /* set INT0 to trigger on rising edge */
  EIMSK |= 1 << INT0; /* turn on INT0 */

  sei(); /* turn on interrupts */

  while(1) {
    @<Indicate...@>@;
    if (keydetect) {
      keydetect = 0;
      switch (PIND & 0xF0) {
      case (0x10):
        digit = '1';
        break;
      case (0x20):
        digit = '2';
        break;
      case (0x30):
        digit = '3';
        break;
      case (0x40):
        digit = '4';
        break;
      case (0x50):
        digit = '5';
        break;
      case (0x60):
        digit = '6';
        break;
      case (0x70):
        digit = '7';
        break;
      case (0x80):
        digit = '8';
        break;
      case (0x90):
        digit = '9';
        break;
      case (0xA0):
        digit = '0';
        break;
      case (0xB0):
        digit = '*';
        break;
      case (0xC0):
        digit = '#';
        break;
      default:
        digit = '?';
        break;
      }
      while (!(UCSR0A & 1 << UDRE0)) ; /* loop while the transmit buffer is not ready to receive
                                          new data */
      UDR0 = digit;
    }
  }
}

@ To reduce power consumption.

@<Put all pins to pullup mode@>=
PORTC = 0xff;
PORTD = 0xff;
PORTB = 0xff;

@ @d BAUD 57600

@<Initialize UART@>=
#include <util/setbaud.h>
UBRR0H = UBRRH_VALUE;
UBRR0L = UBRRL_VALUE;
#if USE_2X
  UCSR0A |= (1<<U2X0);
#endif
UCSR0B = (1<<TXEN0);
UCSR0C = (1<<UCSZ01) | (1<<UCSZ00);

@ For on-line indication we send `\.{@@}' character to PC---to put
program on PC to initial state.
For off-line indication we send `\.{\%}' character to PC---to disable
power reset on base station after timeout.

See \.{test-AOT127A.w} to recall how it was tested.

@<Indicate line state change to the PC@>=
if (PIND & 1 << PD3) { /* off-line or base station is not powered
                          (automatically causes off-line) */
  if (PORTB & 1 << PB5) {
      while (!(UCSR0A & 1 << UDRE0)) ; /* loop while the transmit buffer is not ready to receive
                                          new data */
      UDR0 = '%';
  }
  PORTB &= (unsigned char) ~ (unsigned char) (1 << PB5);
}
else { /* on-line */
  if ((PORTB & 1 << PB5) == 0) {
      while (!(UCSR0A & 1 << UDRE0)) ; /* loop while the transmit buffer is not ready to receive
                                          new data */
      UDR0 = '@@';
  }
  PORTB |= 1 << PB5;
}
