220v relay is used because power supply on base station is AC and thus does not work with TLP281,
so the signal must be inverted.

@x
  PORTD &= (unsigned char) ~ (unsigned char) (1 << PD4);
@y
@z

@x
  PORTD |= 1 << PD4;
@y
  PORTD &= (unsigned char) ~ (unsigned char) (1 << PD4);
@z

@x
  PORTD &= (unsigned char) ~ (unsigned char) (1 << PD4);
@y
  PORTD |= 1 << PD4;
@z

This change is for arduino from email-wifi.w to disable LEDs on PB1-PB4.
@x
PORTB = 0xff;
@y
PORTB = 0xff & ~(1 << PB1) & ~(1 << PB2) & ~(1 << PB3) & ~(1 << PB4);
@z
