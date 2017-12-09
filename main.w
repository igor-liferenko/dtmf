@ There are two boundaries: guaranteed zero and guaranteed one---threshold at which we can
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
    @<Put program on PC to initial state@>@;
  }
}

@ For off-hook indication we will send `\.{@@}' character to PC.

@<Put program...@>=
if (PIND & 1 << PD3) { /* off-line or base station is not powered
                          (automatically causes off-line) */
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
