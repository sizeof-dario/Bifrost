.PHONY: clean run

CC = ~/opt/cross/bin/i686-elf-gcc
LD = ~/opt/cross/bin/i686-elf-ld
AS = ~/opt/cross/bin/i686-elf-as

QM = qemu-system-i386

CC_FLAGS = -ffreestanding -m16 -O0
LD_FLAGS = --orphan-handling=error

C_SOURCES = $(wildcard src/boot/*.c)
OBJECTS = build/boot.o $(patsubst src/boot/%.c,build/%.o,$(C_SOURCES))
DEPENDENCIES = $(wildcard build/*.d)

build/boot.bin: $(OBJECTS) src/boot/boot.ld | $(LD) build
	$(LD) $(LD_FLAGS) -T src/boot/boot.ld $(OBJECTS) -o $@ -Map=build/boot.map

build/boot.o: src/boot/boot.S | $(AS) build
	$(AS) $< -o $@

build/%.o:src/boot/%.c | $(CC) build
	$(CC) $(CC_FLAGS) -MD -c $< -o $@

-include $(DEPENDENCIES)

run: build/boot.bin
	$(QM) -drive file=$<,format=raw,index=0,media=disk -monitor stdio

clean:
	rm -f $(OBJECTS) $(DEPENDENCIES) build/boot.bin build/boot.map

build:
	mkdir -p build
