On arduino duemilanove PD4 stopped working for some reason,
so use PD5 instead.

@x
  DDRD |= 1 << PD4;
@y
  DDRD |= 1 << PD5;
@z

@x
  PORTD |= 1 << PD4;
@y
  PORTD |= 1 << PD5;
@z

@x
  PORTD &= (unsigned char) ~ (unsigned char) (1 << PD4);
@y
  PORTD &= (unsigned char) ~ (unsigned char) (1 << PD5);
@z
