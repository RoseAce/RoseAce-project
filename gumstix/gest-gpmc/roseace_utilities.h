#ifndef __ROSEACE_UTILITIES_H
#define __ROSEACE_UTILITIES_H

#include "roseace_gpmc.h"
#include <libavcodec/avcodec.h>

void send_frame_to_fpga(AVFrame * frame, int height, int width);

static inline void send_pixel_to_fpga(uint8_t red, uint8_t green, uint8_t blue, int npixel) {
  writel((blue << 16) | (green<< 8) | red, npixel<<2 & 0x0003ffff);
}

static inline void send_command_to_fpga(unsigned short command, long address) {
  writeh(command, (0b10 << 19) | (address & 0x0007ffff));
}

static inline void send_configure_to_fpga(unsigned short command, long address) {
  writeh(command, (0b01 << 19) | (address & 0x0007ffff));
}



#endif
