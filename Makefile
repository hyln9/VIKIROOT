CFLAGS := -Os -Wall
LDFLAGS := -pthread -static -s -Wall
CC := gcc
AS := as
OC := objcopy

debug: CFLAGS += -DDBG
debug: all

all: exploit

exploit: exploit.o
	$(CC) -o $@ $^ $(LDFLAGS)

exploit.o: exploit.c payload.h
	$(CC) -o $@ -c $< $(CFLAGS)

payload.h: payload
	xxd -i $^ $@

payload.o: payload.s
	$(AS) -o $@ $^

payload: payload.o
	$(OC) -O binary $^ $@

clean:
	rm -f *.o *.h payload exploit
