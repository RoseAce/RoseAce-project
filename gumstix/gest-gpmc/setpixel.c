#include "roseace_gpmc.h"
#include "roseace_utilities.h"
#include <stdlib.h>

int main(int argc, char *argv[]) {
  if (argc != 5) 
    {
      perror("Error, this function needs 4 arguments, setpixel(char red, char, green, char blue, char addr);\n");
      return 1; 
    }
  roseace_init_gpmc();

  send_pixel_to_fpga(atoi(argv[1]), atoi(argv[2]), atoi(argv[3]), 2*atoi(argv[4]));

  return 0;
}
