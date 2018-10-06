CFLAGS   := -g2 -Os -Wall -W

all: wren

clean:
	rm -f *.o wren wrenb wrenl wrenu examples.out
	rm -R *.dSYM

wren: wren.o

wrenb: wren.c
	$(CC) $(CFLAGS) -DWREN_UNALIGNED_ACCESS_OK=0 -DWREN_BIG_ENDIAN_DATA=1 wren.c -o $@
	objdump -no-show-raw-insn -line-numbers $@ > $@.x

wrenl: wren.c
	$(CC) $(CFLAGS) -DWREN_UNALIGNED_ACCESS_OK=0 -DWREN_BIG_ENDIAN_DATA=0 wren.c -o $@
	objdump -no-show-raw-insn -line-numbers $@ > $@.x

wrenu: wren.c
	$(CC) $(CFLAGS) -DWREN_UNALIGNED_ACCESS_OK=1 -DWREN_BIG_ENDIAN_DATA=0 wren.c -o $@
	objdump -no-show-raw-insn -line-numbers $@ > $@.x
