.PHONY: clean run

CC = ~/opt/cross/bin/i686-elf-gcc
LD = ~/opt/cross/bin/i686-elf-ld
AS = ~/opt/cross/bin/i686-elf-as

QM = qemu-system-i386

C_SOURCES = $(wildcard src/*.c)
OBJECTS = build/boot.o $(patsubst src/%.c,build/%.o,$(C_SOURCES))
DEPENDENCIES = $(wildcard build/*.d)

C_FLAGS = -ffreestanding -O0 -Iinclude
build/int.o: EXTRA_C_FLAGS = -mgeneral-regs-only



build/kernel.bin: $(OBJECTS) link.ld | $(LD) build
	$(LD) -T link.ld $(OBJECTS) -o $@ -Map=build/kernel.map


build/boot.o: src/boot.asm | $(AS) build
	$(AS) $< -o $@

build/%.o:src/%.c | $(CC) build
	$(CC) $(C_FLAGS) $(EXTRA_C_FLAGS) -MD -c $< -o $@



$(CC) $(LD) $(AS) $(DA) &:
	bash setup.sh
	


-include $(DEPENDENCIES)



run: build/kernel.bin
	$(QM) -drive file=$<,format=raw,index=0,media=disk -monitor stdio

clean:
	rm -f $(OBJECTS) $(DEPENDENCIES) build/kernel.map

build:
	mkdir -p build
