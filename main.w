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
  DDRD |= 1 << PD4;
  DDRB |= 1 << PB5;

  uart_init();
  dtmf_init();
  int flag = 0;
  while (1) {
    digit = dtmf_digit();
    if (digit) cout(digit);
    @<Indicate hook state change to the PC@>;
    @<Send disconnect signal to phone if timeout@>;
  }
}

@ For off-hook indication we will send `\.{@@}' character to PC. But it is not enough.

When the phone was off-hook and base station was reset - it is OK because it is the same
condition is in the line when base station is switched off and when the phose is off-hook.
The effect is as if the phone just goes on-hook.
I.e., the ADC value was low when phone was off-hook. Then came disconnect signal and the
ADC value stayed the same. Then power was restored on base station and the ADC signal
became high, and at the same time the phone was switched off (so that base station and
phone are now in default state).

But if the phone was on-hook and base station was reset - then the following happens:
ADC becomes low as if the phone was off-hook. So, corresponding symbol is send to PC
as if the phone was off-hook. The program on PC reacts on this, and starts the timeout alarm.
Meanwhile, power on base station is restored and it goes to on-hook state. After a while
timeout signal comes and base station is reset again - and everything repeats endlessly.

This second case may happen when we reflash the AVR,
because when it is reflashed PD4 (to which the relay is connected) is disabled for a short time,
which resets the base station. So, to avoid cases like this we need to disable alarm if phone is
on-hook. We will use `\.{\%}' character for this.

@<Indicate hook state change to the PC@>=
if (PIND & 1 << PD3) {
  if (flag == 1) cout('%');
  flag = 0;
  PORTB &= (unsigned char) ~ (unsigned char) (1 << PB5);
}
else {
  if (flag == 0) cout('@@');
  flag = 1;
  PORTB |= 1 << PB5;
}

@ Just poweroff/poweron base station via a relay - this will effectively switch off the phone.

@<Send disconnect signal to phone if timeout@>=
if (UCSR0A & (1<<RXC0)) {
  (void) UDR0; /* remove received data from buffer */
  cli();
  PORTD |= 1 << PD4;
  _delay_ms(500);
  PORTD &= (unsigned char) ~ (unsigned char) (1 << PD4);
  sei();
}
