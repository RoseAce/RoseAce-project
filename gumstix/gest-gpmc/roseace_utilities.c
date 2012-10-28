#include "roseace_utilities.h"

void send_frame_to_fpga(AVFrame * frame, int height, int width) {
  uint8_t red, green, blue;

  int npixel;
  for (npixel=0; npixel<height*width; npixel++) {
    red = *(frame->data[npixel*3]);
    green = *(frame->data[npixel*3+1]);
    blue = *(frame->data[npixel*3+2]);
    
    send_pixel_to_fpga(red, green, blue, npixel);
  }
  
  send_command_to_fpga(0, 0); //Asking the fpga to switch the ram
}

