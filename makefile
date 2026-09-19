.PHONY: run clean disasm

CC = $(HOME)/opt/cross/bin/i686-elf-gcc
LD = $(HOME)/opt/cross/bin/i686-elf-ld
AS = nasm
DA = $(HOME)/opt/cross/bin/i686-elf-objdump
QM = qemu-system-i386

C_SOURCES = $(wildcard src/*.c)
OBJECTS = build/boot.o $(patsubst src/%.c,build/%.o,$(C_SOURCES))
DEPENDENCIES = $(wildcard build/*.d)

build/int.o: EXTRA_FLAGS = -mgeneral-regs-only



-include $(DEPENDENCIES)



build/kernel.bin: $(OBJECTS) link.ld | $(LD) build
	$(LD) -T link.ld $(OBJECTS) -o $@ -Map=build/kernel.map && $(MAKE)

build/boot.o: src/boot.asm | build
	$(AS) -f elf32 $< -o $@

build/%.o:src/%.c | $(CC) build
	$(CC) -ffreestanding -O0 -Iinclude $(EXTRA_FLAGS) -MD -c $< -o $@



$(CC) $(LD) $(DA) &:
	bash setup.sh



run: build/kernel.bin
	$(QM) -drive file=$<,format=raw,index=0,media=disk -monitor stdio

clean:
	rm -f $(OBJECTS) $(DEPENDENCIES) build/kernel.map

disasm: build/kernel.bin | $(DA)
	$(DA) -D -b binary -m i386 $<



build:
	mkdir -p build
