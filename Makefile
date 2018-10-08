# Makefile for wren

CFLAGS   := -g2 -Os -Wall -W

all: wren

clean:
	rm -f *.o wren wrena wrenu examples.out
	rm -fR *.dSYM

wren: wren.o

wrena: wren.c
	$(CC) $(CFLAGS) -DWREN_UNALIGNED_ACCESS_OK=0 wren.c -o $@
	objdump -no-show-raw-insn -line-numbers $@ > $@.x

wrenu: wren.c
	$(CC) $(CFLAGS) -DWREN_UNALIGNED_ACCESS_OK=1 wren.c -o $@
	objdump -no-show-raw-insn -line-numbers $@ > $@.x
