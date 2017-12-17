@ TODO: do as in scheme.svg and take on-line/off-line indication from base station's LED
(check that it is not connected with phone line - otherwise use photo resistor).
This will allow to use transformer to play audio from PC.
Then remove the following paragraph.

There are two boundaries: guaranteed zero and guaranteed one---threshold at which we can
precisely determine current logical level. For 5v power supply these are 1.4 and 1.8
volts respectively.

@c
#include "main.h"

int main()
{
  char digit;

  @<Put all pins to pullup mode@>@;
  PORTD &= (unsigned char) ~ (unsigned char) (1 << PD3);
  PORTB &= (unsigned char) ~ (unsigned char) (1 << PB5);

  DDRB |= 1 << PB5;

  uart_init();
  dtmf_init();
  while (1) {
    digit = dtmf_digit();
    if (digit) cout(digit);
    @<Indicate...@>@;
  }
}

@ For on-line indication we send `\.{@@}' character to PC---to put
program on PC to initial state.
For off-line indication we send `\.{\%}' character to PC---to disable
power reset on base station after timeout.

@<Indicate line state change to the PC@>=
if (PIND & 1 << PD3) { /* off-line or base station is not powered
                          (automatically causes off-line) */
  if (PORTB & 1 << PB5) cout('%');
  PORTB &= (unsigned char) ~ (unsigned char) (1 << PB5);
}
else { /* on-line */
  if ((PORTB & 1 << PB5) == 0) cout('@@');
  PORTB |= 1 << PB5;
}

@ To reduce power consumption.

@<Put all pins to pullup mode@>=
PORTC = 0xff;
PORTD = 0xff;
PORTB = 0xff;
