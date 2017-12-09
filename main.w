@ существует две границы: граница гарантированного нуля и граница гарантированной
единицы---пороги за которыми мы можем однозначно четко определить текущий логический уровень.
Для пятивольтового питания это 1.4 и 1.8 вольт соответственно

@c
/*
Efficient AVR DTMF Decoding
Copyright (c) 2015, Paul Stoffregen

I originally developed this 8 bit AVR-based DTMF decoding code in 2009 for a
special one-off project.  More recently, I created a superior implementation
for 32 bit ARM Cortex-M4 in the Teensy Audio Library.

http://www.pjrc.com/teensy/td_libs_Audio.html
https://github.com/PaulStoffregen/Audio/blob/master/examples/Analysis/DialTone%
  _Serial/DialTone_Serial.ino

I highly recommend using the 32 bit version for new projects.  However, this
old 8 bit code may still be useful for some projects.  If you use this code,
I only ask that you preserve this info and links to the newer library.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice, development history, 32 bit audio library links,
and this permission notice shall be included in all copies or substantial
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

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
  int flag = 0;
  while (1) {
    digit = dtmf_digit();
    if (digit) cout(digit);
    @<Indicate hook state change to the PC@>;
  }
}

@ For off-hook indication we will send `\.{@@}' character to PC.

@<Indicate hook state change to the PC@>=
if (PIND & 1 << PD3) {
  flag = 0;
  PORTB &= (unsigned char) ~ (unsigned char) (1 << PB5);
}
else {
  if (flag == 0) cout('@@');
  flag = 1;
  PORTB |= 1 << PB5;
}

@ To reduce power consumption.

@<Put all pins to pullup mode@>=
PORTC = 0xff;
PORTD = 0xff;
PORTB = 0xff;
