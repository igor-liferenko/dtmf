MCU=$(shell if [ `whereami` = home ] || [ `whereami` = notebook ]; then echo atmega328p; else echo atmega168; fi)

CC = avr-gcc
CFLAGS = -Os -Wall -g3 -mmcu=$(MCU) -DF_CPU=16000000UL -fpack-struct
OBJS = dtmf.o goetzel.o uart.o

main: $(OBJS)
	$(CC) -Wno-maybe-uninitialized -Os -Wall -g3 -mmcu=$(MCU) -DF_CPU=16000000UL -fpack-struct -c -o main.o main.c
	$(CC) $(CFLAGS) -o main.elf main.o $(OBJS)
	avr-objcopy -O ihex -R .eeprom -R .fuse -R .lock -R .signature main.elf main.hex
	avrdude -c usbasp -p $(MCU) -U flash:w:main.hex -qq

goetzel.o: goetzel.S
	$(CC) $(CFLAGS) -c -o goetzel.o goetzel.S

clean:
	rm -f *.lst *.hex *.o *.obj *.elf *.bin
