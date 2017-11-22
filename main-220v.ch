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
