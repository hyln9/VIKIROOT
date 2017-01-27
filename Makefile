CFLAGS := -Os -fPIE -Wall
LDFLAGS := -pthread -s -pie -Wall
CC := aarch64-linux-android-gcc
AS := aarch64-linux-android-as
OC := aarch64-linux-android-objcopy

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
