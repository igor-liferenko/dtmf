MCU=$(shell if [ `whereami` = work ]; then echo atmega168; else echo atmega328p; fi)

all: main.hex

CC = avr-gcc
CFLAGS = -Os -Wall -g3 -mmcu=$(MCU) -DF_CPU=16000000UL -fpack-struct
OBJS = dtmf.o goetzel.o uart.o main.o

main.hex: $(OBJS)
	$(CC) $(CFLAGS) -o main.elf $(OBJS) 
	avr-objcopy -O ihex -R .eeprom -R .fuse -R .lock -R .signature main.elf main.hex
	avrdude -c usbasp -p $(MCU) -U flash:w:$@ -qq

goetzel.o: goetzel.S
	$(CC) $(CFLAGS) -c -o goetzel.o goetzel.S

clean:
	rm -f *.lst *.hex *.o *.obj *.elf *.bin

on-off:
	avr-gcc -mmcu=$(MCU) -g -Os -c on-off.c
	avr-gcc -mmcu=$(MCU) -g -o on-off.elf on-off.o
	avr-objcopy -O ihex on-off.elf on-off.hex
	avrdude -c usbasp -p $(MCU) -U flash:w:on-off.hex -qq
