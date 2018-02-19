#include <stdio.h>
#include <stdint.h>

uint16_t can_crc_next(uint16_t crc, uint8_t data)
{
    uint8_t i, j;

    // xor the value on top of the current crc
    crc ^= (uint16_t)data << 7;

    for (i = 0; i < 8; i++) {
        crc <<= 1; // shift crc
        if (crc & 0x8000) { // if crc bit 16 is set do xor
            crc ^= 0xc599;
        }
    }

    return crc & 0x7fff;
}

int main()
{
    int i;
    //uint8_t data[] = {0x01, 0x40, 0x20,0x28};
    //uint8_t data[] = {0xff};
    uint8_t data[] = {0x00};
    //uint8_t * data = 0";
    uint16_t crc = 0;

    for (unsigned int x = 0 ; x < 256 ; x++){
	    crc = 0;
	    crc = can_crc_next(crc, x);
    	    printf("%02X %04X\n", x , crc);
    }

}

