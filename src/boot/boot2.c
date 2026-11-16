#include <stdint.h>

void boot2main(uint8_t drive)
{
    while(1) {
        asm volatile("hlt");
    }
}
